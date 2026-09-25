function New-TGWizardStep {
    <#
    .SYNOPSIS
    Creates one step for New-TGWizard.

    .PARAMETER Title
    Title shown in the border.

    .PARAMETER Content
    Scriptblock whose view output is added as child views.

    .PARAMETER HelpText
    Help text shown beside the step.

    .PARAMETER NextButtonText
    Caption for the Next button on this step.

    .PARAMETER BackButtonText
    Caption for the Back button on this step.

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
    Hashtable of any other WizardStep properties to set.

    .EXAMPLE
    TGWizardStep 'Name' -HelpText 'Enter your name.' { TGTextField -Id name -Width 30 }
    #>
    [CmdletBinding()]
    [Alias('TGWizardStep')]
    [OutputType([Terminal.Gui.Views.WizardStep])]
    param (
        [Parameter(Mandatory=$false, Position=0)]
        [string]
        $Title,

        [Parameter(Mandatory=$false, Position=1)]
        [scriptblock]
        $Content,

        [Parameter(Mandatory=$false)]
        [string]
        $HelpText,

        [Parameter(Mandatory=$false)]
        [string]
        $NextButtonText,

        [Parameter(Mandatory=$false)]
        [string]
        $BackButtonText,

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

    process {
        $view = [Terminal.Gui.Views.WizardStep]::new()
        if ($PSBoundParameters.ContainsKey('HelpText')) { $view.HelpText = $HelpText }
        if ($PSBoundParameters.ContainsKey('NextButtonText')) { $view.NextButtonText = $NextButtonText }
        if ($PSBoundParameters.ContainsKey('BackButtonText')) { $view.BackButtonText = $BackButtonText }
        Set-TGViewCommon -View $view -BoundParameters $PSBoundParameters
        if ($Content) { Add-TGContent -Parent $view -Content $Content }
        $view
    }
}