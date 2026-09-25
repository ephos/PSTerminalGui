[CmdletBinding()]
param (
    # Terminal.Gui NuGet version to restore
    [Parameter(Mandatory=$false)]
    [string]
    $Version = '2.5.0',

    # Folder the DLLs are copied into
    [Parameter(Mandatory=$false)]
    [string]
    $Destination = (Join-Path -Path $PSScriptRoot -ChildPath '../src/lib')
)

$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
$feed = 'https://api.nuget.org/v3-flatcontainer'
# Frameworks we can load in pwsh 7.6 (.NET 10), best match first.
$tfmOrder = 'net10.0', 'net9.0', 'net8.0', 'net7.0', 'net6.0', 'netstandard2.1', 'netstandard2.0'

$cache = Join-Path -Path ([System.IO.Path]::GetTempPath()) -ChildPath 'tg-nuget-cache'
New-Item -Path $cache, $Destination -ItemType Directory -Force | Out-Null

# Assemblies pwsh already loads; never ship an older/equal copy of these.
$pwshAssemblies = @{}
Get-ChildItem -Path $PSHOME, ([System.Runtime.InteropServices.RuntimeEnvironment]::GetRuntimeDirectory()) -Filter *.dll |
    ForEach-Object {
        try {
            $pwshAssemblies[$_.BaseName] = [System.Reflection.AssemblyName]::GetAssemblyName($_.FullName).Version
        } catch { }
    }

$resolved = @{}
$queue = [System.Collections.Generic.Queue[object]]::new()
$queue.Enqueue(@{ Id = 'Terminal.Gui'; Version = $Version })

while ($queue.Count -gt 0) {
    $pkg = $queue.Dequeue()
    $id = $pkg.Id.ToLowerInvariant()
    $ver = $pkg.Version.ToLowerInvariant()

    if ($resolved.ContainsKey($id) -and [version]($resolved[$id] -replace '-.*') -ge [version]($ver -replace '-.*')) {
        continue
    }
    $resolved[$id] = $ver

    $nupkg = Join-Path -Path $cache -ChildPath "$id.$ver.nupkg"
    if (-not (Test-Path -Path $nupkg)) {
        Write-Verbose -Message "Downloading $id $ver"
        Invoke-WebRequest -Uri "$feed/$id/$ver/$id.$ver.nupkg" -OutFile $nupkg -Verbose:$false
    }

    $extract = Join-Path -Path $cache -ChildPath "$id.$ver"
    if (-not (Test-Path -Path $extract)) {
        Expand-Archive -Path $nupkg -DestinationPath $extract -Force -Verbose:$false
    }

    # Pick the dependency group and lib folder for the best matching framework.
    [xml]$nuspec = Get-Content -Path (Get-ChildItem -Path $extract -Filter *.nuspec).FullName -Raw
    $groups = @($nuspec.package.metadata.dependencies.group)
    foreach ($tfm in $tfmOrder) {
        $group = $groups | Where-Object { $_.targetFramework -and $_.targetFramework.ToLowerInvariant() -in $tfm, ".netstandard$($tfm -replace 'netstandard')", ".netcoreapp$($tfm -replace 'net')" } | Select-Object -First 1
        if ($group) { break }
    }
    foreach ($dep in @($group.dependency)) {
        if (-not $dep) { continue }
        # Version ranges look like "[1.2.3, )" or "1.2.3"; take the minimum.
        $depVer = ($dep.version -replace '[\[\]\(\) ]').Split(',')[0]
        $queue.Enqueue(@{ Id = $dep.id; Version = $depVer })
    }

    $libRoot = Join-Path -Path $extract -ChildPath 'lib'
    if (-not (Test-Path -Path $libRoot)) { continue }
    $libDir = $tfmOrder | ForEach-Object { Join-Path -Path $libRoot -ChildPath $_ } | Where-Object { Test-Path -Path $_ } | Select-Object -First 1
    if (-not $libDir) { continue }

    foreach ($dll in Get-ChildItem -Path $libDir -Filter *.dll) {
        $dllVer = [System.Reflection.AssemblyName]::GetAssemblyName($dll.FullName).Version
        if ($pwshAssemblies.ContainsKey($dll.BaseName) -and $pwshAssemblies[$dll.BaseName] -ge $dllVer) {
            Write-Verbose -Message "Skipping $($dll.Name) $dllVer (pwsh ships $($pwshAssemblies[$dll.BaseName]))"
            continue
        }
        Copy-Item -Path $dll.FullName -Destination $Destination -Force
        [PSCustomObject]@{ Package = $pkg.Id; Version = $ver; Assembly = $dll.Name; AssemblyVersion = $dllVer }
    }
}
