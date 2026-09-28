function New-TGMarkdown {
    <#
    .SYNOPSIS
    Creates a view that renders Markdown.

    .PARAMETER Text
    Markdown source.

    .PARAMETER Path
    Markdown file to load instead of -Text.

    .PARAMETER NoSyntaxHighlighting
    Render fenced code blocks without syntax highlighting. Highlighting is on by default.
    Token colors come from the Terminal.Gui theme.

    .PARAMETER OnLinkClicked
    Scriptblock run when a link is clicked. $_ has the link details.

    .PARAMETER Id
    Id used to find the view with Get-TGView.

    .PARAMETER X
    Column: int, 'Center', 'N%', 'AnchorEnd', or a Pos from New-TGPos.

    .PARAMETER Y
    Row: int, 'Center', 'N%', 'AnchorEnd', or a Pos from New-TGPos.

    .PARAMETER Width
    Width: int, 'Fill', 'Fill-N', 'Auto', 'N%', or a Dim from New-TGDim.

    .PARAMETER Height
    Height: int, 'Fill', 'Fill-N', 'Auto', 'N%', or a Dim from New-TGDim.

    .PARAMETER Property
    Hashtable of any other Markdown properties to set.

    .EXAMPLE
    TGMarkdown -Path ./Readme.md -Width Fill -Height Fill
    #>
    [CmdletBinding()]
    [Alias('TGMarkdown')]
    [OutputType([Terminal.Gui.Views.Markdown])]
    param (
        [Parameter(Mandatory=$false, Position=0)]
        [string]
        $Text,

        [Parameter(Mandatory=$false)]
        [string]
        $Path,

        [Parameter(Mandatory=$false)]
        [switch]
        $NoSyntaxHighlighting,

        [Parameter(Mandatory=$false)]
        [scriptblock]
        $OnLinkClicked,

        [Parameter(Mandatory=$false)]
        [string]
        $Id,

        [Parameter(Mandatory=$false)]
        [object]
        $X,

        [Parameter(Mandatory=$false)]
        [object]
        $Y,

        [Parameter(Mandatory=$false)]
        [object]
        $Width,

        [Parameter(Mandatory=$false)]
        [object]
        $Height,

        [Parameter(Mandatory=$false)]
        [hashtable]
        $Property
    )

    process {
        $view = [Terminal.Gui.Views.Markdown]::new()
        # Markdown has no highlighter by default. TextMate needs the native libonigwrap restored by Install-TGDependency.ps1.
        # The TextMate theme only sets the code block background; token colors come from the Terminal.Gui theme.
        if (-not $NoSyntaxHighlighting) {
            $view.SyntaxHighlighter = [Terminal.Gui.Drawing.TextMateSyntaxHighlighter]::new([TextMateSharp.Grammars.ThemeName]::DarkPlus)
        }
        if ($PSBoundParameters.ContainsKey('Path')) {
            $view.Text = Get-Content -Path $Path -Raw -ErrorAction Stop
        } elseif ($PSBoundParameters.ContainsKey('Text')) {
            $view.Text = $Text
        }
        Set-TGViewCommon -View $view -BoundParameters $PSBoundParameters
        if ($OnLinkClicked) {
            Register-TGEventInternal -InputObject $view -EventName 'LinkClicked' -Action $OnLinkClicked
        }
        $view
    }
}