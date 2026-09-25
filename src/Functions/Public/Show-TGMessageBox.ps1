function Show-TGMessageBox {
    <#
    .SYNOPSIS
    Shows a modal message box and returns the button that was pressed.

    .DESCRIPTION
    Works inside a running application (e.g. from an event handler) and from plain scripts,
    where it briefly takes over the terminal.

    .PARAMETER Title
    Message box title.

    .PARAMETER Message
    Message text.

    .PARAMETER Button
    Button captions. Defaults to 'OK'.

    .PARAMETER ErrorStyle
    Use the error color scheme.

    .PARAMETER NoWrap
    Do not word-wrap the message.

    .EXAMPLE
    if ((Show-TGMessageBox 'Deploy to production?' -Button Yes, No) -ne 'Yes') { return }

    .EXAMPLE
    if ((Show-TGMessageBox -Title 'Quit' -Message 'Are you sure?' -Button Yes, No) -eq 'Yes') { Stop-TGApplication }

    .OUTPUTS
    The caption of the pressed button, or nothing if the box was cancelled with Esc.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param (
        [Parameter(Mandatory=$false)]
        [string]
        $Title = '',

        [Parameter(Mandatory=$true, Position=0)]
        [string]
        $Message,

        [Parameter(Mandatory=$false)]
        [string[]]
        $Button = @('OK'),

        [Parameter(Mandatory=$false)]
        [switch]
        $ErrorStyle,

        [Parameter(Mandatory=$false)]
        [switch]
        $NoWrap
    )

    process {
        $wrap = -not $NoWrap.IsPresent

        $index = Invoke-TGModal -ScriptBlock {
            param($app)
            if ($ErrorStyle) {
                [Terminal.Gui.Views.MessageBox]::ErrorQuery($app, $Title, $Message, $wrap, $Button)
            } else {
                [Terminal.Gui.Views.MessageBox]::Query($app, $Title, $Message, $wrap, $Button)
            }
        }

        if ($null -ne $index -and $index -ge 0 -and $index -lt $Button.Count) {
            $Button[$index]
        }
    }
}
