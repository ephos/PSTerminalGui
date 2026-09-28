BeforeAll {
    Import-Module $PSScriptRoot/../src/PSTerminalGui.psd1 -Force
}

Describe 'View constructors' {
    It '<Command> returns <Type>' -ForEach @(
        @{ Command = { New-TGWindow 'w' }; Type = 'Terminal.Gui.Views.Window' }
        @{ Command = { New-TGDialog 'd' -Button OK }; Type = 'Terminal.Gui.Views.Dialog' }
        @{ Command = { New-TGFrameView 'f' }; Type = 'Terminal.Gui.Views.FrameView' }
        @{ Command = { New-TGTabs }; Type = 'Terminal.Gui.Views.Tabs' }
        @{ Command = { New-TGTab 't' }; Type = 'Terminal.Gui.ViewBase.View' }
        @{ Command = { New-TGWizard 'w' }; Type = 'Terminal.Gui.Views.Wizard' }
        @{ Command = { New-TGWizardStep 's' }; Type = 'Terminal.Gui.Views.WizardStep' }
        @{ Command = { New-TGLabel 'l' }; Type = 'Terminal.Gui.Views.Label' }
        @{ Command = { New-TGButton 'b' }; Type = 'Terminal.Gui.Views.Button' }
        @{ Command = { New-TGTextField 't' }; Type = 'Terminal.Gui.Views.TextField' }
        @{ Command = { New-TGTextView 't' }; Type = 'Terminal.Gui.Views.TextView' }
        @{ Command = { New-TGCheckBox 'c' }; Type = 'Terminal.Gui.Views.CheckBox' }
        @{ Command = { New-TGOptionSelector 'a', 'b' }; Type = 'Terminal.Gui.Views.OptionSelector' }
        @{ Command = { New-TGLinearSelector 'a', 'b' }; Type = 'Terminal.Gui.Views.LinearSelector' }
        @{ Command = { New-TGNumericUpDown 1 }; Type = 'Terminal.Gui.Views.NumericUpDown' }
        @{ Command = { New-TGDatePicker }; Type = 'Terminal.Gui.Views.DatePicker' }
        @{ Command = { New-TGColorPicker 'Red' }; Type = 'Terminal.Gui.Views.ColorPicker' }
        @{ Command = { New-TGDropDownList 'a', 'b' }; Type = 'Terminal.Gui.Views.DropDownList' }
        @{ Command = { New-TGListView 'a', 'b' }; Type = 'Terminal.Gui.Views.ListView' }
        @{ Command = { New-TGTableView 'a', 'b' }; Type = 'Terminal.Gui.Views.TableView' }
        @{ Command = { New-TGTreeView 'a' -ChildScript { } }; Type = 'Terminal.Gui.Views.TreeView`1' }
        @{ Command = { New-TGProgressBar 0.5 }; Type = 'Terminal.Gui.Views.ProgressBar' }
        @{ Command = { New-TGSpinnerView }; Type = 'Terminal.Gui.Views.SpinnerView' }
        @{ Command = { New-TGMarkdown '# Hi' }; Type = 'Terminal.Gui.Views.Markdown' }
        @{ Command = { New-TGGraphView 1, 2 }; Type = 'Terminal.Gui.Views.GraphView' }
        @{ Command = { New-TGMenuBar }; Type = 'Terminal.Gui.Views.MenuBar' }
        @{ Command = { New-TGMenuBarItem '_File' }; Type = 'Terminal.Gui.Views.MenuBarItem' }
        @{ Command = { New-TGMenuItem '_Open' }; Type = 'Terminal.Gui.Views.MenuItem' }
        @{ Command = { New-TGStatusBar }; Type = 'Terminal.Gui.Views.StatusBar' }
        @{ Command = { New-TGShortcut 'Ctrl+Q' 'Quit' }; Type = 'Terminal.Gui.Views.Shortcut' }
        @{ Command = { New-TGPopoverMenu }; Type = 'Terminal.Gui.Views.PopoverMenu' }
    ) {
        $view = & $Command
        # Namespace + Name, so generic types compare without their assembly-qualified arguments.
        "$($view.GetType().Namespace).$($view.GetType().Name)" | Should -Be $Type
    }

    It 'has a TG* alias for every New-TG* function' {
        foreach ($command in Get-Command -Module PSTerminalGui -Name New-TG* -CommandType Function) {
            if ($command.Name -in 'New-TGPos', 'New-TGDim') { continue }
            Get-Alias -Name ($command.Name -replace '^New-') -ErrorAction SilentlyContinue | Should -Not -BeNullOrEmpty -Because $command.Name
        }
    }
}

