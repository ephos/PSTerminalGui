# Unblock files if Windows.
if ($PSVersionTable.Platform -eq 'Windows') {
    Get-ChildItem -Path $PSScriptRoot -Recurse | Unblock-File
}

# Load Terminal.Gui and its dependencies.
# This has to happen before anything is dot sourced, scripts that reference [Terminal.Gui.*] types fail to parse otherwise.
$libPath = Join-Path -Path $PSScriptRoot -ChildPath 'lib'
if (-not (Test-Path -Path (Join-Path -Path $libPath -ChildPath 'Terminal.Gui.dll'))) {
    throw "Terminal.Gui assemblies not found in '$libPath'. Run ./build/Install-TGDependency.ps1 to restore them."
}
Get-ChildItem -Path $libPath -Filter *.dll | ForEach-Object { Add-Type -Path $_.FullName }

# Module state.
$script:TGApp = $null                 # The running IApplication, set by Start-TGApplication.
$script:TGRunError = $null            # First exception raised while the application loop was running.
$script:TGViewRegistry = @{}          # Views keyed by -Id, used by Get-TGView.
$script:TGPendingTimeouts = [System.Collections.Generic.List[PSCustomObject]]::new()

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
