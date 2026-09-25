function New-TGTabs {
    <#
    .SYNOPSIS
    Creates a tab container. Add tabs with New-TGTab in the content block.

    .PARAMETER Content
    Scriptblock that outputs New-TGTab views.

    .PARAMETER OnValueChanged
    Scriptblock run after the selected tab changes. $_.NewValue is the selected tab view.

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
    Hashtable of any other Tabs properties to set.

    .EXAMPLE
    TGTabs -Width Fill -Height Fill {
        TGTab 'General' { TGLabel 'General settings' }
        TGTab 'Advanced' { TGLabel 'Advanced settings' }
    }
    #>
    [CmdletBinding()]
    [Alias('TGTabs')]
    [OutputType([Terminal.Gui.Views.Tabs])]
    param (
        [Parameter(Mandatory=$false, Position=0)]
        [scriptblock]
        $Content,

        [Parameter(Mandatory=$false)]
        [scriptblock]
        $OnValueChanged,

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
        $view = [Terminal.Gui.Views.Tabs]::new()
        Set-TGViewCommon -View $view -BoundParameters $PSBoundParameters
        if ($Content) { Add-TGContent -Parent $view -Content $Content }
        if ($OnValueChanged) {
            Register-TGEventInternal -InputObject $view -EventName 'ValueChanged' -Action $OnValueChanged
        }
        $view
    }
}