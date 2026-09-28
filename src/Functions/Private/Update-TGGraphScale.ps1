function Update-TGGraphScale {
    # Fits a graph's scale, scroll offset, margins, and axis labels to its data and current viewport.
    # Runs before every draw, so data changed after creation (then SetNeedsDraw) is refitted too.
    [CmdletBinding()]
    param (
        # Graph to fit
        [Parameter(Mandatory=$true)]
        [Terminal.Gui.Views.GraphView]
        $Graph
    )

    begin {
        # Smallest 1, 2, or 5 x 10^n step that splits the range into at most $Count parts.
        function Get-NiceStep ([double]$Range, [double]$Count) {
            $raw = $Range / [math]::Max(1, $Count)
            $magnitude = [math]::Pow(10, [math]::Floor([math]::Log10($raw)))
            foreach ($factor in 1, 2, 5, 10) {
                if ($factor * $magnitude -ge $raw) { return $factor * $magnitude }
            }
        }

        # Enough decimals to tell the labels of a step apart, e.g. 0.25 -> 'N2', 50 -> 'N0'.
        function Get-LabelFormat ([double]$Step) {
            $decimals = 0
            while ($decimals -lt 6 -and [math]::Abs($Step * [math]::Pow(10, $decimals) - [math]::Round($Step * [math]::Pow(10, $decimals))) -gt 1e-6) {
                $decimals++
            }
            "N$decimals"
        }
    }

    process {
        $viewport = $Graph.Viewport
        $xs = [System.Collections.Generic.List[double]]::new()
        $ys = [System.Collections.Generic.List[double]]::new()
        $barCount = 0

        foreach ($series in $Graph.Series) {
            if ($series -is [Terminal.Gui.Views.BarSeries]) {
                $barCount = [math]::Max($barCount, $series.Bars.Count)
                foreach ($bar in $series.Bars) { $ys.Add($bar.Value) }
            } elseif ($series -is [Terminal.Gui.Views.ScatterSeries]) {
                foreach ($point in $series.Points) { $xs.Add($point.X); $ys.Add($point.Y) }
            }
        }
        foreach ($annotation in $Graph.Annotations) {
            if ($annotation -is [Terminal.Gui.Views.PathAnnotation]) {
                foreach ($point in $annotation.Points) { $xs.Add($point.X); $ys.Add($point.Y) }
            }
        }
        if ($ys.Count -eq 0) { return }

        $marginBottom = if ($Graph.AxisX.Text) { 3 } else { 2 }
        $plotHeight = $viewport.Height - $marginBottom
        if ($plotHeight -lt 2) { return }

        # Bars grow from zero; points use their own range. Round the range out to whole label steps.
        $yStats = $ys | Measure-Object -Minimum -Maximum
        $yMin = $yStats.Minimum
        $yMax = $yStats.Maximum
        if ($barCount) {
            $yMin = [math]::Min(0, $yMin)
            $yMax = [math]::Max(0, $yMax)
        }
        if ($yMax -eq $yMin) { $yMax = $yMin + 1 }
        $yStep = Get-NiceStep -Range ($yMax - $yMin) -Count ([math]::Floor($plotHeight / 2))
        $yMin = [math]::Floor($yMin / $yStep) * $yStep
        $yMax = [math]::Ceiling($yMax / $yStep) * $yStep
        $yFormat = Get-LabelFormat -Step $yStep

        $yLabelWidth = ($yMin.ToString($yFormat).Length, $yMax.ToString($yFormat).Length | Measure-Object -Maximum).Maximum
        # The Y axis title is drawn down the first column.
        $marginLeft = $yLabelWidth + 1 + [int][bool]$Graph.AxisY.Text
        $plotWidth = $viewport.Width - $marginLeft
        if ($plotWidth -lt 2) { return }

        if ($barCount) {
            # One graph unit per bar. BarSeries draws bar i at (i + 1) + Offset, so -0.5 centers it in slot i.
            $xMin = 0
            $cellX = $barCount / $plotWidth
            # Shorten labels to their slot so neighbours do not overlap. The full text is kept aside,
            # and a label set from outside (Text no longer what we showed) becomes the new full text.
            $slotWidth = [math]::Floor($plotWidth / $barCount) - 1
            foreach ($series in $Graph.Series) {
                if ($series -isnot [Terminal.Gui.Views.BarSeries]) { continue }
                $series.Offset = -0.5
                foreach ($bar in $series.Bars) {
                    $entry = $null
                    if (-not $script:TGBarLabels.TryGetValue($bar, [ref]$entry) -or $bar.Text -ne $entry.Shown) {
                        $entry = [PSCustomObject]@{ Full = "$($bar.Text)"; Shown = $null }
                        $script:TGBarLabels.AddOrUpdate($bar, $entry)
                    }
                    $entry.Shown = if ($entry.Full.Length -le $slotWidth) {
                        $entry.Full
                    } elseif ($slotWidth -ge 2) {
                        $entry.Full.Substring(0, $slotWidth - 1) + [char]0x2026
                    } else {
                        ''
                    }
                    if ($bar.Text -ne $entry.Shown) { $bar.Text = $entry.Shown }
                }
            }
            # Bar labels take the place of X axis labels.
            $Graph.AxisX.Increment = 0
        } else {
            $xStats = $xs | Measure-Object -Minimum -Maximum
            $xMin = $xStats.Minimum
            $xMax = $xStats.Maximum
            if ($xMax -eq $xMin) { $xMax = $xMin + 1 }

            $xLabelWidth = ($xMin.ToString('G6').Length, $xMax.ToString('G6').Length | Measure-Object -Maximum).Maximum
            $xStep = Get-NiceStep -Range ($xMax - $xMin) -Count ([math]::Floor($plotWidth / ($xLabelWidth + 4)))
            $xMin = [math]::Floor($xMin / $xStep) * $xStep
            $xMax = [math]::Ceiling($xMax / $xStep) * $xStep
            # Leave room on the right for half of the last label, which is centered on its tick.
            $cellX = ($xMax - $xMin) / ($plotWidth - 1 - [math]::Ceiling($xLabelWidth / 2))
            $xFormat = Get-LabelFormat -Step $xStep
            $Graph.AxisX.Increment = $xStep
            $Graph.AxisX.ShowLabelsEvery = 1
            $Graph.AxisX.LabelGetter = { param($tick) $tick.Value.ToString($xFormat) }.GetNewClosure()
        }
        $cellY = ($yMax - $yMin) / ($plotHeight - 1)

        $Graph.AxisY.Increment = $yStep
        $Graph.AxisY.ShowLabelsEvery = 1
        $Graph.AxisY.LabelGetter = { param($tick) $tick.Value.ToString($yFormat) }.GetNewClosure()

        # Only assign on change: the setters request a redraw, and this runs during one.
        $cellSize = [System.Drawing.PointF]::new($cellX, $cellY)
        $scrollOffset = [System.Drawing.PointF]::new($xMin, $yMin)
        if ($Graph.CellSize -ne $cellSize) { $Graph.CellSize = $cellSize }
        if ($Graph.ScrollOffset -ne $scrollOffset) { $Graph.ScrollOffset = $scrollOffset }
        if ($Graph.MarginLeft -ne $marginLeft) { $Graph.MarginLeft = [uint32]$marginLeft }
        if ($Graph.MarginBottom -ne $marginBottom) { $Graph.MarginBottom = [uint32]$marginBottom }
    }
}
