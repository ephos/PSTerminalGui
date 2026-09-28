function New-TGGraphView {
    <#
    .SYNOPSIS
    Creates a bar, scatter, or line chart from pipeline data.

    .DESCRIPTION
    Each input object becomes one bar or point. -Value picks the number to plot (the object itself when
    omitted), -Label the bar text, and -XValue the horizontal position of scatter and line points
    (the input position when omitted).

    The chart scales itself to fit its data and size every time it is drawn. To update it, change the
    data on the view (the BarSeries in .Series for bars, the ScatterSeries in .Series for scatter, or
    the PathAnnotation in .Annotations for a line), then call .SetNeedsDraw().

    Width and Height default to 'Fill'.

    .PARAMETER InputObject
    Objects or numbers to chart.

    .PARAMETER Type
    Bar (default), Scatter, or Line.

    .PARAMETER Value
    Property name, or scriptblock with the object in $_, giving the number to plot.

    .PARAMETER Label
    Bar charts: property name, or scriptblock with the object in $_, giving the text under each bar.
    Defaults to the object's Name, when it has one.

    .PARAMETER XValue
    Scatter and line charts: property name, or scriptblock with the object in $_, giving the horizontal position.

    .PARAMETER Color
    Bar, point, or line color: a name like 'BrightGreen' or a hex value like '#FF8800'.

    .PARAMETER Fill
    Character used to draw bars or points. Defaults to a full block for bars and a dot for points and lines.

    .PARAMETER XAxisTitle
    Text shown along the horizontal axis.

    .PARAMETER YAxisTitle
    Text shown along the vertical axis.

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
    Hashtable of any other GraphView properties to set.

    .EXAMPLE
    Get-Process | Sort-Object WorkingSet64 -Descending | Select-Object -First 8 |
        TGGraphView -Value { $_.WorkingSet64 / 1MB } -YAxisTitle 'MB' -Color BrightCyan

    .EXAMPLE
    1..40 | TGGraphView -Type Line -Value { [math]::Sin($_ / 5) } -Color BrightGreen

    .EXAMPLE
    $points | TGGraphView -Type Scatter -XValue Height -Value Weight -Fill 'x'
    #>
    [CmdletBinding()]
    [Alias('TGGraphView')]
    [OutputType([Terminal.Gui.Views.GraphView])]
    param (
        [Parameter(Mandatory=$false, Position=0, ValueFromPipeline=$true)]
        [object[]]
        $InputObject,

        [Parameter(Mandatory=$false)]
        [ValidateSet('Bar', 'Scatter', 'Line')]
        [string]
        $Type = 'Bar',

        [Parameter(Mandatory=$false)]
        [object]
        $Value,

        [Parameter(Mandatory=$false)]
        [object]
        $Label,

        [Parameter(Mandatory=$false)]
        [object]
        $XValue,

        [Parameter(Mandatory=$false)]
        [Terminal.Gui.Drawing.Color]
        $Color,

        [Parameter(Mandatory=$false)]
        [ValidateLength(1, 2)]
        [string]
        $Fill,

        [Parameter(Mandatory=$false)]
        [string]
        $XAxisTitle,

        [Parameter(Mandatory=$false)]
        [string]
        $YAxisTitle,

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
        $Width = 'Fill',

        [Parameter(Mandatory=$false)]
        [object]
        $Height = 'Fill',

        [Parameter(Mandatory=$false)]
        [hashtable]
        $Property
    )

    begin {
        $items = [System.Collections.Generic.List[object]]::new()
    }

    process {
        foreach ($item in $InputObject) { $items.Add($item) }
    }

    end {
        $view = [Terminal.Gui.Views.GraphView]::new()

        $fillText = if ($Fill) { $Fill } elseif ($Type -eq 'Bar') { [string][char]0x2588 } else { [string][char]0x2022 }
        $rune = [System.Text.Rune]::GetRuneAt($fillText, 0)
        $attribute = $null
        if ($PSBoundParameters.ContainsKey('Color')) {
            # Attribute's constructors take 'in' parameters, which PowerShell passes as [ref].
            $background = $view.GetScheme().Normal.Background
            $attribute = [Terminal.Gui.Drawing.Attribute]::new([ref]$Color, [ref]$background)
        }
        $cell = if ($attribute) {
            [Terminal.Gui.Views.GraphCellToRender]::new($rune, [Terminal.Gui.Drawing.Attribute]$attribute)
        } else {
            [Terminal.Gui.Views.GraphCellToRender]::new($rune)
        }

        switch ($Type) {
            'Bar' {
                $series = [Terminal.Gui.Views.BarSeries]::new()
                foreach ($item in $items) {
                    $text = if ($Label -or ($item -isnot [ValueType] -and $item -isnot [string])) { Get-TGItemLabel -InputObject $item -Display $Label } else { '' }
                    $series.Bars.Add([Terminal.Gui.Views.BarSeriesBar]::new($text, $cell, (Get-TGItemValue -InputObject $item -Selector $Value)))
                }
                $view.Series.Add($series)
            }
            'Scatter' {
                $series = [Terminal.Gui.Views.ScatterSeries]::new()
                $series.Fill = $cell
                for ($i = 0; $i -lt $items.Count; $i++) {
                    $pointX = if ($PSBoundParameters.ContainsKey('XValue')) { Get-TGItemValue -InputObject $items[$i] -Selector $XValue } else { $i }
                    $series.Points.Add([System.Drawing.PointF]::new($pointX, (Get-TGItemValue -InputObject $items[$i] -Selector $Value)))
                }
                $view.Series.Add($series)
            }
            'Line' {
                $path = [Terminal.Gui.Views.PathAnnotation]::new()
                $path.LineRune = $rune
                if ($attribute) { $path.LineColor = [Terminal.Gui.Drawing.Attribute]$attribute }
                for ($i = 0; $i -lt $items.Count; $i++) {
                    $pointX = if ($PSBoundParameters.ContainsKey('XValue')) { Get-TGItemValue -InputObject $items[$i] -Selector $XValue } else { $i }
                    $path.Points.Add([System.Drawing.PointF]::new($pointX, (Get-TGItemValue -InputObject $items[$i] -Selector $Value)))
                }
                $view.Annotations.Add($path)
            }
        }

        if ($XAxisTitle) { $view.AxisX.Text = $XAxisTitle }
        if ($YAxisTitle) { $view.AxisY.Text = $YAxisTitle }

        # Common parameters with the Fill defaults, which $PSBoundParameters does not include.
        $common = @{} + $PSBoundParameters
        $common.Width = $Width
        $common.Height = $Height
        Set-TGViewCommon -View $view -BoundParameters $common

        $fitScale = (Get-Command -Name Update-TGGraphScale).ScriptBlock
        Register-TGEventInternal -InputObject $view -EventName 'ClearingViewport' -Action { & $fitScale -Graph $this }.GetNewClosure()
        $view
    }
}
