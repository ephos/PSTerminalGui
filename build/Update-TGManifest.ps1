[CmdletBinding()]
param (
    # Module source folder
    [Parameter(Mandatory=$false)]
    [string]
    $Path = (Join-Path -Path $PSScriptRoot -ChildPath '../src')
)

# Syncs FunctionsToExport and AliasesToExport in the manifest with the files in Functions/Public.
$ErrorActionPreference = 'Stop'

$functions = [System.Collections.Generic.List[string]]::new()
$aliases = [System.Collections.Generic.List[string]]::new()

foreach ($file in Get-ChildItem -Path (Join-Path -Path $Path -ChildPath 'Functions/Public') -Filter *.ps1 | Sort-Object -Property BaseName) {
    $ast = [System.Management.Automation.Language.Parser]::ParseFile($file.FullName, [ref]$null, [ref]$null)
    $function = $ast.Find({ param($node) $node -is [System.Management.Automation.Language.FunctionDefinitionAst] }, $false)
    $functions.Add($function.Name)

    $aliasAttribute = $function.Body.ParamBlock.Attributes | Where-Object { $_.TypeName.Name -eq 'Alias' }
    foreach ($argument in $aliasAttribute.PositionalArguments) {
        $aliases.Add($argument.SafeGetValue())
    }
}

$manifest = Get-ChildItem -Path $Path -Filter *.psd1 | Select-Object -First 1
Update-ModuleManifest -Path $manifest.FullName -FunctionsToExport $functions -AliasesToExport $aliases
# Update-ModuleManifest leaves trailing whitespace on wrapped lines.
(Get-Content -Path $manifest.FullName) -replace '\s+$' | Set-Content -Path $manifest.FullName
"Exported $($functions.Count) functions and $($aliases.Count) aliases in $($manifest.Name)."
