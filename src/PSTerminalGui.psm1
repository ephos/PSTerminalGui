# Unblock files if Windows.
if ($PSVersionTable.Platform -eq 'Windows') {
    Get-ChildItem -Path $PSScriptRoot -Recurse | Unblock-File
}

# Terminal.Gui version this module is built against, restored by Install-TGDependency.
$script:TGDependencyVersion = '2.5.0'

# Load Terminal.Gui and its dependencies from the per-user dependency folder, restoring them on first use.
# This has to happen before the other functions are dot sourced, scripts that reference [Terminal.Gui.*] types fail to parse otherwise.
# Install-TGDependency and its path helper do not reference those types, so they are loaded first.
. $PSScriptRoot/Functions/Public/Install-TGDependency.ps1
. $PSScriptRoot/Functions/Private/Get-TGDependencyPath.ps1

$libPath = Get-TGDependencyPath
if (-not (Test-Path -Path (Join-Path -Path $libPath -ChildPath 'Terminal.Gui.dll'))) {
    Write-Warning -Message "Terminal.Gui not found in '$libPath'. Downloading it from nuget.org, this only happens once."
    try {
        $null = Install-TGDependency
    } catch {
        # Import anyway with just Install-TGDependency, so the restore can be retried without reinstalling the module.
        Write-Warning -Message "Could not restore Terminal.Gui: $($_.Exception.Message)"
        Write-Warning -Message 'Only Install-TGDependency is available. Run it, then Import-Module PSTerminalGui -Force.'
        Export-ModuleMember -Function Install-TGDependency
        return
    }
}
Get-ChildItem -Path $libPath -Filter *.dll | ForEach-Object {
    # Native libraries (e.g. libonigwrap.dll on Windows) share the folder; .NET loads those itself.
    try { $null = [System.Reflection.AssemblyName]::GetAssemblyName($_.FullName) } catch { return }
    Add-Type -Path $_.FullName
}

# Module state.
$script:TGApp = $null                 # The running IApplication, set by Start-TGApplication.
$script:TGRunError = $null            # First exception raised while the application loop was running.
$script:TGViewRegistry = @{}          # Views keyed by -Id, used by Get-TGView.
$script:TGPendingTimeouts = [System.Collections.Generic.List[PSCustomObject]]::new()
$script:TGBarLabels = [System.Runtime.CompilerServices.ConditionalWeakTable[object, object]]::new()  # Full bar labels, shortened to fit by Update-TGGraphScale.

# Work queued by Invoke-TGOnUIThread. Stored on the AppDomain so other runspaces (thread jobs) share it.
$script:TGUIQueueKey = 'PSTerminalGui.UIQueue'
if (-not [AppDomain]::CurrentDomain.GetData($script:TGUIQueueKey)) {
    [AppDomain]::CurrentDomain.SetData($script:TGUIQueueKey, [System.Collections.Concurrent.ConcurrentQueue[PSCustomObject]]::new())
}

# Dot source classes.
# Get-ChildItem -Path $PSScriptRoot\Classes\*.ps1 | Foreach-Object { . $_.FullName }

# Dot source public functions.
Get-ChildItem -Path $PSScriptRoot\Functions\Public\*.ps1 | Foreach-Object { . $_.FullName }

# Dot source private functions.
Get-ChildItem -Path $PSScriptRoot\Functions\Private\*.ps1 | Foreach-Object { . $_.FullName }

# PS1XML to customize output.
Update-FormatData -PrependPath $PSScriptRoot\Format\tg.format.ps1xml

# Argument completion.
Get-ChildItem -Path $PSScriptRoot\Completers\*.ps1 -ErrorAction SilentlyContinue | Foreach-Object { . $_.FullName }
