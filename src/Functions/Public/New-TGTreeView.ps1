function New-TGTreeView {
    <#
    .SYNOPSIS
    Creates an expandable tree of objects.

    .DESCRIPTION
    Children are loaded on demand by running -ChildScript with the parent node in $_.
    Get the selected node with Get-TGSelectedItem, or $this.SelectedObject in a handler.

    .PARAMETER InputObject
    Root objects of the tree.

    .PARAMETER ChildScript
    Scriptblock that outputs the children of the node in $_. Output nothing for a leaf.

    .PARAMETER Display
    Property name, or scriptblock with the node in $_, used as the node text.

    .PARAMETER OnSelectionChanged
    Scriptblock run after the selected node changes. $_.NewValue is the node.

    .PARAMETER OnAccept
    Scriptblock run when Enter is pressed or a node is double-clicked.

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
    Hashtable of any other TreeView properties to set.

    .EXAMPLE
    Get-Item ~ | TGTreeView -Width Fill -Height Fill -ChildScript {
        if ($_.PSIsContainer) { Get-ChildItem -Path $_.FullName -ErrorAction SilentlyContinue }
    }
    #>
    [CmdletBinding()]
    [Alias('TGTreeView')]
    [OutputType([Terminal.Gui.Views.TreeView[object]])]
    param (
        [Parameter(Mandatory=$false, Position=0, ValueFromPipeline=$true)]
        [object[]]
        $InputObject,

        [Parameter(Mandatory=$true)]
        [scriptblock]
        $ChildScript,

        [Parameter(Mandatory=$false)]
        [object]
        $Display,

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
        $roots = [System.Collections.Generic.List[object]]::new()
    }

    process {
        foreach ($item in $InputObject) { $roots.Add($item) }
    }

    end {
        # Children are cached per node, since Terminal.Gui asks for them repeatedly while drawing.
        $cache = [System.Collections.Generic.Dictionary[object, object[]]]::new()
        $getChildren = {
            param($node)
            $children = $null
            if (-not $cache.TryGetValue($node, [ref]$children)) {
                $children = [object[]]@($node | ForEach-Object -Process $ChildScript)
                $cache[$node] = $children
            }
            , $children
        }.GetNewClosure()

        $childGetter = [Func[object, System.Collections.Generic.IEnumerable[object]]] { param($node) , (& $getChildren $node) }.GetNewClosure()
        $canExpand = [Func[object, bool]] { param($node) (& $getChildren $node).Count -gt 0 }.GetNewClosure()

        $labelFunction = ${function:Get-TGItemLabel}
        $view = [Terminal.Gui.Views.TreeView[object]]::new()
        $view.TreeBuilder = [Terminal.Gui.Views.DelegateTreeBuilder[object]]::new($childGetter, $canExpand)
        $view.AspectGetter = [Terminal.Gui.Views.AspectGetterDelegate[object]] { param($node) & $labelFunction -InputObject $node -Display $Display }.GetNewClosure()
        $view.AddObjects($roots)
        Set-TGViewCommon -View $view -BoundParameters $PSBoundParameters
        if ($OnSelectionChanged) {
            Register-TGEventInternal -InputObject $view -EventName 'SelectionChanged' -Action $OnSelectionChanged
        }
        if ($OnAccept) {
            Register-TGEventInternal -InputObject $view -EventName 'Accepting' -Action $OnAccept -SetHandled
        }
        $view
    }
}
