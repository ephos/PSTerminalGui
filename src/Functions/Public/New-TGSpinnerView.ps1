function New-TGSpinnerView {
    <#
    .SYNOPSIS
    Creates an animated activity spinner.

    .PARAMETER NoAutoSpin
    Do not animate automatically. Call $view.AdvanceAnimation() yourself.

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
    Hashtable of any other SpinnerView properties to set.

    .EXAMPLE
    TGSpinnerView -Id busy -X 1 -Y 1
    #>
    [CmdletBinding()]
    [Alias('TGSpinnerView')]
    [OutputType([Terminal.Gui.Views.SpinnerView])]
    param (
        [Parameter(Mandatory=$false)]
        [switch]
        $NoAutoSpin,

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
        $view = [Terminal.Gui.Views.SpinnerView]::new()
        $view.AutoSpin = -not $NoAutoSpin
        Set-TGViewCommon -View $view -BoundParameters $PSBoundParameters
        $view
    }
}