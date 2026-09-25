function New-TGPos {
    <#
    .SYNOPSIS
    Creates a Terminal.Gui Pos (an X or Y position), including positions relative to other views.

    .DESCRIPTION
    Simple positions can be passed straight to -X/-Y as ints or strings ('Center', '50%', 'AnchorEnd').
    Use this function for positions relative to another view.

    .PARAMETER Value
    Int or friendly string, same as -X/-Y accept.

    .PARAMETER Left
    Left edge of this view.

    .PARAMETER Right
    Right edge of this view (the column just after it).

    .PARAMETER Top
    Top edge of this view.

    .PARAMETER Bottom
    Bottom edge of this view (the row just below it).

    .PARAMETER Offset
    Cells to add (or subtract, if negative).

    .EXAMPLE
    $label = New-TGLabel 'Name:'
    New-TGTextField -X (New-TGPos -Right $label -Offset 1)
    #>
    [CmdletBinding(DefaultParameterSetName='Value')]
    [OutputType([Terminal.Gui.ViewBase.Pos])]
    param (
        [Parameter(Mandatory=$true, Position=0, ParameterSetName='Value')]
        [object]
        $Value,

        [Parameter(Mandatory=$true, ParameterSetName='Left')]
        [Terminal.Gui.ViewBase.View]
        $Left,

        [Parameter(Mandatory=$true, ParameterSetName='Right')]
        [Terminal.Gui.ViewBase.View]
        $Right,

        [Parameter(Mandatory=$true, ParameterSetName='Top')]
        [Terminal.Gui.ViewBase.View]
        $Top,

        [Parameter(Mandatory=$true, ParameterSetName='Bottom')]
        [Terminal.Gui.ViewBase.View]
        $Bottom,

        [Parameter(Mandatory=$false)]
        [int]
        $Offset = 0
    )

    process {
        $pos = switch ($PSCmdlet.ParameterSetName) {
            'Value'  { ConvertTo-TGPos -Value $Value }
            'Left'   { [Terminal.Gui.ViewBase.Pos]::Left($Left) }
            'Right'  { [Terminal.Gui.ViewBase.Pos]::Right($Right) }
            'Top'    { [Terminal.Gui.ViewBase.Pos]::Top($Top) }
            'Bottom' { [Terminal.Gui.ViewBase.Pos]::Bottom($Bottom) }
        }

        if ($Offset -ne 0) {
            $pos = [Terminal.Gui.ViewBase.Pos]::op_Addition($pos, [Terminal.Gui.ViewBase.Pos]::Absolute($Offset))
        }

        $pos
    }
}
