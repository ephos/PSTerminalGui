function Set-TGViewCommon {
    [CmdletBinding()]
    param (
        # View to configure
        [Parameter(Mandatory=$true)]
        [Terminal.Gui.ViewBase.View]
        $View,

        # $PSBoundParameters of the calling New-TG* function
        [Parameter(Mandatory=$true)]
        [hashtable]
        $BoundParameters
    )

    process {
        if ($BoundParameters.ContainsKey('Id')) {
            $View.Id = $BoundParameters.Id
            $script:TGViewRegistry[$BoundParameters.Id] = $View
        }

        if ($BoundParameters.ContainsKey('X'))      { $View.X = ConvertTo-TGPos -Value $BoundParameters.X }
        if ($BoundParameters.ContainsKey('Y'))      { $View.Y = ConvertTo-TGPos -Value $BoundParameters.Y }
        if ($BoundParameters.ContainsKey('Width'))  { $View.Width = ConvertTo-TGDim -Value $BoundParameters.Width }
        if ($BoundParameters.ContainsKey('Height')) { $View.Height = ConvertTo-TGDim -Value $BoundParameters.Height }
        if ($BoundParameters.ContainsKey('Title'))  { $View.Title = $BoundParameters.Title }

        # Escape hatch for any property without a dedicated parameter.
        if ($BoundParameters.ContainsKey('Property')) {
            foreach ($key in $BoundParameters.Property.Keys) {
                if (-not $View.PSObject.Properties[$key]) {
                    throw "$($View.GetType().Name) has no property named '$key'."
                }
                $View.$key = $BoundParameters.Property[$key]
            }
        }
    }
}
