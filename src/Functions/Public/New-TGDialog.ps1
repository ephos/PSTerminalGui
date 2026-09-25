function New-TGDialog {
    <#
    .SYNOPSIS
    Creates a modal Dialog with buttons along the bottom.

    .DESCRIPTION
    Run it with Start-TGApplication (nested inside a running app, or on its own).
    The run result is the index of the button that closed the dialog, or nothing if cancelled with Esc.

    .PARAMETER Title
    Title shown in the border.

    .PARAMETER Content
    Scriptblock whose view output is added as child views.

    .PARAMETER Button
    Button captions, e.g. 'OK', 'Cancel'.

    .PARAMETER Id
    Id used to find the view with Get-TGView.

    .PARAMETER X
    Column: int, 'Center', 'N%', 'AnchorEnd', or a Pos from New-TGPos.

    .PARAMETER Y
    Row: int, 'Center', 'N%', 'AnchorEnd', or a Pos from New-TGPos.

    .PARAMETER Width
    Width: int, 'Fill', 'Fill-N', 'Auto', 'N%', or a Dim from New-TGDim.

    .PARAMETER Height
    Height: int, 'Fill', 'Fill-N', 'Auto', 'N%', or a Dim from New-TGDim.

    .PARAMETER Property
    Hashtable of any other Dialog properties to set.

    .EXAMPLE
    $answer = TGDialog 'Confirm' { TGLabel 'Delete it?' -X Center -Y 1 } -Button Yes, No | Start-TGApplication
    if ($answer -eq 0) { 'Deleting' }
    #>
    [CmdletBinding()]
    [Alias('TGDialog')]
    [OutputType([Terminal.Gui.Views.Dialog])]
    param (
        [Parameter(Mandatory=$false, Position=0)]
        [string]
        $Title,

        [Parameter(Mandatory=$false, Position=1)]
        [scriptblock]
        $Content,

        [Parameter(Mandatory=$false)]
        [string[]]
        $Button,

        [Parameter(Mandatory=$false)]
        [string]
        $Id,

        [Parameter(Mandatory=$false)]
        [object]
        $X,

        [Parameter(Mandatory=$false)]
        [object]
        $Y,

        [Parameter(Mandatory=$false)]
        [object]
        $Width,

        [Parameter(Mandatory=$false)]
        [object]
        $Height,

        [Parameter(Mandatory=$false)]
        [hashtable]
        $Property
    )

    process {
        $view = [Terminal.Gui.Views.Dialog]::new()
        Set-TGViewCommon -View $view -BoundParameters $PSBoundParameters
        foreach ($caption in $Button) {
            $dialogButton = [Terminal.Gui.Views.Button]::new()
            $dialogButton.Text = $caption
            $view.AddButton($dialogButton)
        }
        if ($Content) { Add-TGContent -Parent $view -Content $Content }
        $view
    }
}