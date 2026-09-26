function Get-TGTitleLabel {
    [CmdletBinding()]
    [OutputType([Terminal.Gui.Views.Label])]
    param (
        # View whose title is styled
        [Parameter(Mandatory=$true)]
        [Terminal.Gui.ViewBase.View]
        $View
    )

    # Terminal.Gui draws a title with the same colors as its border whenever the view does not have focus.
    # To style the title on its own, a label is laid over the title text inside the border adornment,
    # leaving the built-in title's position and end caps (┤ ├) in place. The label follows title changes.
    process {
        if (-not $View.Border -or -not $View.Border.View -or $View.Border.Thickness.Top -lt 1) {
            throw "$($View.GetType().Name) has no top border to draw a title in."
        }

        $marker = 'PSTerminalGui.Title'
        $label = $View.Border.View.SubViews | Where-Object { $_.Data -eq $marker } | Select-Object -First 1
        if ($label) { return $label }

        # Terminal.Gui removes the first _ from a title, it marks the hotkey.
        $getText = { param($title) $title -replace '^([^_]*)_', '$1' }

        $label = [Terminal.Gui.Views.Label]::new()
        $label.Data = $marker
        $label.Text = & $getText $View.Title
        $label.X = [Terminal.Gui.ViewBase.Pos]::Absolute(2)
        $label.Y = [Terminal.Gui.ViewBase.Pos]::Absolute(0)
        $label.CanFocus = $false
        $null = $View.Border.View.Add($label)

        Register-TGEventInternal -InputObject $View -EventName 'TitleChanged' -Action {
            $label.Text = & $getText $this.Title
        }.GetNewClosure()

        $label
    }
}
