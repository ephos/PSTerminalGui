# Runs real application loops with the ansi driver. Tagged so they can be skipped: Invoke-Pester -ExcludeTag Integration
BeforeAll {
    Import-Module $PSScriptRoot/../src/PSTerminalGui.psd1 -Force
}

Describe 'Start-TGApplication' -Tag 'Integration' {
    It 'runs button handlers with $this and $_' {
        $log = [System.Collections.Generic.List[string]]::new()
        $window = New-TGWindow 'w' {
            New-TGButton 'Go' -Id go -OnAccept { $log.Add("$($this.Text)|$($_.GetType().Name)") }
        }
        $null = Add-TGTimeout 50 {
            $null = (Get-TGView go).InvokeCommand([Terminal.Gui.Input.Command]::Accept)
            Stop-TGApplication
        }
        $window | Start-TGApplication -Driver ansi
        $log | Should -Be 'Go|CommandEventArgs'
    }

    It 'returns the index of the dialog button that was pressed' {
        $dialog = New-TGDialog 'd' -Button Yes, No
        $null = Add-TGTimeout 50 { $null = $dialog.Buttons[1].InvokeCommand([Terminal.Gui.Input.Command]::Accept) }
        $dialog | Start-TGApplication -Driver ansi | Should -Be 1
    }

    It 'rethrows handler errors after restoring the terminal' {
        $null = Add-TGTimeout 50 { throw 'boom' }
        { New-TGWindow 'w' | Start-TGApplication -Driver ansi } | Should -Throw 'boom'
    }

    It 'repeats timeouts that return $true and stops the others' {
        $script:ticks = 0
        $null = Add-TGTimeout 20 { $script:ticks++; $script:ticks -lt 3 }
        $null = Add-TGTimeout 300 { Stop-TGApplication }
        New-TGWindow 'w' | Start-TGApplication -Driver ansi
        $script:ticks | Should -Be 3
    }

    It 'removes a pending timeout' {
        $script:fired = $false
        Add-TGTimeout 20 { $script:fired = $true } | Remove-TGTimeout
        $null = Add-TGTimeout 100 { Stop-TGApplication }
        New-TGWindow 'w' | Start-TGApplication -Driver ansi
        $script:fired | Should -BeFalse
    }

    It 'calls -OnFinished when a wizard is finished' {
        $script:finished = $false
        $wizard = New-TGWizard 'w' { New-TGWizardStep 'one'; New-TGWizardStep 'two' } -OnFinished { $script:finished = $true }
        $null = Add-TGTimeout 50 {
            $next = $wizard.Buttons | Where-Object IsDefault
            $null = $next.InvokeCommand([Terminal.Gui.Input.Command]::Accept)
            $null = $next.InvokeCommand([Terminal.Gui.Input.Command]::Accept)
        }
        $null = $wizard | Start-TGApplication -Driver ansi
        $script:finished | Should -BeTrue
    }
}

Describe 'Get-TGSelectedItem' -Tag 'Integration' {
    It 'returns the original object for list and table selections' {
        $items = 1..5 | ForEach-Object { [PSCustomObject]@{ Name = "item$_"; Value = $_ } }
        $window = New-TGWindow 'w' {
            $items | New-TGListView -Id list -Height 5
            $items | New-TGTableView -Id table -Y 6 -Height 5
        }
        $null = Add-TGTimeout 50 {
            (Get-TGView list).SelectedItem = 2
            (Get-TGView table).Value = [Terminal.Gui.Views.TableSelection]::new([System.Drawing.Point]::new(0, 3))
            $script:list = Get-TGSelectedItem list
            $script:table = Get-TGSelectedItem table
            Stop-TGApplication
        }
        $window | Start-TGApplication -Driver ansi
        $script:list.Name | Should -Be 'item3'
        $script:table.Name | Should -Be 'item4'
    }
}

Describe 'Invoke-TGOnUIThread' -Tag 'Integration' {
    It 'runs work queued from a thread job on the UI thread' {
        $window = New-TGWindow 'w' { New-TGProgressBar -Id jobprogress }
        $modulePath = (Resolve-Path "$PSScriptRoot/../src/PSTerminalGui.psd1").Path
        $job = Start-ThreadJob {
            Import-Module $using:modulePath
            1..4 | ForEach-Object { Invoke-TGOnUIThread { param($step) (Get-TGView jobprogress).Fraction = $step / 4 } -ArgumentList $_ }
            Invoke-TGOnUIThread { Stop-TGApplication }
        }
        $window | Start-TGApplication -Driver ansi
        $job | Wait-Job | Remove-Job
        (Get-TGView jobprogress).Fraction | Should -Be 1
    }
}

Describe 'New-TGGraphView' -Tag 'Integration' {
    It 'fits the scale to the data and draws bar labels' {
        $window = New-TGWindow 'w' {
            [PSCustomObject]@{ Name = 'alpha'; N = 3 }, [PSCustomObject]@{ Name = 'beta'; N = 12 } |
                New-TGGraphView -Id graph -Value N
        }
        $null = Add-TGTimeout 100 {
            $script:screen = (& (Get-Module PSTerminalGui) { $script:TGApp }).Driver.ToString()
            Stop-TGApplication
        }
        $window | Start-TGApplication -Driver ansi
        $graph = Get-TGView graph
        $graph.ScrollOffset.Y | Should -Be 0
        $graph.CellSize.X | Should -BeLessThan 1
        $script:screen | Should -Match 'alpha'
        $script:screen | Should -Match 'beta'
    }
}

Describe 'Get-TGApplication guard' {
    It 'Stop-TGApplication throws when nothing is running' {
        { Stop-TGApplication } | Should -Throw '*No Terminal.Gui application is running*'
    }
}

Describe 'Install-TGDependency' {
    It 'reports an existing install instead of restoring again' {
        Install-TGDependency 6>&1 | Should -Match 'already installed'
    }

    It 'imports with only Install-TGDependency when Terminal.Gui cannot be restored' {
        # A dependency folder under a file cannot be created, so the restore fails before any download.
        $blocker = New-TemporaryFile
        $manifest = (Resolve-Path "$PSScriptRoot/../src/PSTerminalGui.psd1").Path
        $env:PSTERMINALGUI_DEPENDENCY_PATH = Join-Path -Path $blocker -ChildPath 'deps'
        try {
            $commands = pwsh -NoProfile -Command "Import-Module '$manifest' 3>`$null; (Get-Command -Module PSTerminalGui).Name"
        } finally {
            Remove-Item -Path Env:PSTERMINALGUI_DEPENDENCY_PATH
            Remove-Item -Path $blocker
        }
        $commands | Should -Be 'Install-TGDependency'
    }
}
