function Get-TGItemLabel {
    [CmdletBinding()]
    [OutputType([string])]
    param (
        # Object to label
        [Parameter(Mandatory=$false)]
        [object]
        $InputObject,

        # Property name, or scriptblock with the object in $_
        [Parameter(Mandatory=$false)]
        [object]
        $Display
    )

    process {
        if ($null -eq $InputObject) { return '' }

        if ($Display -is [scriptblock]) {
            return "$($InputObject | ForEach-Object -Process $Display)"
        }
        if ($Display) {
            return "$($InputObject.$Display)"
        }

        # Most PowerShell objects (files, processes, services) are best identified by Name.
        if ($InputObject -isnot [string] -and -not $InputObject.GetType().IsPrimitive -and $InputObject.PSObject.Properties['Name']) {
            return "$($InputObject.Name)"
        }
        "$InputObject"
    }
}
