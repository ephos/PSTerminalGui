function New-TGListView {
    <#
    .SYNOPSIS
    Creates a scrollable list of objects.

    .DESCRIPTION
    Accepts any objects from the pipeline. Each row shows -Display, or the object's Name property,
    or the object as a string. The original objects are kept, get the selection with Get-TGSelectedItem.

    .PARAMETER InputObject
    Objects to list.

    .PARAMETER Display
    Property name, or scriptblock with the object in $_, used as the row text.

    .PARAMETER MultiSelect
    Allow marking several rows (Space toggles a mark).

    .PARAMETER OnSelectionChanged
    Scriptblock run after the highlighted row changes. $this is the list, Get-TGSelectedItem $this the object.

    .PARAMETER OnAccept
    Scriptblock run when Enter is pressed or a row is double-clicked.

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
    Hashtable of any other ListView properties to set.

    .EXAMPLE
    Get-Service | TGListView -Id services -Width Fill -Height Fill -OnAccept {
        Show-TGMessageBox -Title 'Status' -Message (Get-TGSelectedItem $this).Status
    }
    #>
    [CmdletBinding()]
    [Alias('TGListView')]
    [OutputType([Terminal.Gui.Views.ListView])]
    param (
        [Parameter(Mandatory=$false, Position=0, ValueFromPipeline=$true)]
        [object[]]
        $InputObject,

        [Parameter(Mandatory=$false)]
        [object]
        $Display,

        [Parameter(Mandatory=$false)]
        [switch]
        $MultiSelect,

        [Parameter(Mandatory=$false)]
        [scriptblock]
        $OnSelectionChanged,

        [Parameter(Mandatory=$false)]
        [scriptblock]
        $OnAccept,

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

    begin {
        $items = [System.Collections.Generic.List[object]]::new()
    }

    process {
        foreach ($item in $InputObject) { $items.Add($item) }
    }

    end {
        $labels = [System.Collections.ObjectModel.ObservableCollection[string]]::new()
        foreach ($item in $items) { $labels.Add((Get-TGItemLabel -InputObject $item -Display $Display)) }

        $view = [Terminal.Gui.Views.ListView]::new()
        $view.Source = [Terminal.Gui.Views.ListWrapper[string]]::new($labels)
        $view.Data = $items.ToArray()
        if ($MultiSelect) {
            $view.ShowMarks = $true
            $view.MarkMultiple = $true
        }
        Set-TGViewCommon -View $view -BoundParameters $PSBoundParameters
        if ($OnSelectionChanged) {
            Register-TGEventInternal -InputObject $view -EventName 'ValueChanged' -Action $OnSelectionChanged
        }
        if ($OnAccept) {
            Register-TGEventInternal -InputObject $view -EventName 'Accepting' -Action $OnAccept -SetHandled
        }
        $view
    }
}
