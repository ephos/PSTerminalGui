# Smallest possible app. Esc quits.
Import-Module $PSScriptRoot/../src/PSTerminalGui.psd1

TGWindow 'Hello (Esc quits)' {
    TGLabel 'Hello from PowerShell!' -X Center -Y Center
} | Start-TGApplication