Describe 'Common view parameters' {
    It 'applies Id, X, Y, Width, Height, and Title' {
        $view = New-TGFrameView 'Frame' -Id frame -X 2 -Y Center -Width Fill -Height 5
        $view.Id | Should -Be 'frame'
        $view.Title | Should -Be 'Frame'
        $view.X.ToString() | Should -Be 'Absolute(2)'
        $view.Y.ToString() | Should -Be 'Center'
        $view.Width.ToString() | Should -Be 'Fill(Absolute(0))'
        $view.Height.ToString() | Should -Be 'Absolute(5)'
    }

    It 'sets other properties from -Property' {
        (New-TGLabel 'x' -Property @{ Enabled = $false }).Enabled | Should -BeFalse
    }

    It 'throws for an unknown -Property key' {
        { New-TGLabel 'x' -Property @{ NotAProperty = 1 } } | Should -Throw "*no property named 'NotAProperty'*"
    }
}

Describe 'Content blocks' {
    It 'adds view output as child views and ignores other output' {
        $window = New-TGWindow 'w' {
            New-TGLabel 'one'
            'not a view'
            New-TGButton 'two'
        }
        $window.SubViews.GetType().Name | Should -Not -BeNullOrEmpty
        @($window.SubViews | ForEach-Object { $_.GetType().Name }) | Should -Be @('Label', 'Button')
    }

    It 'nests containers' {
        $window = New-TGWindow 'w' { New-TGFrameView 'f' { New-TGLabel 'inner' -Id inner } }
        (Get-TGView -Id inner -Root $window).Text | Should -Be 'inner'
    }

    It 'adds dialog buttons' {
        (New-TGDialog 'd' -Button Yes, No).Buttons.Text | Should -Be @('Yes', 'No')
    }

    It 'adds menu items to menus' {
        $bar = New-TGMenuBar { New-TGMenuBarItem '_File' { New-TGMenuItem '_Open'; New-TGMenuItem '_Quit' -Key Ctrl+Q } }
        $bar.SubViews.Title | Should -Be '_File'
        $bar.SubViews[0].PopoverMenu.Root.SubViews.Title | Should -Be @('_Open', '_Quit')
    }

    It 'adds wizard steps' {
        $wizard = New-TGWizard 'w' { New-TGWizardStep 'one'; New-TGWizardStep 'two' }
        $wizard.GetFirstStep().Title | Should -Be 'one'
        $wizard.GetLastStep().Title | Should -Be 'two'
    }
}

