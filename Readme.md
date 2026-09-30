# PSTerminalGui

> [!WARNING]
> This module is vibe coded, largely written with AI assistance, and may contain errors. Use it at your own risk.

## Overview

A PowerShell module for building terminal user interfaces (TUIs), wrapping [Terminal.Gui v2](https://github.com/tui-cs/Terminal.Gui).

```powershell
TGWindow 'Demo (Esc quits)' {
    TGLabel 'Name:' -X 1 -Y 1
    TGTextField -Id name -X 8 -Y 1 -Width 30
    TGButton 'Greet' -X Center -Y 3 -OnAccept {
        Show-TGMessageBox -Title Hi -Message "Hello $((Get-TGView name).Text)"
    }
} | Start-TGApplication
```

Tested on.

| OS | PowerShell Version | Terminal.Gui |
| --- | --- | --- |
| Arch <span style="color:cyan">󰣇 </span>Linux 🐧 | 7.6.4 | 2.5.0 |

Requires PowerShell 7.6+ (Terminal.Gui 2.5 targets .NET 10).

## Getting Started

```powershell
Import-Module ./src/PSTerminalGui.psd1
./examples/01-HelloWorld.ps1
```

The Terminal.Gui assemblies are not committed or bundled. The first import downloads them from nuget.org (no .NET SDK needed), together with the native libraries for your OS and CPU, into a per-user folder:

| OS | Folder |
| --- | --- |
| Linux | `~/.local/share/PSTerminalGui/<version>` |
| macOS | `~/Library/Application Support/PSTerminalGui/<version>` |
| Windows | `%LOCALAPPDATA%\PSTerminalGui\<version>` |

Set `$env:PSTERMINALGUI_DEPENDENCY_PATH` to use another base folder. Run `Install-TGDependency -Force` to repair an install.

If the download fails (offline, proxy), the module still imports but only `Install-TGDependency` is available. Fix the cause, run `Install-TGDependency`, then `Import-Module PSTerminalGui -Force`.

## Writing UIs

Every `New-TG*` function has a short `TG*` alias, and containers take a scriptblock whose view output becomes their children, so the same commands work as a DSL or as plain cmdlets:

```powershell
# DSL
TGWindow 'App' { TGLabel 'Hi' } | Start-TGApplication

# Cmdlets
$window = New-TGWindow -Title 'App'
New-TGLabel -Text 'Hi' | Add-TGView -Parent $window
Start-TGApplication -View $window
```

### Layout

Every view takes `-X`, `-Y`, `-Width`, and `-Height`.

| Parameter | Accepts |
| --- | --- |
| `-X` / `-Y` | `5`, `'Center'`, `'25%'`, `'AnchorEnd'`, `'AnchorEnd(3)'`, with optional offset (`'Center+2'`), or `New-TGPos -Right $view -Offset 1` |
| `-Width` / `-Height` | `20`, `'Fill'`, `'Fill-2'`, `'Auto'`, `'50%'`, with optional offset, or `New-TGDim -WidthOf $view` / `-FillTo $view` |

Anything else can be set with `-Property @{ Name = Value }`.

### Events

Common events have parameters: `-OnAccept`, `-OnTextChanged`, `-OnValueChanged`, `-OnSelectionChanged`. Any other .NET event can be hooked with `Register-TGEvent` (with tab completion for event names). In a handler, `$this` is the view and `$_` the event args.

Give views an `-Id` and look them up with `Get-TGView`. For list, table, and tree views, `Get-TGSelectedItem` returns the original PowerShell objects, not the displayed text.

### Background work

Views may only be changed on the UI thread. From `Start-ThreadJob` or other runspaces, use `Invoke-TGOnUIThread` and pass values with `-ArgumentList`. See [examples/04-BackgroundJob.ps1](examples/04-BackgroundJob.ps1).

`Add-TGTimeout` runs a scriptblock on the UI thread every N milliseconds for as long as it returns `$true`.

### Pop-ups from plain scripts

`Show-TGMessageBox`, `Show-TGOpenDialog`, and `Show-TGSaveDialog` also work outside an application:

```powershell
if ((Show-TGMessageBox 'Deploy to production?' -Button Yes, No) -eq 'Yes') { ./deploy.ps1 }
```

### Styling

`Set-TGStyle` sets colors (names like `BrightYellow` or hex like `#FF8800`), text style, border, title, and shadow. Add `-PassThru` to keep the view in a content block:

```powershell
TGLabel 'Build failed' | Set-TGStyle -Foreground BrightYellow -Background Red -TextStyle Bold -PassThru
TGFrameView 'Status' { TGLabel 'OK' } | Set-TGStyle -BorderStyle Rounded -Scheme Accent -PassThru
```

Titles can be colored on their own with `-TitleForeground`, `-TitleBackground`, and `-TitleStyle`. This works on any view with a border (windows, frames, dialogs), whether it has focus or not:

```powershell
TGWindow 'Dashboard' {
    TGFrameView 'CPU' -Width 30 -Height 5 | Set-TGStyle -TitleForeground BrightCyan -TitleStyle Bold -PassThru
    TGFrameView 'Alerts' -X 31 -Width 30 -Height 5 | Set-TGStyle -TitleForeground White -TitleBackground Red -PassThru
} | Set-TGStyle -TitleForeground BrightYellow -PassThru | Start-TGApplication
```

### Charts

`New-TGGraphView` turns pipeline data into a bar, scatter, or line chart that scales itself to fit. `-Value`, `-Label`, and `-XValue` take a property name or a scriptblock:

```powershell
Get-Process | Sort-Object WorkingSet64 -Descending | Select-Object -First 8 |
    TGGraphView -Value { $_.WorkingSet64 / 1MB } -YAxisTitle 'MB' -Color BrightCyan

1..40 | TGGraphView -Type Line -Value { [math]::Sin($_ / 5) } -Color BrightGreen
```

To update a chart, change its data (the series in `.Series`, or for a line the path in `.Annotations`) and call `.SetNeedsDraw()`. See [examples/09-Charts.ps1](examples/09-Charts.ps1).

### Markdown

`New-TGMarkdown` renders Markdown with syntax highlighted code blocks on Linux, macOS, and Windows. Token colors follow the Terminal.Gui theme. Use `-NoSyntaxHighlighting` to turn highlighting off. See [examples/10-MarkdownViewer.ps1](examples/10-MarkdownViewer.ps1).

## Practical Examples

Each of these is a complete script in [examples/](examples/). The snippets below show the interesting parts.

### Pokédex: a REST API browser

[examples/06-Pokedex.ps1](examples/06-Pokedex.ps1) lists the first 151 Pokémon from [PokéAPI](https://pokeapi.co) and shows types, abilities, and base stats for the selected one.

The details request runs in a thread job, so scrolling stays smooth while it is in flight. The result is handed back to the UI thread with `Invoke-TGOnUIThread`. If the user has already moved on to another Pokémon, the stale result is dropped.

```powershell
$modulePath = (Get-Module PSTerminalGui).Path   # the thread job imports the module too
$pokemon = (Invoke-RestMethod -Uri 'https://pokeapi.co/api/v2/pokemon?limit=151').results

TGWindow 'Pokédex (Esc quits)' {
    $pokemon | TGListView -Id list -Width 22 -Height Fill -Display { $_.name } -OnSelectionChanged {
        $entry = Get-TGSelectedItem $this
        (Get-TGView name).Text = "Loading $($entry.name)..."

        $null = Start-ThreadJob -ArgumentList $modulePath, $entry.url {
            param($modulePath, $url)
            Import-Module $modulePath
            $p = Invoke-RestMethod -Uri $url
            $stats = ($p.stats | ForEach-Object {
                '{0,-16} {1,3} {2}' -f $_.stat.name, $_.base_stat, ('█' * [math]::Ceiling($_.base_stat / 10))
            }) -join "`n"

            Invoke-TGOnUIThread -ArgumentList $p.name, $stats {
                param($name, $stats)
                if ((Get-TGSelectedItem list).name -ne $name) { return }   # user moved on
                (Get-TGView name).Text = $name.ToUpper()
                (Get-TGView stats).Text = $stats
            }
        }
    }

    TGFrameView 'Details' -X 23 -Width Fill -Height Fill {
        TGLabel 'Pick a Pokémon' -Id name -X 1 | Set-TGStyle -Foreground BrightYellow -TextStyle Bold -PassThru
        TGFrameView 'Base stats' -X 1 -Y 2 -Width Fill-1 -Height 8 {
            TGLabel -Id stats -Width Fill
        } | Set-TGStyle -BorderStyle Rounded -TitleForeground BrightGreen -TitleStyle Bold -PassThru
    } | Set-TGStyle -TitleForeground BrightCyan -TitleStyle Bold -PassThru
} | Set-TGStyle -TitleForeground White -TitleBackground Red -TitleStyle Bold -PassThru | Start-TGApplication
```

### Style gallery: colors, text, borders, and schemes

[examples/07-Styles.ps1](examples/07-Styles.ps1) is a tabbed tour of what `Set-TGStyle` can do. It has swatches for the 16 standard colors plus hex colors, every text style, every border line style, styled titles, shadows, the named theme schemes, and a live color mixer built from two color pickers.

```powershell
function Update-Preview {
    Get-TGView preview | Set-TGStyle -Foreground (Get-TGView fg).SelectedColor -Background (Get-TGView bg).SelectedColor
}

