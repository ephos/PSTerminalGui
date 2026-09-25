function Show-TGOpenDialog {
    <#
    .SYNOPSIS
    Shows a file/folder open dialog and returns the chosen path(s).

    .DESCRIPTION
    Works inside a running application and from plain scripts.

    .PARAMETER Title
    Dialog title.

    .PARAMETER Path
    Folder (or file) to start in. Defaults to the current location.

    .PARAMETER Filter
    Allowed file types, as a hashtable of description to extensions, e.g. @{ 'PowerShell' = '.ps1', '.psm1' }.

    .PARAMETER Mode
    Pick files, directories, or both.

    .PARAMETER AllowMultiple
    Allow choosing several paths.

    .EXAMPLE
    $script = Show-TGOpenDialog -Title 'Pick a script' -Filter @{ 'PowerShell' = '.ps1' }

    .OUTPUTS
    The chosen path(s), or nothing if the dialog was cancelled.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param (
        [Parameter(Mandatory=$false, Position=0)]
        [string]
        $Title = 'Open',

        [Parameter(Mandatory=$false)]
        [string]
        $Path = $PWD.ProviderPath,

        [Parameter(Mandatory=$false)]
        [hashtable]
        $Filter,

        [Parameter(Mandatory=$false)]
        [ValidateSet('File', 'Directory', 'Mixed')]
        [string]
        $Mode = 'File',

        [Parameter(Mandatory=$false)]
        [switch]
        $AllowMultiple
    )

    process {
        Invoke-TGModal -ScriptBlock {
            param($app)
            $dialog = [Terminal.Gui.Views.OpenDialog]::new()
            try {
                $dialog.Title = $Title
                $dialog.Path = $Path
                $dialog.OpenMode = $Mode
                $dialog.AllowsMultipleSelection = $AllowMultiple.IsPresent
                foreach ($description in $Filter.Keys) {
                    $dialog.AllowedTypes.Add([Terminal.Gui.Views.AllowedType]::new($description, [string[]]$Filter[$description]))
                }

                $null = $app.Run($dialog, $null)

                if (-not $dialog.Canceled) {
                    if ($AllowMultiple -and $dialog.MultiSelected.Count -gt 0) {
                        $dialog.MultiSelected
                    } else {
                        $dialog.Path
                    }
                }
            } finally {
                $dialog.Dispose()
            }
        }
    }
}
