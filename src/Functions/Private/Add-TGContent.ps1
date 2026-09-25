function Add-TGContent {
    [CmdletBinding()]
    param (
        # View that receives the child views
        [Parameter(Mandatory=$true)]
        [Terminal.Gui.ViewBase.View]
        $Parent,

        # Scriptblock whose View output is added to the parent
        [Parameter(Mandatory=$true)]
        [scriptblock]
        $Content
    )

    process {
        foreach ($child in (& $Content)) {
            if ($child -is [Terminal.Gui.ViewBase.View]) {
                $null = $Parent.Add($child)
            } elseif ($null -ne $child) {
                Write-Verbose -Message "Ignoring non-view output from content block: $($child.GetType().FullName)"
            }
        }
    }
}
