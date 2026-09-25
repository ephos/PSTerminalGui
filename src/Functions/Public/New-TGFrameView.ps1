function New-TGFrameView {
    <#
    .SYNOPSIS
    Creates a FrameView, a bordered container used to group views.

    .PARAMETER Title
    Title shown in the border.

    .PARAMETER Content
    Scriptblock whose view output is added as child views.

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
    Hashtable of any other FrameView properties to set.

    .EXAMPLE
    TGFrameView 'Options' -X 1 -Y 1 -Width 30 -Height 6 {
        TGCheckBox 'Verbose' -Id verbose
    }
    #>
    [CmdletBinding()]
    [Alias('TGFrameView')]
    [OutputType([Terminal.Gui.Views.FrameView])]
    param (
        [Parameter(Mandatory=$false, Position=0)]
        [string]
        $Title,

        [Parameter(Mandatory=$false, Position=1)]
        [scriptblock]
        $Content,

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
        $view = [Terminal.Gui.Views.FrameView]::new()
        Set-TGViewCommon -View $view -BoundParameters $PSBoundParameters
        if ($Content) { Add-TGContent -Parent $view -Content $Content }
        $view
    }
}