Describe 'Initial values' {
    It 'sets <Name>' -ForEach @(
        @{ Name = 'TextField text'; Command = { (New-TGTextField 'abc').Text }; Expected = 'abc' }
        @{ Name = 'TextField secret'; Command = { (New-TGTextField -Secret).Secret }; Expected = $true }
        @{ Name = 'Button default'; Command = { (New-TGButton 'OK' -IsDefault).IsDefault }; Expected = $true }
        @{ Name = 'CheckBox checked'; Command = { "$((New-TGCheckBox 'c' -Checked).Value)" }; Expected = 'Checked' }
        @{ Name = 'OptionSelector value'; Command = { (New-TGOptionSelector 'a', 'b', 'c' -Value 2).Value }; Expected = 2 }
        @{ Name = 'LinearSelector value'; Command = { (New-TGLinearSelector 'a', 'b' -Value b).Value }; Expected = 'b' }
        @{ Name = 'NumericUpDown value'; Command = { (New-TGNumericUpDown 7 -Increment 2).Increment }; Expected = 2 }
        @{ Name = 'DatePicker value'; Command = { (New-TGDatePicker ([datetime]'2026-01-02')).Value.Day }; Expected = 2 }
        @{ Name = 'ColorPicker value'; Command = { "$((New-TGColorPicker '#FF8800').SelectedColor)" }; Expected = '#FF8800' }
        @{ Name = 'DropDownList text'; Command = { (New-TGDropDownList 'a', 'b' -Text b).Text }; Expected = 'b' }
        @{ Name = 'ProgressBar fraction'; Command = { (New-TGProgressBar 0.25).Fraction }; Expected = 0.25 }
        @{ Name = 'Markdown text'; Command = { (New-TGMarkdown '# Hi').Text }; Expected = '# Hi' }
    ) {
        & $Command | Should -Be $Expected
    }
}

Describe 'Data views' {
    BeforeAll {
        $people = @(
            [PSCustomObject]@{ Name = 'Ada'; Age = 36 }
            [PSCustomObject]@{ Name = 'Grace'; Age = 85 }
        )
    }

    It 'lists objects by Name and keeps the originals' {
        $list = $people | New-TGListView
        $list.Source.ToList() | Should -Be @('Ada', 'Grace')
        $list.Data[1] | Should -Be $people[1]
    }

    It 'lists objects by -Display scriptblock' {
        $list = $people | New-TGListView -Display { "$($_.Name) ($($_.Age))" }
        $list.Source.ToList()[0] | Should -Be 'Ada (36)'
    }

    It 'builds table columns from properties' {
        $table = $people | New-TGTableView
        $table.Table.ColumnNames | Should -Be @('Name', 'Age')
        $table.Table.Rows | Should -Be 2
    }

    It 'builds table columns from -Column' {
        ($people | New-TGTableView -Column Age).Table.ColumnNames | Should -Be @('Age')
    }

    It 'loads tree children from -ChildScript' {
        $tree = New-TGTreeView 1 -ChildScript { if ($_ -lt 3) { $_ * 10; $_ * 10 + 1 } }
        @($tree.TreeBuilder.GetChildren(1)) | Should -Be @(10, 11)
        $tree.TreeBuilder.CanExpand(30) | Should -BeFalse
    }
}

Describe 'Graph views' {
    BeforeAll {
        $people = @(
            [PSCustomObject]@{ Name = 'Ada'; Age = 36; Height = 160 }
            [PSCustomObject]@{ Name = 'Grace'; Age = 85; Height = 170 }
        )
    }

    It 'builds bars from -Value, labelled by Name' {
        $graph = $people | New-TGGraphView -Value Age
        $graph.Series[0].Bars.Text | Should -Be @('Ada', 'Grace')
        $graph.Series[0].Bars.Value | Should -Be @(36, 85)
    }

    It 'builds bars from plain numbers and -Label scriptblocks' {
        $graph = 3, 5 | New-TGGraphView -Label { "n$_" }
        $graph.Series[0].Bars.Text | Should -Be @('n3', 'n5')
        $graph.Series[0].Bars.Value | Should -Be @(3, 5)
    }

    It 'builds scatter points from -XValue and -Value' {
        $graph = $people | New-TGGraphView -Type Scatter -XValue Height -Value { $_.Age * 2 }
        $graph.Series[0].GetType().Name | Should -Be 'ScatterSeries'
        $graph.Series[0].Points.X | Should -Be @(160, 170)
        $graph.Series[0].Points.Y | Should -Be @(72, 170)
    }

    It 'builds a line from input positions' {
        $graph = 4, 8, 6 | New-TGGraphView -Type Line
        $graph.Annotations[0].Points.X | Should -Be @(0, 1, 2)
        $graph.Annotations[0].Points.Y | Should -Be @(4, 8, 6)
    }

    It 'applies color, fill, and axis titles' {
        $graph = 1 | New-TGGraphView -Color BrightGreen -Fill '#' -XAxisTitle 'x' -YAxisTitle 'y'
        $graph.Series[0].Bars[0].Fill.Color.Foreground | Should -Be ([Terminal.Gui.Drawing.Color]'BrightGreen')
        "$($graph.Series[0].Bars[0].Fill.Rune)" | Should -Be '#'
        $graph.AxisX.Text | Should -Be 'x'
        $graph.AxisY.Text | Should -Be 'y'
    }

    It 'throws for values that are not numbers' {
        { $people | New-TGGraphView -Value Name } | Should -Throw "*'Name' of*is not a number*"
    }
}