TGWindow 'Styles (Esc quits)' {
    TGTabs -Width Fill -Height Fill {
        TGTab '_Text' {
            $y = 1
            foreach ($style in 'Bold', 'Faint', 'Italic', 'Underline', 'Strikethrough', 'Reverse') {
                TGLabel "This text is $style" -X 1 -Y $y | Set-TGStyle -TextStyle $style -PassThru
                $y += 2
            }
        }

        TGTab '_Borders' {
            $borders = 'Single', 'Double', 'Heavy', 'Rounded', 'Dashed', 'Dotted'
            for ($i = 0; $i -lt $borders.Count; $i++) {
                TGFrameView $borders[$i] -X (($i % 3) * 20 + 1) -Y ([math]::Floor($i / 3) * 5 + 1) -Width 18 -Height 4 {
                    TGLabel $borders[$i] -X Center -Y Center
                } | Set-TGStyle -BorderStyle $borders[$i] -PassThru
            }
        }

        TGTab 'Color _mixer' {
            TGLabel '  The quick brown fox jumps over the lazy dog.  ' -Id preview -X Center -Y 1 |
                Set-TGStyle -Foreground White -Background Blue -TextStyle Bold -PassThru
            TGColorPicker 'White' -Id fg -X 1 -Y 4 -Width Fill-1 -OnValueChanged { Update-Preview }
            TGColorPicker 'Blue' -Id bg -X 1 -Y 10 -Width Fill-1 -OnValueChanged { Update-Preview }
        }
    }
} | Start-TGApplication
```

### System dashboard: processes and systemd user services

[examples/08-SystemDashboard.ps1](examples/08-SystemDashboard.ps1) has two tabs:
- **Processes:** a table built from `Get-Process` that refreshes every 3 seconds. Press Enter on a row to stop that process, after a confirmation.
- **User services:** your `systemctl --user` services, with Start, Stop, Restart, and Logs buttons. Logs opens `journalctl` output in a dialog.

Native commands fit in naturally. `systemctl --output=json` pipes straight into `ConvertFrom-Json`, and the resulting objects go straight into a table.

```powershell
function Get-TopProcess {
    Get-Process | Sort-Object CPU -Descending | Select-Object -First 100 Id, Name,
        @{ n = 'CPU (s)'; e = { [math]::Round($_.CPU, 1) } }, @{ n = 'Memory (MB)'; e = { [math]::Round($_.WorkingSet64 / 1MB, 1) } }
}

