# Markdown viewer. Fenced code blocks (```powershell, ```json, ...) are syntax highlighted.
# Usage: ./10-MarkdownViewer.ps1 [-Path some.md]
param (
    [string]
    $Path = "$PSScriptRoot/../Readme.md"
)
Import-Module $PSScriptRoot/../src/PSTerminalGui.psd1

TGWindow "$(Split-Path -Path $Path -Leaf) (Esc quits)" {
    TGMarkdown -Path $Path -Width Fill -Height Fill
} | Start-TGApplication