Describe 'Markdown syntax highlighting' {
    It 'highlights code blocks by default' {
        (New-TGMarkdown '# Hi').SyntaxHighlighter.ThemeName | Should -Be 'DarkPlus'
    }

    It 'honours -NoSyntaxHighlighting' {
        (New-TGMarkdown '# Hi' -NoSyntaxHighlighting).SyntaxHighlighter | Should -BeNullOrEmpty
    }

    It 'loads the native TextMate regex library for this platform' {
        # Throws DllNotFoundException when libonigwrap was not restored next to the assemblies.
        $highlighter = (New-TGMarkdown '# Hi').SyntaxHighlighter
        $highlighter.Highlight('$x = Get-Process', 'powershell').Text | Should -Contain 'Get-Process'
    }
}

Describe 'Get-TGView' {
    It 'finds views by Id' {
        $null = New-TGLabel 'found me' -Id 'getview-test'
        (Get-TGView 'getview-test').Text | Should -Be 'found me'
    }

    It 'writes an error for an unknown Id' {
        { Get-TGView 'no-such-view' -ErrorAction Stop } | Should -Throw "*No view with Id 'no-such-view'*"
    }
}

Describe 'Register-TGEvent' {
    It 'throws for an unknown event' {
        { New-TGButton 'b' | Register-TGEvent -EventName NotAnEvent -Action { } } | Should -Throw "*no event named 'NotAnEvent'*"
    }

    It 'passes $this and $_ to the handler' {
        $script:seen = $null
        $field = New-TGTextField 'a' | Register-TGEvent TextChanged { $script:seen = "$($this.Text)|$($_.GetType().Name)" } -PassThru
        $field.Text = 'b'
        $script:seen | Should -Be 'b|EventArgs'
    }
}

Describe 'Add-TGView' {
    It 'adds piped views to the parent' {
        $window = New-TGWindow 'w'
        New-TGLabel 'a' | Add-TGView -Parent $window
        $window.SubViews.Count | Should -Be 1
    }
}

Describe 'Set-TGStyle' {
    It 'builds a color scheme from foreground, background, and text style' {
        $label = New-TGLabel 'x' | Set-TGStyle -Foreground BrightYellow -Background '#003366' -TextStyle 'Bold, Underline' -PassThru
        "$($label.GetScheme().Normal)" | Should -Be '[BrightYellow,#003366,Bold, Underline]'
    }

    It 'keeps current colors that are not given' {
        $label = New-TGLabel 'x' | Set-TGStyle -Foreground Red -Background Blue -PassThru
        $label | Set-TGStyle -TextStyle Italic
        "$($label.GetScheme().Normal)" | Should -Be '[Red,Blue,Italic]'
    }

    It 'sets scheme name, border, and shadow' {
        $frame = New-TGFrameView 'f' | Set-TGStyle -Scheme Accent -BorderStyle Rounded -Shadow Opaque -PassThru
        $frame.SchemeName | Should -Be 'Accent'
        "$($frame.BorderStyle)" | Should -Be 'Rounded'
        "$($frame.ShadowStyle)" | Should -Be 'Opaque'
    }

    It 'outputs nothing without -PassThru' {
        New-TGLabel 'x' | Set-TGStyle -Foreground Red | Should -BeNullOrEmpty
    }
}