function Get-UserService {
    systemctl --user list-units --type=service --all --output=json --no-pager | ConvertFrom-Json |
        Select-Object @{ n = 'Unit'; e = { $_.unit } }, @{ n = 'Active'; e = { $_.active } },
                      @{ n = 'State'; e = { $_.sub } }, @{ n = 'Description'; e = { $_.description } }
}

# Swap fresh rows into an existing table.
function Update-Table ([string]$Id, [object[]]$InputObject) {
    $table = Get-TGView $Id
    $fresh = $InputObject | New-TGTableView
    $table.Table = $fresh.Table
    $table.Data = $fresh.Data
}

function Invoke-ServiceAction ([string]$Action) {
    $service = Get-TGSelectedItem services
    $output = systemctl --user $Action $service.Unit 2>&1
    if ($LASTEXITCODE -ne 0) { Show-TGMessageBox -Title "systemctl $Action failed" -Message ($output -join "`n") -ErrorStyle }
    Update-Table -Id services -InputObject (Get-UserService)
}

$null = Add-TGTimeout 3000 { Update-Table -Id processes -InputObject (Get-TopProcess); $true }

TGWindow 'System dashboard (Esc quits)' {
    TGTabs -Width Fill -Height Fill-1 {
        TGTab '_Processes' {
            Get-TopProcess | TGTableView -Id processes -Width Fill -Height Fill -OnAccept {
                $process = Get-TGSelectedItem $this
                if ((Show-TGMessageBox "Stop $($process.Name) ($($process.Id))?" -Button Stop, Cancel) -eq 'Stop') {
                    Stop-Process -Id $process.Id
                }
            }
        }
        TGTab '_User services' {
            Get-UserService | TGTableView -Id services -Width Fill -Height Fill-2
            TGButton 'St_art'   -Y AnchorEnd        -OnAccept { Invoke-ServiceAction start }
            TGButton 'St_op'    -X 10 -Y AnchorEnd  -OnAccept { Invoke-ServiceAction stop }
            TGButton '_Restart' -X 19 -Y AnchorEnd  -OnAccept { Invoke-ServiceAction restart }
            TGButton '_Logs'    -X 31 -Y AnchorEnd  -OnAccept {
                $log = journalctl --user --unit (Get-TGSelectedItem services).Unit --lines 200 --no-pager | Out-String
                TGDialog 'Logs' -Width 90% -Height 80% -Button Close {
                    TGTextView $log -ReadOnly -Width Fill -Height Fill
                } | Set-TGStyle -TitleForeground BrightCyan -TitleStyle Bold -PassThru | Start-TGApplication | Out-Null
            }
        }
    }
    TGStatusBar { TGShortcut Ctrl+Q 'Quit' { Stop-TGApplication } }
} | Set-TGStyle -TitleForeground BrightGreen -TitleStyle Bold -PassThru | Start-TGApplication
```

## Commands

| Group | Commands |
| --- | --- |
| Application | `Start-TGApplication`, `Stop-TGApplication`, `Invoke-TGOnUIThread`, `Add-TGTimeout`, `Remove-TGTimeout`, `Install-TGDependency` |
| Wiring | `Add-TGView`, `Get-TGView`, `Get-TGSelectedItem`, `Register-TGEvent`, `Set-TGFocus`, `Set-TGStyle`, `New-TGPos`, `New-TGDim` |
| Containers | `New-TGWindow`, `New-TGDialog`, `New-TGFrameView`, `New-TGTabs`, `New-TGTab`, `New-TGWizard`, `New-TGWizardStep` |
| Input | `New-TGLabel`, `New-TGButton`, `New-TGTextField`, `New-TGTextView`, `New-TGCheckBox`, `New-TGOptionSelector`, `New-TGLinearSelector`, `New-TGNumericUpDown`, `New-TGDatePicker`, `New-TGColorPicker`, `New-TGDropDownList` |
| Data / display | `New-TGListView`, `New-TGTableView`, `New-TGTreeView`, `New-TGGraphView`, `New-TGProgressBar`, `New-TGSpinnerView`, `New-TGMarkdown` |
| Menus | `New-TGMenuBar`, `New-TGMenuBarItem`, `New-TGMenuItem`, `New-TGStatusBar`, `New-TGShortcut`, `New-TGPopoverMenu`, `Show-TGPopoverMenu` |
| Dialogs | `Show-TGMessageBox`, `Show-TGOpenDialog`, `Show-TGSaveDialog` |

Every command has comment-based help: `Get-Help New-TGTableView -Examples`.

## Development

```powershell
./build/Install-TGDependency.ps1 -Force            # restore Terminal.Gui into the per-user folder again (import restores it when missing)
./build/Update-TGManifest.ps1                      # sync FunctionsToExport/AliasesToExport after adding a public function
Invoke-ScriptAnalyzer -Path ./src -Recurse -Settings ./PSScriptAnalyzerSettings.psd1
Invoke-Pester -Path ./tests                        # add -ExcludeTag Integration to skip the tests that run an app loop
```

The integration tests run real application loops with the `ansi` driver, so they briefly draw to the terminal.

### Project layout

| Path | Contents |
| --- | --- |
| `src/PSTerminalGui.psm1` | Pins the Terminal.Gui version, loads its DLLs from the per-user folder (restoring them if missing), sets up module state, dot sources functions, formats, and completers |
| `src/PSTerminalGui.psd1` | Manifest with explicit `FunctionsToExport` / `AliasesToExport` (keep in sync with `Update-TGManifest.ps1`) |
| `src/Functions/Public/` | One exported command per file |
| `src/Functions/Private/` | Shared helpers, e.g. `Set-TGViewCommon` (`-Id`, layout, `-Property`) and `ConvertTo-TGPos` / `ConvertTo-TGDim` (parse `'Center+2'`, `'Fill-1'`, `'50%'`) |
| `src/Format/`, `src/Completers/` | Output formatting and the `Register-TGEvent` event name completer |
| `build/` | Dev wrappers: dependency restore and manifest sync |
| `examples/` | Runnable demo scripts |
| `tests/` | Pester tests: `Application`, `Layout`, `Manifest`, `Views` |

### How it works

- **Assembly loading:** the `.psm1` loads every managed DLL in the dependency folder before dot sourcing anything, because scripts that reference `[Terminal.Gui.*]` types fail to parse otherwise. Native libraries (such as `libonigwrap`, for syntax highlighting) sit in the same folder, where .NET finds them.
- **View registry:** `-Id` stores the view in a module-scoped table, which is what `Get-TGView` and `Get-TGSelectedItem <id>` read.
- **Application loop:** `Start-TGApplication` creates and initializes the application, or runs the view as a nested modal when one is already running. Exceptions thrown in event handlers stop the app and are rethrown once the terminal is restored.
- **Cross-thread work:** `Invoke-TGOnUIThread` puts work on a queue stored on the AppDomain, so thread jobs in other runspaces can reach it. The UI thread drains it every 50 ms.
- **Timeouts:** `Add-TGTimeout` calls made before the app starts are queued and registered when it does.

### CI

Pushes to branches and PRs to `main` run `.github/workflows/validate-wf.yml` on Linux, macOS, and Windows: restore dependencies and run Pester (JUnit report). The Linux job also runs PSScriptAnalyzer, the Integration tests, and a check that `ModuleVersion` in the manifest is higher than on `main`. Bump the version in `src/PSTerminalGui.psd1` in every PR.

## Current Known Issues

- Syntax highlighting has only been verified on Linux x64. The dependency script restores the native `libonigwrap` for macOS (x64, arm64) and Windows (x64, x86, arm64) too, and CI checks those platforms.
- Charts draw one series each. Add more with `.Series.Add()` / `.Annotations.Add()`; the scale fits all of them.

## To-Do

- [x] Wrap `GraphView` (bar/scatter/line series from pipeline data)
- [x] Restore native runtime libraries for TextMate syntax highlighting
