function Get-TGDependencyPath {
    [CmdletBinding()]
    [OutputType([string])]
    param (
        # Terminal.Gui version, which names the folder
        [Parameter(Mandatory=$false)]
        [string]
        $Version = $script:TGDependencyVersion
    )

    process {
        # LocalApplicationData is ~/.local/share (or $XDG_DATA_HOME) on Linux,
        # ~/Library/Application Support on macOS, and %LOCALAPPDATA% on Windows.
        $base = if ($env:PSTERMINALGUI_DEPENDENCY_PATH) {
            $env:PSTERMINALGUI_DEPENDENCY_PATH
        } else {
            Join-Path -Path ([Environment]::GetFolderPath('LocalApplicationData')) -ChildPath 'PSTerminalGui'
        }
        Join-Path -Path $base -ChildPath $Version
    }
}
