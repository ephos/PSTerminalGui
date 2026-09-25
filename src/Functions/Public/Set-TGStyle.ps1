function Set-TGStyle {
    <#
    .SYNOPSIS
    Sets the colors, text style, border, and shadow of a view.

    .DESCRIPTION
    -Foreground, -Background, and -TextStyle build a color scheme for the view. Terminal.Gui derives the
    focus, hotkey, and disabled colors from it. Any of the three you leave out keeps the view's current value.

    -Scheme applies one of the named theme schemes instead: Base, Accent, Dialog, Error, or Menu.

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
            $current = $View.GetScheme().Normal
            $fg = if ($PSBoundParameters.ContainsKey('Foreground')) { $Foreground } else { $current.Foreground }
            $bg = if ($PSBoundParameters.ContainsKey('Background')) { $Background } else { $current.Background }
            $style = if ($PSBoundParameters.ContainsKey('TextStyle')) { $TextStyle } else { $current.Style }

            # Attribute's constructors take 'in' parameters, which PowerShell passes as [ref].
            $attribute = [Terminal.Gui.Drawing.Attribute]::new([ref]$fg, [ref]$bg, [ref]$style)
            $null = $View.SetScheme([Terminal.Gui.Drawing.Scheme]::new($attribute))
        }

        if ($PSBoundParameters.ContainsKey('BorderStyle')) { $View.BorderStyle = $BorderStyle }
        if ($PSBoundParameters.ContainsKey('Shadow')) { $View.ShadowStyle = $Shadow }

        if ($PassThru) { $View }
    }
}
