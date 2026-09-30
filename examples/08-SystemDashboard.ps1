# A local system dashboard: live processes from Get-Process, and your systemd user services from systemctl.
Import-Module $PSScriptRoot/../src/PSTerminalGui.psd1

function Get-TopProcess {
    Get-Process | Sort-Object -Property CPU -Descending | Select-Object -First 100 -Property Id, Name,
        @{ Name = 'CPU (s)'; Expression = { [math]::Round($_.CPU, 1) } },
        @{ Name = 'Memory (MB)'; Expression = { [math]::Round($_.WorkingSet64 / 1MB, 1) } },
        @{ Name = 'Threads'; Expression = { $_.Threads.Count } }
}

function Get-UserService {
    # systemd 246+ can emit JSON, so no text parsing is needed.
    systemctl --user list-units --type=service --all --output=json --no-pager | ConvertFrom-Json |
        Sort-Object -Property unit | Select-Object -Property @{ Name = 'Unit'; Expression = { $_.unit } },
            @{ Name = 'Active'; Expression = { $_.active } }, @{ Name = 'State'; Expression = { $_.sub } },
            @{ Name = 'Description'; Expression = { $_.description } }
}

# Swap new rows into an existing table, keeping the selected row where it was.
function Update-Table ([string]$Id, [object[]]$InputObject) {
    $table = Get-TGView $Id
    $selection = $table.Value
    $fresh = $InputObject | New-TGTableView
    $table.Table = $fresh.Table
    $table.Data = $fresh.Data
    if ($selection -and $selection.SelectedCell.Y -lt $fresh.Data.Count) { $table.Value = $selection }
}

function Invoke-ServiceAction ([string]$Action) {
    $service = Get-TGSelectedItem services
    if (-not $service) { return }
    $output = systemctl --user $Action $service.Unit 2>&1
    if ($LASTEXITCODE -ne 0) {
        Show-TGMessageBox -Title "systemctl $Action failed" -Message ($output -join "`n") -ErrorStyle
    }
    Update-Table -Id services -InputObject (Get-UserService)
}

$hasSystemd = [bool](Get-Command -Name systemctl -ErrorAction SilentlyContinue)

# Refresh the process list every 3 seconds. Registered now, starts with the application.
$null = Add-TGTimeout 3000 { Update-Table -Id processes -InputObject (Get-TopProcess); $true }

TGWindow 'System dashboard (Esc quits)' {
    TGTabs -Width Fill -Height Fill-1 {

        TGTab '_Processes' {
            Get-TopProcess | TGTableView -Id processes -Width Fill -Height Fill -OnAccept {
                $process = Get-TGSelectedItem $this
                $answer = Show-TGMessageBox -Title 'Stop process' -Message "Stop $($process.Name) ($($process.Id))?" -Button Stop, Cancel
                if ($answer -eq 'Stop') {
                    try {
                        Stop-Process -Id $process.Id -ErrorAction Stop
                    } catch {
                        Show-TGMessageBox -Title 'Stop-Process failed' -Message $_.Exception.Message -ErrorStyle
                    }
                    Update-Table -Id processes -InputObject (Get-TopProcess)
                }
            }
        }

        TGTab '_User services' {
            if (-not $hasSystemd) {
                TGLabel 'systemctl was not found. This tab needs a Linux system running systemd.' -X Center -Y Center
                return
            }

            Get-UserService | TGTableView -Id services -Width Fill -Height Fill-2
            TGButton 'St_art' -Y AnchorEnd -OnAccept { Invoke-ServiceAction start }
            TGButton 'St_op' -X 10 -Y AnchorEnd -OnAccept { Invoke-ServiceAction stop }
            TGButton '_Restart' -X 19 -Y AnchorEnd -OnAccept { Invoke-ServiceAction restart }
            TGButton '_Logs' -X 31 -Y AnchorEnd -OnAccept {
                $service = Get-TGSelectedItem services
                if (-not $service) { return }
                $log = journalctl --user --unit $service.Unit --lines 200 --no-pager 2>&1 | Out-String
                TGDialog "Logs: $($service.Unit)" -Width 90% -Height 80% -Button Close {
                    TGTextView $log -ReadOnly -Width Fill -Height Fill
                } | Set-TGStyle -TitleForeground BrightCyan -TitleStyle Bold -PassThru | Start-TGApplication | Out-Null
            }
        }
    }

    TGStatusBar {
        TGShortcut F5 'Refresh' {
            Update-Table -Id processes -InputObject (Get-TopProcess)
            if ($hasSystemd) { Update-Table -Id services -InputObject (Get-UserService) }
        }
        TGShortcut Ctrl+Q 'Quit' { Stop-TGApplication }
    }
} | Set-TGStyle -TitleForeground BrightGreen -TitleStyle Bold -PassThru | Start-TGApplication
