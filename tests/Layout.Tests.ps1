BeforeAll {
    Import-Module $PSScriptRoot/../src/PSTerminalGui.psd1 -Force
}

Describe 'New-TGPos' {
    It 'converts <Value> to <Expected>' -ForEach @(
        @{ Value = 5; Expected = 'Absolute(5)' }
        @{ Value = '5'; Expected = 'Absolute(5)' }
        @{ Value = 'Center'; Expected = 'Center' }
        @{ Value = '25%'; Expected = 'Percent(25)' }
        @{ Value = 'AnchorEnd'; Expected = 'AnchorEnd' }
        @{ Value = 'AnchorEnd(3)'; Expected = 'AnchorEnd(3)' }
        @{ Value = 'Center+2'; Expected = 'Combine(Center+Absolute(2))' }
        @{ Value = '50%-1'; Expected = 'Combine(Percent(50)-Absolute(1))' }
    ) {
        (New-TGPos $Value).ToString() | Should -Be $Expected
    }

    It 'passes a Pos object through unchanged' {
        $pos = [Terminal.Gui.ViewBase.Pos]::Center()
        New-TGPos $pos | Should -Be $pos
    }

    It 'builds a position relative to another view' {
        $label = New-TGLabel 'Name:'
        (New-TGPos -Right $label -Offset 1).ToString() | Should -Match 'Side=Right.*Absolute\(1\)'
    }

    It 'throws on an unknown value' {
        { New-TGPos 'Middle' } | Should -Throw '*Cannot convert*'
    }
}

Describe 'New-TGDim' {
    It 'converts <Value> to <Expected>' -ForEach @(
        @{ Value = 10; Expected = 'Absolute(10)' }
        @{ Value = 'Fill'; Expected = 'Fill(Absolute(0))' }
        @{ Value = 'Fill-2'; Expected = 'Fill(Absolute(2))' }
        @{ Value = 'Auto'; Expected = 'Auto(Auto,,)' }
        @{ Value = '50%'; Expected = 'Percent(50,ContentSize)' }
        @{ Value = '50%+1'; Expected = 'Combine(Percent(50,ContentSize)+Absolute(1))' }
    ) {
        (New-TGDim $Value).ToString() | Should -Be $Expected
    }

    It 'builds a size relative to another view' {
        $label = New-TGLabel 'Name:'
        (New-TGDim -WidthOf $label).ToString() | Should -Match 'Width'
    }

    It 'throws on an unknown value' {
        { New-TGDim 'Huge' } | Should -Throw '*Cannot convert*'
    }
}
