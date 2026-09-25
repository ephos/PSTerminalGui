function ConvertTo-TGDataTable {
    [CmdletBinding()]
    [OutputType([System.Data.DataTable])]
    param (
        # Objects to convert, one row each
        [Parameter(Mandatory=$false)]
        [AllowEmptyCollection()]
        [object[]]
        $InputObject = @(),

        # Property names to use as columns
        [Parameter(Mandatory=$false)]
        [string[]]
        $Column
    )

    process {
        if (-not $Column -and $InputObject.Count -gt 0) {
            $first = $InputObject[0]
            if ($first -is [string] -or $first.GetType().IsPrimitive) {
                $Column = @('Value')
            } else {
                $Column = $first.PSStandardMembers.DefaultDisplayPropertySet.ReferencedPropertyNames
                if (-not $Column) {
                    $Column = $first.PSObject.Properties.Where({ $_.IsGettable }).Name
                }
            }
        }

        $table = [System.Data.DataTable]::new()
        foreach ($name in $Column) {
            $null = $table.Columns.Add($name, [object])
        }

        foreach ($item in $InputObject) {
            $row = $table.NewRow()
            foreach ($name in $Column) {
                $value = if ($Column.Count -eq 1 -and $name -eq 'Value' -and ($item -is [string] -or $item.GetType().IsPrimitive)) { $item } else { $item.$name }
                $row[$name] = if ($null -eq $value) { [DBNull]::Value } else { $value }
            }
            $table.Rows.Add($row)
        }

        # -NoEnumerate keeps PowerShell from enumerating the table's rows.
        Write-Output -InputObject $table -NoEnumerate
    }
}
