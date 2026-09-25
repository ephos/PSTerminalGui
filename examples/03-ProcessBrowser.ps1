# A process table with a menu, a status bar, and a detail pop-up on Enter.
Import-Module $PSScriptRoot/../src/PSTerminalGui.psd1

function Update-ProcessTable {
    $table = Get-TGView processes
    $fresh = Get-Process | Sort-Object -Property CPU -Descending | Select-Object -First 200 | New-TGTableView -Column Id, Name, CPU, WorkingSet64
    $table.Table = $fresh.Table
    $table.Data = $fresh.Data
}

TGWindow 'Processes' {
    TGMenuBar {
        TGMenuBarItem '_File' {
            TGMenuItem '_Refresh' { Update-ProcessTable } -Key F5
            TGMenuItem '_Quit' { Stop-TGApplication } -Key Ctrl+Q
        }
    }

    Get-Process | Sort-Object -Property CPU -Descending | Select-Object -First 200 |
        TGTableView -Id processes -Column Id, Name, CPU, WorkingSet64 -Y 1 -Width Fill -Height Fill-1 -OnAccept {
            $process = Get-TGSelectedItem $this
            Show-TGMessageBox -Title $process.Name -Message ($process | Format-List -Property Id, Path, StartTime | Out-String).Trim()
        }

    TGStatusBar {
        TGShortcut F5 'Refresh' { Update-ProcessTable }
        TGShortcut Ctrl+Q 'Quit' { Stop-TGApplication }
    }
} | Start-TGApplication
