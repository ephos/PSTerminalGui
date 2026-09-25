function Set-TGFocus {
    <#
    .SYNOPSIS
    Moves keyboard focus to a view.

    .PARAMETER View
    The view to focus. Accepts a view object or an Id.

    .EXAMPLE
    Set-TGFocus -View name
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true, ValueFromPipeline=$true, Position=0)]
        [object]
        $View
    )

    process {
        if ($View -is [string]) {
            $View = Get-TGView -Id $View -ErrorAction Stop
        }
        $null = $View.SetFocus()
    }
}
