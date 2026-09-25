function New-TGTab {
    <#
    .SYNOPSIS
    Creates one tab page for New-TGTabs. The title is the tab caption.

    .PARAMETER Title
    Tab caption. Use _ before a letter to make it the hotkey.

    .PARAMETER Content
    Scriptblock whose view output is added as child views.

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
    Hashtable of any other View properties to set.

    .EXAMPLE
    TGTab 'General' { TGLabel 'General settings' }
    #>
    [CmdletBinding()]
    [Alias('TGTab')]
    [OutputType([Terminal.Gui.ViewBase.View])]
    param (
        [Parameter(Mandatory=$true, Position=0)]
        [string]
        $Title,

        [Parameter(Mandatory=$false, Position=1)]
        [scriptblock]
        $Content,

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
        $view = [Terminal.Gui.ViewBase.View]::new()
        $view.Width = [Terminal.Gui.ViewBase.Dim]::Fill()
        $view.Height = [Terminal.Gui.ViewBase.Dim]::Fill()
        $view.CanFocus = $true
        Set-TGViewCommon -View $view -BoundParameters $PSBoundParameters
        if ($Content) { Add-TGContent -Parent $view -Content $Content }
        $view
    }
}