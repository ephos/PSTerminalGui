function New-TGButton {
    <#
    .SYNOPSIS
    Creates a Button.

    .PARAMETER Text
    Button caption. Use _ before a letter to make it the hotkey (e.g. '_Save').

    .PARAMETER OnAccept
    Scriptblock run when the button is pressed (Enter, Space, click, or hotkey).
    $this is the button. The event is marked handled so it does not also close a parent dialog.

    .PARAMETER IsDefault
    Make this the default button, pressed by Enter anywhere in the parent.

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
    Hashtable of any other Button properties to set.

    .EXAMPLE
    New-TGButton '_Quit' -X Center -Y AnchorEnd -OnAccept { Stop-TGApplication }
    #>
    [CmdletBinding()]
    [Alias('TGButton')]
    [OutputType([Terminal.Gui.Views.Button])]
    param (
        [Parameter(Mandatory=$false, Position=0)]
        [string]
        $Text,

        [Parameter(Mandatory=$false, Position=1)]
        [scriptblock]
        $OnAccept,

        [Parameter(Mandatory=$false)]
        [switch]
        $IsDefault,

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
        $view = [Terminal.Gui.Views.Button]::new()
        if ($PSBoundParameters.ContainsKey('Text')) { $view.Text = $Text }
        if ($IsDefault) { $view.IsDefault = $true }
        Set-TGViewCommon -View $view -BoundParameters $PSBoundParameters
        if ($OnAccept) {
            Register-TGEventInternal -InputObject $view -EventName 'Accepting' -Action $OnAccept -SetHandled
        }
        $view
    }
}
