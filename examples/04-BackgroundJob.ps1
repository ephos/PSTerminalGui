# Background work in a thread job, reporting progress to the UI with Invoke-TGOnUIThread.
Import-Module $PSScriptRoot/../src/PSTerminalGui.psd1

$modulePath = (Resolve-Path -Path "$PSScriptRoot/../src/PSTerminalGui.psd1").Path

TGWindow 'Background work (Esc quits)' {
    TGLabel 'Press Start to run a 5 second job.' -X 1 -Y 1 -Id status
    TGProgressBar -Id progress -X 1 -Y 3 -Width Fill-1 -Style Continuous
    TGButton '_Start' -X 1 -Y 5 -OnAccept {
        (Get-TGView status).Text = 'Working...'
        $null = Start-ThreadJob -ArgumentList $modulePath {
            param($modulePath)
            Import-Module $modulePath
            foreach ($step in 1..50) {
                Start-Sleep -Milliseconds 100
                # The scriptblock runs on the UI thread, so pass values in with -ArgumentList.
                Invoke-TGOnUIThread { param($step) (Get-TGView progress).Fraction = $step / 50 } -ArgumentList $step
            }
            Invoke-TGOnUIThread { (Get-TGView status).Text = 'Done!' }
        }
    }
} | Start-TGApplication
