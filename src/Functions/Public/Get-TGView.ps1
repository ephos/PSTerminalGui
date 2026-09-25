function Get-TGView {
    <#
    .SYNOPSIS
    Gets a view by the -Id it was created with.

    .DESCRIPTION
    Without -Root, looks the Id up in the module's registry of views created with -Id.
    With -Root, searches that view's subviews recursively instead.

    .PARAMETER Id
    The view Id. Supports wildcards.

    .PARAMETER Root
    View whose subtree to search.

    .EXAMPLE
    New-TGButton 'Greet' -OnAccept { Show-TGMessageBox -Message "Hi $((Get-TGView name).Text)" }
    #>
    [CmdletBinding()]
    [OutputType([Terminal.Gui.ViewBase.View])]
    param (
        [Parameter(Mandatory=$false, Position=0)]
        [SupportsWildcards()]
        [string]
        $Id = '*',

        [Parameter(Mandatory=$false)]
        [Terminal.Gui.ViewBase.View]
        $Root
    )

    process {
        if (-not $Root) {
            $found = $script:TGViewRegistry.Keys | Where-Object { $_ -like $Id } | Sort-Object | ForEach-Object { $script:TGViewRegistry[$_] }
            if (-not $found -and -not [WildcardPattern]::ContainsWildcardCharacters($Id)) {
                Write-Error -Message "No view with Id '$Id' was found." -Category ObjectNotFound -TargetObject $Id
            }
            return $found
        }

        $stack = [System.Collections.Generic.Stack[Terminal.Gui.ViewBase.View]]::new()
        $stack.Push($Root)
        while ($stack.Count -gt 0) {
            $current = $stack.Pop()
            if ($current.Id -and $current.Id -like $Id) { $current }
            foreach ($child in $current.SubViews) { $stack.Push($child) }
        }
    }
}
