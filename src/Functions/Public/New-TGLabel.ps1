function New-TGLabel {
    <#
    .SYNOPSIS
    Creates a Label that displays text.

    .PARAMETER Text
    Text to display. Use _ before a letter to make it a hotkey that focuses the next view.

    .PARAMETER Id
    Id used to find the view with Get-TGView.

    .PARAMETER X
    Column: int, 'Center', 'N%', 'AnchorEnd', or a Pos from New-TGPos.

    .PARAMETER Y
    Row: int, 'Center', 'N%', 'AnchorEnd', or a Pos from New-TGPos.

    .PARAMETER Width
    Width: int, 'Fill', 'Fill-N', 'Auto', 'N%', or a Dim from New-TGDim. Defaults to fitting the text.

    .PARAMETER Height
    Height: int, 'Fill', 'Fill-N', 'Auto', 'N%', or a Dim from New-TGDim. Defaults to fitting the text.

    .PARAMETER Property
    Hashtable of any other Label properties to set.

    .EXAMPLE
    New-TGLabel 'Name:' -X 1 -Y 1
    #>
    [CmdletBinding()]
    [Alias('TGLabel')]
    [OutputType([Terminal.Gui.Views.Label])]
    param (
        [Parameter(Mandatory=$false, Position=0)]
        [string]
        $Text,

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
        $view = [Terminal.Gui.Views.Label]::new()
        if ($PSBoundParameters.ContainsKey('Text')) { $view.Text = $Text }
        Set-TGViewCommon -View $view -BoundParameters $PSBoundParameters
        $view
    }
}
