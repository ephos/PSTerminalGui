function ConvertTo-TGDim {
    [CmdletBinding()]
    [OutputType([Terminal.Gui.ViewBase.Dim])]
    param (
        # Int, Dim object, or friendly string: 'Fill', 'Fill-2', 'Auto', '50%', optionally with an offset ('50%+2').
        [Parameter(Mandatory=$true)]
        [object]
        $Value
    )

    process {
        if ($Value -is [Terminal.Gui.ViewBase.Dim]) {
            return $Value
        }

        if ($Value -is [int] -or $Value -is [long] -or $Value -is [double]) {
            return [Terminal.Gui.ViewBase.Dim]::Absolute([int]$Value)
        }

        $text = "$Value".Trim()

        # 'Fill-N' means fill, leaving N cells as a margin.
        if ($text -match '^Fill\s*(-\s*(?<margin>\d+))?$') {
            if ($Matches.margin) {
                return [Terminal.Gui.ViewBase.Dim]::Fill([Terminal.Gui.ViewBase.Dim]::Absolute([int]$Matches.margin))
            }
            return [Terminal.Gui.ViewBase.Dim]::Fill()
        }

        if ($text -notmatch '^(?<base>\d+%?|Auto)\s*((?<op>[+-])\s*(?<offset>\d+))?$') {
            throw "Cannot convert '$Value' to a Dim. Use an int, a Dim object, 'Fill', 'Fill-N', 'Auto', or 'N%', optionally followed by +N or -N."
        }

        # switch -Regex overwrites $Matches, keep a copy.
        $m = $Matches.Clone()

        $dim = switch -Regex ($m.base) {
            '^\d+$'    { [Terminal.Gui.ViewBase.Dim]::Absolute([int]$m.base) }
            '^(\d+)%$' { [Terminal.Gui.ViewBase.Dim]::Percent([int]$m.base.TrimEnd('%')) }
            '^Auto$'   { [Terminal.Gui.ViewBase.Dim]::Auto() }
        }

        if ($m.offset) {
            $offset = [Terminal.Gui.ViewBase.Dim]::Absolute([int]$m.offset)
            if ($m.op -eq '+') {
                $dim = [Terminal.Gui.ViewBase.Dim]::op_Addition($dim, $offset)
            } else {
                $dim = [Terminal.Gui.ViewBase.Dim]::op_Subtraction($dim, $offset)
            }
        }

        $dim
    }
}
