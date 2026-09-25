function Show-TGSaveDialog {
    <#
    .SYNOPSIS
    Shows a save-as dialog and returns the chosen path.

    .DESCRIPTION
    Works inside a running application and from plain scripts.

    .PARAMETER Title
    Dialog title.

    .PARAMETER Path
    Folder or file name to start with. Defaults to the current location.

    .PARAMETER Filter
    Allowed file types, as a hashtable of description to extensions, e.g. @{ 'CSV' = '.csv' }.

    .EXAMPLE
    $target = Show-TGSaveDialog -Title 'Export' -Filter @{ 'CSV' = '.csv' }
    if ($target) { Get-Process | Export-Csv -Path $target }

    .OUTPUTS
    The chosen path, or nothing if the dialog was cancelled.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param (
        [Parameter(Mandatory=$false, Position=0)]
        [string]
        $Title = 'Save',

        [Parameter(Mandatory=$false)]
        [string]
        $Path = $PWD.ProviderPath,

        [Parameter(Mandatory=$false)]
        [hashtable]
        $Filter
    )

    process {
        Invoke-TGModal -ScriptBlock {
            param($app)
            $dialog = [Terminal.Gui.Views.SaveDialog]::new()
            try {
                $dialog.Title = $Title
                $dialog.Path = $Path
                foreach ($description in $Filter.Keys) {
                    $dialog.AllowedTypes.Add([Terminal.Gui.Views.AllowedType]::new($description, [string[]]$Filter[$description]))
                }

                $null = $app.Run($dialog, $null)

                if (-not $dialog.Canceled) { $dialog.Path }
            } finally {
                $dialog.Dispose()
            }
        }
    }
}
