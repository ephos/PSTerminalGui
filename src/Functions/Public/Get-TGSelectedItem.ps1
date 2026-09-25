function Get-TGSelectedItem {
    <#
    .SYNOPSIS
    Gets the selected object(s) of a list, table, or tree view.

    .DESCRIPTION
    Returns the original objects passed to New-TGListView, New-TGTableView, or New-TGTreeView,
    not the displayed text. For a list with -MultiSelect, returns every marked object,
    or the highlighted object when nothing is marked.

    .PARAMETER View
    The list, table, or tree view, or its Id.

    .EXAMPLE
    TGListView (Get-ChildItem) -OnAccept { Show-TGMessageBox (Get-TGSelectedItem $this).FullName }
    #>
    [CmdletBinding()]
    [OutputType([object], [object[]])]
    param (
        [Parameter(Mandatory=$true, Position=0, ValueFromPipeline=$true)]
        [object]
        $View
    )

    process {
        if ($View -is [string]) {
            $View = Get-TGView -Id $View -ErrorAction Stop
        }

        switch ($View) {
            { $_ -is [Terminal.Gui.Views.ListView] } {
                $marked = @(for ($i = 0; $i -lt $View.Data.Count; $i++) { if ($View.Source.IsMarked($i)) { $View.Data[$i] } })
                if ($marked) { return $marked }
                if ($null -ne $View.SelectedItem) { return $View.Data[$View.SelectedItem] }
                return
            }
            { $_ -is [Terminal.Gui.Views.TableView] } {
                $rows = @($View.GetAllSelectedCells() | ForEach-Object Y | Sort-Object -Unique)
                return $rows | ForEach-Object { $View.Data[$_] }
            }
            { $_ -is [Terminal.Gui.Views.TreeView[object]] } {
                return $View.GetAllSelectedObjects()
            }
            default {
                throw "Get-TGSelectedItem supports ListView, TableView, and TreeView, not $($View.GetType().Name)."
            }
        }
    }
}
