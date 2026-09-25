function ConvertTo-TGPos {
    [CmdletBinding()]
    [OutputType([Terminal.Gui.ViewBase.Pos])]
    param (
        # Int, Pos object, or friendly string: 'Center', '50%', 'AnchorEnd', 'AnchorEnd(3)', optionally with an offset ('Center+2', '50%-1').
        [Parameter(Mandatory=$true)]
        [object]
        $Value
    )

    process {
        if ($Value -is [Terminal.Gui.ViewBase.Pos]) {
            return $Value
        }

        if ($Value -is [int] -or $Value -is [long] -or $Value -is [double]) {
            return [Terminal.Gui.ViewBase.Pos]::Absolute([int]$Value)
        }

        $text = "$Value".Trim()
        if ($text -notmatch '^(?<base>\d+%?|Center|AnchorEnd(\((?<anchor>\d+)\))?)\s*((?<op>[+-])\s*(?<offset>\d+))?$') {
            throw "Cannot convert '$Value' to a Pos. Use an int, a Pos object, 'Center', 'N%', 'AnchorEnd', or 'AnchorEnd(N)', optionally followed by +N or -N."
        }

        # switch -Regex overwrites $Matches, keep a copy.
        $m = $Matches.Clone()

        $pos = switch -Regex ($m.base) {
            '^\d+$'      { [Terminal.Gui.ViewBase.Pos]::Absolute([int]$m.base) }
            '^(\d+)%$'   { [Terminal.Gui.ViewBase.Pos]::Percent([int]$m.base.TrimEnd('%')) }
            '^Center$'   { [Terminal.Gui.ViewBase.Pos]::Center() }
            '^AnchorEnd' {
                if ($m.anchor) {
                    [Terminal.Gui.ViewBase.Pos]::AnchorEnd([int]$m.anchor)
                } else {
                    [Terminal.Gui.ViewBase.Pos]::AnchorEnd()
                }
            }
        }

        if ($m.offset) {
            $offset = [Terminal.Gui.ViewBase.Pos]::Absolute([int]$m.offset)
            if ($m.op -eq '+') {
                $pos = [Terminal.Gui.ViewBase.Pos]::op_Addition($pos, $offset)
            } else {
                $pos = [Terminal.Gui.ViewBase.Pos]::op_Subtraction($pos, $offset)
            }
        }

        $pos
    }
}
