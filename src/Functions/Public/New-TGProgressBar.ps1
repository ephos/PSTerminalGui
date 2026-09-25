function New-TGProgressBar {
    <#
    .SYNOPSIS
    Creates a progress bar.

    .PARAMETER Fraction
    Progress from 0.0 to 1.0.

    .PARAMETER Style
    Blocks, Continuous, MarqueeBlocks, MarqueeContinuous, or Fire.

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
    Hashtable of any other ProgressBar properties to set.

    .EXAMPLE
    TGProgressBar -Id progress -Width Fill -Style Continuous
    #>
    [CmdletBinding()]
    [Alias('TGProgressBar')]
    [OutputType([Terminal.Gui.Views.ProgressBar])]
    param (
        [Parameter(Mandatory=$false, Position=0)]
        [single]
        $Fraction,

        [Parameter(Mandatory=$false)]
        [Terminal.Gui.Views.ProgressBarStyle]
        $Style,

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
        $view = [Terminal.Gui.Views.ProgressBar]::new()
        if ($PSBoundParameters.ContainsKey('Fraction')) { $view.Fraction = $Fraction }
        if ($PSBoundParameters.ContainsKey('Style')) { $view.ProgressBarStyle = $Style }
        Set-TGViewCommon -View $view -BoundParameters $PSBoundParameters
        $view
    }
}