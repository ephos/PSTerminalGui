function New-TGDim {
    <#
    .SYNOPSIS
    Creates a Terminal.Gui Dim (a width or height), including sizes relative to other views.

    .DESCRIPTION
    Simple sizes can be passed straight to -Width/-Height as ints or strings ('Fill', 'Fill-2', 'Auto', '50%').
    Use this function for sizes relative to another view or to fill up to another view.

    .PARAMETER Value
    Int or friendly string, same as -Width/-Height accept.

    .PARAMETER WidthOf
    Match the width of this view.

    .PARAMETER HeightOf
    Match the height of this view.

    .PARAMETER FillTo
    Fill the available space up to this view.

    .PARAMETER Offset
    Cells to add (or subtract, if negative).

    .EXAMPLE
    New-TGListView -Height (New-TGDim -FillTo $statusBar)
    #>
    [CmdletBinding(DefaultParameterSetName='Value')]
    [OutputType([Terminal.Gui.ViewBase.Dim])]
    param (
        [Parameter(Mandatory=$true, Position=0, ParameterSetName='Value')]
        [object]
        $Value,

        [Parameter(Mandatory=$true, ParameterSetName='WidthOf')]
        [Terminal.Gui.ViewBase.View]
        $WidthOf,

        [Parameter(Mandatory=$true, ParameterSetName='HeightOf')]
        [Terminal.Gui.ViewBase.View]
        $HeightOf,

        [Parameter(Mandatory=$true, ParameterSetName='FillTo')]
        [Terminal.Gui.ViewBase.View]
        $FillTo,

        [Parameter(Mandatory=$false)]
        [int]
        $Offset = 0
    )

    process {
        $dim = switch ($PSCmdlet.ParameterSetName) {
            'Value'    { ConvertTo-TGDim -Value $Value }
            'WidthOf'  { [Terminal.Gui.ViewBase.Dim]::Width($WidthOf) }
            'HeightOf' { [Terminal.Gui.ViewBase.Dim]::Height($HeightOf) }
            'FillTo'   { [Terminal.Gui.ViewBase.Dim]::Fill([Terminal.Gui.ViewBase.View]$FillTo) }
        }

        if ($Offset -ne 0) {
            $dim = [Terminal.Gui.ViewBase.Dim]::op_Addition($dim, [Terminal.Gui.ViewBase.Dim]::Absolute($Offset))
        }

        $dim
    }
}
