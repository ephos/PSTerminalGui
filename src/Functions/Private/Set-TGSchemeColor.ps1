function Set-TGSchemeColor {
    [CmdletBinding()]
    param (
        # View whose color scheme is replaced
        [Parameter(Mandatory=$true)]
        [Terminal.Gui.ViewBase.View]
        $View,

        # New text color, or $null to keep the current one
        [Parameter(Mandatory=$false)]
        [Nullable[Terminal.Gui.Drawing.Color]]
        $Foreground,

        # New background color, or $null to keep the current one
        [Parameter(Mandatory=$false)]
        [Nullable[Terminal.Gui.Drawing.Color]]
        $Background,

        # New text style, or $null to keep the current one
        [Parameter(Mandatory=$false)]
        [Nullable[Terminal.Gui.Drawing.TextStyle]]
        $TextStyle
    )

    process {
        $current = $View.GetScheme().Normal
        $fg = if ($null -ne $Foreground) { $Foreground } else { $current.Foreground }
        $bg = if ($null -ne $Background) { $Background } else { $current.Background }
        $style = if ($null -ne $TextStyle) { $TextStyle } else { $current.Style }

        # Attribute's constructors take 'in' parameters, which PowerShell passes as [ref].
        $attribute = [Terminal.Gui.Drawing.Attribute]::new([ref]$fg, [ref]$bg, [ref]$style)
        $null = $View.SetScheme([Terminal.Gui.Drawing.Scheme]::new($attribute))
    }
}
