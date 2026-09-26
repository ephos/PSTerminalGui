# A tour of colors, text styles, borders, shadows, and theme schemes, one tab each.
Import-Module $PSScriptRoot/../src/PSTerminalGui.psd1

function Update-Preview {
    (Get-TGView preview) | Set-TGStyle -Foreground (Get-TGView fg).SelectedColor -Background (Get-TGView bg).SelectedColor
}

TGWindow 'Styles (Esc quits)' {
    TGTabs -Width Fill -Height Fill {

        TGTab '_Colors' {
            # One swatch per standard terminal color.
            $colors = [Enum]::GetNames([Terminal.Gui.Drawing.ColorName16])
            for ($i = 0; $i -lt $colors.Count; $i++) {
                $foreground = if ($i -lt 7) { 'White' } else { 'Black' }
                TGLabel (' {0,-14}' -f $colors[$i]) -X (($i % 4) * 18 + 1) -Y ([math]::Floor($i / 4) * 2 + 1) |
                    Set-TGStyle -Foreground $foreground -Background $colors[$i] -PassThru
            }
            TGLabel 'Hex colors work too:' -X 1 -Y 10
            TGLabel ' #FF8800 ' -X 23 -Y 10 | Set-TGStyle -Foreground Black -Background '#FF8800' -PassThru
            TGLabel ' #7B2FBE ' -X 33 -Y 10 | Set-TGStyle -Foreground White -Background '#7B2FBE' -PassThru
        }

        TGTab '_Text' {
            $y = 1
            foreach ($style in 'Bold', 'Faint', 'Italic', 'Underline', 'Strikethrough', 'Reverse', 'Blink', 'Bold, Italic, Underline') {
                TGLabel "This text is $style" -X 1 -Y $y | Set-TGStyle -TextStyle $style -PassThru
                $y += 2
            }
        }

        TGTab '_Borders' {
            $borders = 'Single', 'Double', 'Heavy', 'Rounded', 'Dashed', 'Dotted', 'HeavyDashed', 'RoundedDotted'
            for ($i = 0; $i -lt $borders.Count; $i++) {
                TGFrameView $borders[$i] -X (($i % 4) * 20 + 1) -Y ([math]::Floor($i / 4) * 5 + 1) -Width 18 -Height 4 {
                    TGLabel $borders[$i] -X Center -Y Center
                } | Set-TGStyle -BorderStyle $borders[$i] -PassThru
            }
            TGButton 'Opaque shadow' -X 1 -Y 12 | Set-TGStyle -Shadow Opaque -PassThru
            TGButton 'Transparent shadow' -X 22 -Y 12 | Set-TGStyle -Shadow Transparent -PassThru

            # Titles can be styled separately from the border, focused or not.
            TGFrameView 'Cyan title' -X 1 -Y 15 -Width 24 -Height 3 | Set-TGStyle -TitleForeground BrightCyan -TitleStyle Bold -PassThru
            TGFrameView 'Alert title' -X 27 -Y 15 -Width 24 -Height 3 | Set-TGStyle -TitleForeground White -TitleBackground Red -PassThru
            TGFrameView 'Italic title' -X 53 -Y 15 -Width 24 -Height 3 | Set-TGStyle -TitleForeground '#FF8800' -TitleStyle Italic -PassThru
        }

        TGTab '_Schemes' {
            TGLabel 'Named schemes follow the active theme, so they suit any terminal.' -X 1 -Y 1
            $y = 3
            foreach ($scheme in 'Base', 'Accent', 'Dialog', 'Menu', 'Error') {
                TGFrameView $scheme -X 1 -Y $y -Width 50 -Height 3 {
                    TGLabel "Set-TGStyle -Scheme $scheme"
                    TGButton 'Button' -X AnchorEnd
                } | Set-TGStyle -Scheme $scheme -PassThru
                $y += 3
            }
        }

        TGTab 'Color _mixer' {
            TGLabel '   The quick brown fox jumps over the lazy dog.   ' -Id preview -X Center -Y 1 |
                Set-TGStyle -Foreground White -Background Blue -TextStyle Bold -PassThru
            TGLabel 'Foreground' -X 1 -Y 3
            TGColorPicker 'White' -Id fg -X 1 -Y 4 -Width Fill-1 -OnValueChanged { Update-Preview }
            TGLabel 'Background' -X 1 -Y 9
            TGColorPicker 'Blue' -Id bg -X 1 -Y 10 -Width Fill-1 -OnValueChanged { Update-Preview }
        }
    }
} | Set-TGStyle -TitleForeground BrightYellow -TitleStyle Bold -PassThru | Start-TGApplication
