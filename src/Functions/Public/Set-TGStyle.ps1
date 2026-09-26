function Set-TGStyle {
    <#
    .SYNOPSIS
    Sets the colors, text style, border, title, and shadow of a view.

    .DESCRIPTION
    -Foreground, -Background, and -TextStyle build a color scheme for the view. Terminal.Gui derives the
    focus, hotkey, and disabled colors from it. Any of the three you leave out keeps the view's current value.

    -Scheme applies one of the named theme schemes instead: Base, Accent, Dialog, Error, or Menu.

    -TitleForeground, -TitleBackground, and -TitleStyle style the title in the border on its own,
    whether or not the view has focus. The title keeps following changes to the view's Title.

    Use -PassThru to keep the view in a content block's output.

    .PARAMETER View
    The view to style.

    .PARAMETER Foreground
    Text color: a name like 'BrightYellow' or a hex value like '#FF8800'.

    .PARAMETER Background
    Background color: a name like 'Blue' or a hex value like '#003366'.

    .PARAMETER TextStyle
    One or more of Bold, Faint, Italic, Underline, Blink, Reverse, Strikethrough.

    .PARAMETER Scheme
    Named theme scheme to use.

    .PARAMETER TitleForeground
    Title text color: a name like 'BrightCyan' or a hex value like '#FF8800'.

    .PARAMETER TitleBackground
    Title background color.

    .PARAMETER TitleStyle
    Title text style, e.g. 'Bold, Underline'.

    .PARAMETER BorderStyle
    Border line style: None, Single, Double, Heavy, Rounded, Dashed, Dotted, and their Heavy/Rounded variants.

    .PARAMETER Shadow
    Drop shadow: None, Opaque, or Transparent.

    .PARAMETER PassThru
    Output the view after styling it.

    .EXAMPLE
    TGLabel 'Warning!' | Set-TGStyle -Foreground BrightYellow -Background Red -TextStyle Bold -PassThru

    .EXAMPLE
    TGFrameView 'Status' { TGLabel 'All good' } | Set-TGStyle -BorderStyle Rounded -Scheme Accent -PassThru

    .EXAMPLE
    TGWindow 'Dashboard' { ... } | Set-TGStyle -TitleForeground BrightCyan -TitleStyle Bold -PassThru | Start-TGApplication
    #>
    [CmdletBinding()]
    [OutputType([Terminal.Gui.ViewBase.View])]
    param (
        [Parameter(Mandatory=$true, ValueFromPipeline=$true, Position=0)]
        [Terminal.Gui.ViewBase.View]
        $View,

        [Parameter(Mandatory=$false)]
        [Terminal.Gui.Drawing.Color]
        $Foreground,

        [Parameter(Mandatory=$false)]
        [Terminal.Gui.Drawing.Color]
        $Background,

        [Parameter(Mandatory=$false)]
        [Terminal.Gui.Drawing.TextStyle]
        $TextStyle,

        [Parameter(Mandatory=$false)]
        [ValidateSet('Base', 'Accent', 'Dialog', 'Error', 'Menu')]
        [string]
        $Scheme,

        [Parameter(Mandatory=$false)]
        [Terminal.Gui.Drawing.Color]
        $TitleForeground,

        [Parameter(Mandatory=$false)]
        [Terminal.Gui.Drawing.Color]
        $TitleBackground,

        [Parameter(Mandatory=$false)]
        [Terminal.Gui.Drawing.TextStyle]
        $TitleStyle,

        [Parameter(Mandatory=$false)]
        [Terminal.Gui.Drawing.LineStyle]
        $BorderStyle,

        [Parameter(Mandatory=$false)]
        [Terminal.Gui.ViewBase.ShadowStyles]
        $Shadow,

        [Parameter(Mandatory=$false)]
        [switch]
        $PassThru
    )

    process {
        if ($Scheme) {
            $View.SchemeName = $Scheme
        }

        if ($PSBoundParameters.ContainsKey('Foreground') -or $PSBoundParameters.ContainsKey('Background') -or $PSBoundParameters.ContainsKey('TextStyle')) {
            Set-TGSchemeColor -View $View -Foreground $PSBoundParameters['Foreground'] -Background $PSBoundParameters['Background'] -TextStyle $PSBoundParameters['TextStyle']
        }

        if ($PSBoundParameters.ContainsKey('TitleForeground') -or $PSBoundParameters.ContainsKey('TitleBackground') -or $PSBoundParameters.ContainsKey('TitleStyle')) {
            $titleLabel = Get-TGTitleLabel -View $View
            Set-TGSchemeColor -View $titleLabel -Foreground $PSBoundParameters['TitleForeground'] -Background $PSBoundParameters['TitleBackground'] -TextStyle $PSBoundParameters['TitleStyle']
        }

        if ($PSBoundParameters.ContainsKey('BorderStyle')) { $View.BorderStyle = $BorderStyle }
        if ($PSBoundParameters.ContainsKey('Shadow')) { $View.ShadowStyle = $Shadow }

        if ($PassThru) { $View }
    }
}
