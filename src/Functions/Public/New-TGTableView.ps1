function New-TGTableView {
    <#
    .SYNOPSIS
    Creates a table of objects, one row per object and one column per property.

    .DESCRIPTION
    Accepts any objects from the pipeline. Columns come from -Property, or the object's default
    display properties, or all of its properties. The original objects are kept, get the selected
    row's object with Get-TGSelectedItem.

    .PARAMETER InputObject
    Objects to show.

    .PARAMETER Column
    Property names to show as columns, in order.

    .PARAMETER CellSelect
    Highlight single cells instead of whole rows.

    .PARAMETER OnSelectionChanged
    Scriptblock run after the selected cell changes. $this is the table, Get-TGSelectedItem $this the row object.

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
    Hashtable of any other TableView properties to set.

    .EXAMPLE
    Get-Process | TGTableView -Column Id, Name, CPU, WorkingSet -Width Fill -Height Fill
    #>
    [CmdletBinding()]
    [Alias('TGTableView')]
    [OutputType([Terminal.Gui.Views.TableView])]
    param (
        [Parameter(Mandatory=$false, Position=0, ValueFromPipeline=$true)]
        [object[]]
        $InputObject,

        [Parameter(Mandatory=$false)]
        [string[]]
        $Column,

        [Parameter(Mandatory=$false)]
        [switch]
        $CellSelect,

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
        $view = [Terminal.Gui.Views.TableView]::new()
        $view.Table = [Terminal.Gui.Views.DataTableSource]::new((ConvertTo-TGDataTable -InputObject $items -Column $Column))
        $view.Data = $items.ToArray()
        $view.FullRowSelect = -not $CellSelect
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
