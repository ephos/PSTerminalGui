# A small form: text input, checkbox, options, and a button that reads them back.
Import-Module $PSScriptRoot/../src/PSTerminalGui.psd1

TGWindow 'Demo (Esc quits)' {
    TGLabel '_Name:' -X 1 -Y 1
    TGTextField -Id name -X 10 -Y 1 -Width 30

    TGLabel 'Size:' -X 1 -Y 3
    TGOptionSelector 'Small', 'Medium', 'Large' -Id size -X 10 -Y 3 -Value 1

    TGCheckBox '_Extra cheese' -Id cheese -X 10 -Y 7

    TGButton '_Greet' -X Center -Y 9 -IsDefault -OnAccept {
        $size = (Get-TGView size).Labels[(Get-TGView size).Value]
        $cheese = if ((Get-TGView cheese).Value -eq 'Checked') { 'with' } else { 'without' }
        Show-TGMessageBox -Title 'Order' -Message "Hello $((Get-TGView name).Text), one $size pizza $cheese extra cheese."
    }
} | Start-TGApplication
