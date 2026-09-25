# A lazy-loading file tree next to a Markdown/text preview.
Import-Module $PSScriptRoot/../src/PSTerminalGui.psd1

TGWindow 'Files (Esc quits)' {
    Get-Item -Path (Resolve-Path "$PSScriptRoot/..") |
        TGTreeView -Id tree -Width 40% -Height Fill -ChildScript {
            if ($_.PSIsContainer) { Get-ChildItem -Path $_.FullName -ErrorAction SilentlyContinue | Sort-Object -Property { -not $_.PSIsContainer }, Name }
        } -OnSelectionChanged {
            $item = $_.NewValue
            if ($item -and -not $item.PSIsContainer -and $item.Length -lt 100KB) {
                (Get-TGView preview).Text = Get-Content -Path $item.FullName -Raw
            }
        }

    TGFrameView 'Preview' -X 40% -Width Fill -Height Fill {
        TGTextView -Id preview -ReadOnly -Width Fill -Height Fill
    }
} | Start-TGApplication
