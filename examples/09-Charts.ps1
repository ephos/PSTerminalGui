# Live charts: memory per process as bars, total CPU as a rolling line, and a scatter of memory vs. threads.
Import-Module $PSScriptRoot/../src/PSTerminalGui.psd1

function Get-TopMemory {
    Get-Process | Sort-Object -Property WorkingSet64 -Descending | Select-Object -First 10 -Property Name,
        @{ Name = 'MB'; Expression = { [math]::Round($_.WorkingSet64 / 1MB) } }
}

# Total CPU time of all processes, used to turn two samples into a percentage.
function Get-CpuSeconds {
    (Get-Process | Measure-Object -Property CPU -Sum).Sum
}

$script:cpuSamples = [System.Collections.Generic.List[double]]::new()
$script:lastCpu = Get-CpuSeconds
$interval = 1000

# Charts refit to their data on every draw, so updating one is: change the data, then SetNeedsDraw().
$null = Add-TGTimeout $interval {
    $cpu = Get-CpuSeconds
    $percent = [math]::Max(0, ($cpu - $script:lastCpu) / ($interval / 1000) / [Environment]::ProcessorCount * 100)
    $script:lastCpu = $cpu
    $script:cpuSamples.Add($percent)
    if ($script:cpuSamples.Count -gt 60) { $script:cpuSamples.RemoveAt(0) }

    $cpuGraph = Get-TGView cpu
    $line = $cpuGraph.Annotations[0]
    $line.Points.Clear()
    for ($i = 0; $i -lt $script:cpuSamples.Count; $i++) {
        $line.Points.Add([System.Drawing.PointF]::new($i, $script:cpuSamples[$i]))
    }
    $cpuGraph.SetNeedsDraw()

    # Or build a fresh chart from new data and take its series.
    $memoryGraph = Get-TGView memory
    $memoryGraph.Series[0] = (Get-TopMemory | New-TGGraphView -Value MB).Series[0]
    $memoryGraph.SetNeedsDraw()
    $true
}

TGWindow 'Charts (Esc quits)' {
    TGTabs -Width Fill -Height Fill {
        TGTab '_Memory' {
            Get-TopMemory | TGGraphView -Id memory -Value MB -YAxisTitle 'MB' -Color BrightCyan
        }
        TGTab '_CPU' {
            0 | TGGraphView -Id cpu -Type Line -YAxisTitle '% CPU' -XAxisTitle 'last 60 seconds' -Color BrightGreen
        }
        TGTab '_Threads vs memory' {
            Get-Process | TGGraphView -Type Scatter -XValue { $_.Threads.Count } -Value { $_.WorkingSet64 / 1MB } `
                -XAxisTitle 'threads' -YAxisTitle 'MB' -Fill 'o' -Color BrightYellow
        }
    }
} | Start-TGApplication
