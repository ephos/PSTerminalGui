function Install-TGDependency {
    <#
    .SYNOPSIS
    Restores Terminal.Gui and its dependencies from nuget.org into a per-user folder.

    .DESCRIPTION
    PSTerminalGui runs this automatically the first time it is imported. Run it yourself to repair an
    install (-Force), or when the automatic restore failed: the module then loads with only this command,
    and you import it again (Import-Module PSTerminalGui -Force) once the restore has worked.

    Resolves the Terminal.Gui NuGet package and its dependencies without the .NET SDK, then copies the
    managed assemblies and the native libraries for this OS and CPU (e.g. libonigwrap, used for syntax
    highlighting in Markdown code blocks) into one folder:

        Linux    ~/.local/share/PSTerminalGui/<version>
        macOS    ~/Library/Application Support/PSTerminalGui/<version>
        Windows  %LOCALAPPDATA%\PSTerminalGui\<version>

    Set $env:PSTERMINALGUI_DEPENDENCY_PATH to use another base folder.

    .PARAMETER Version
    Terminal.Gui NuGet version to restore. Defaults to the version PSTerminalGui is built against.

    .PARAMETER Destination
    Folder the files are copied into. Defaults to the per-user folder above.

    .PARAMETER Force
    Restore again even when the folder already has Terminal.Gui. Files already loaded in a session
    may be locked on Windows; close other PowerShell sessions using the module first.

    .EXAMPLE
    Install-TGDependency -Force | Format-Table

    .OUTPUTS
    One object per file copied: Package, Version, File, and Target (framework or runtime identifier).
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$false)]
        [string]
        $Version = $script:TGDependencyVersion,

        [Parameter(Mandatory=$false)]
        [string]
        $Destination,

        [Parameter(Mandatory=$false)]
        [switch]
        $Force
    )

    process {
        $ErrorActionPreference = 'Stop'
        $ProgressPreference = 'SilentlyContinue'

        if (-not $Destination) {
            $Destination = Get-TGDependencyPath -Version $Version
        }
        if (-not $Force -and (Test-Path -Path (Join-Path -Path $Destination -ChildPath 'Terminal.Gui.dll'))) {
            Write-Information -MessageData "Terminal.Gui $Version is already installed in '$Destination'. Use -Force to restore it again." -InformationAction Continue
            return
        }

        $feed = 'https://api.nuget.org/v3-flatcontainer'
        # Frameworks we can load in pwsh 7.6 (.NET 10), best match first.
        $tfmOrder = 'net10.0', 'net9.0', 'net8.0', 'net7.0', 'net6.0', 'netstandard2.1', 'netstandard2.0'

        # Runtime identifiers for native libraries (runtimes/<rid>/native), best match first.
        $arch = [System.Runtime.InteropServices.RuntimeInformation]::OSArchitecture.ToString().ToLowerInvariant()
        $os = if ($IsWindows) {
            'win'
        } elseif ($IsMacOS) {
            'osx'
        } elseif (Get-ChildItem -Path '/lib/ld-musl-*' -ErrorAction SilentlyContinue) {
            'linux-musl'
        } else {
            'linux'
        }
        $ridOrder = "$os-$arch", $os

        $cache = Join-Path -Path ([System.IO.Path]::GetTempPath()) -ChildPath 'tg-nuget-cache'
        # Stage into a sibling folder so a failed restore never leaves a half-populated destination behind.
        $staging = "$Destination.partial"
        Remove-Item -Path $staging -Recurse -Force -ErrorAction SilentlyContinue
        New-Item -Path $cache, $staging -ItemType Directory -Force | Out-Null

        # Assemblies pwsh already loads; never ship an older/equal copy of these.
        $pwshAssemblies = @{}
        Get-ChildItem -Path $PSHOME, ([System.Runtime.InteropServices.RuntimeEnvironment]::GetRuntimeDirectory()) -Filter *.dll |
            ForEach-Object {
                try {
                    $pwshAssemblies[$_.BaseName] = [System.Reflection.AssemblyName]::GetAssemblyName($_.FullName).Version
                } catch {
                    Write-Verbose -Message "Skipping $($_.TargetObject), not a .NET assembly"
                }
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
                Expand-Archive -Path $nupkg -DestinationPath $extract -Force -Verbose:$false 4>$null
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

            # Native libraries go next to the managed assemblies, where .NET probes for [DllImport] targets.
            $rid = $ridOrder | Where-Object { Test-Path -Path (Join-Path -Path $extract -ChildPath "runtimes/$_/native") } | Select-Object -First 1
            if ($rid) {
                foreach ($file in Get-ChildItem -Path (Join-Path -Path $extract -ChildPath "runtimes/$rid/native") -File) {
                    Copy-Item -Path $file.FullName -Destination $staging -Force
                    [PSCustomObject]@{ Package = $pkg.Id; Version = $ver; File = $file.Name; Target = $rid }
                }
            }

            $libRoot = Join-Path -Path $extract -ChildPath 'lib'
            if (-not (Test-Path -Path $libRoot)) { continue }
            $tfm = $tfmOrder | Where-Object { Test-Path -Path (Join-Path -Path $libRoot -ChildPath $_) } | Select-Object -First 1
            if (-not $tfm) { continue }

            foreach ($dll in Get-ChildItem -Path (Join-Path -Path $libRoot -ChildPath $tfm) -Filter *.dll) {
                $dllVer = [System.Reflection.AssemblyName]::GetAssemblyName($dll.FullName).Version
                if ($pwshAssemblies.ContainsKey($dll.BaseName) -and $pwshAssemblies[$dll.BaseName] -ge $dllVer) {
                    Write-Verbose -Message "Skipping $($dll.Name) $dllVer (pwsh ships $($pwshAssemblies[$dll.BaseName]))"
                    continue
                }
                Copy-Item -Path $dll.FullName -Destination $staging -Force
                [PSCustomObject]@{ Package = $pkg.Id; Version = $ver; File = $dll.Name; Target = $tfm }
            }
        }

        if (Test-Path -Path $Destination) {
            # Reinstall: copy over the existing files, which may be locked if another session has them loaded.
            Copy-Item -Path (Join-Path -Path $staging -ChildPath '*') -Destination $Destination -Force
            Remove-Item -Path $staging -Recurse -Force
        } else {
            Move-Item -Path $staging -Destination $Destination
        }
    }
}
