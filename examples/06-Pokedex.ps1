# Browse the first 151 Pokémon from https://pokeapi.co.
# Details load in a thread job, so the UI stays responsive while the request is in flight.
Import-Module $PSScriptRoot/../src/PSTerminalGui.psd1

$api = 'https://pokeapi.co/api/v2'
$modulePath = (Resolve-Path -Path "$PSScriptRoot/../src/PSTerminalGui.psd1").Path

Write-Host 'Fetching the Pokédex...'
$pokemon = (Invoke-RestMethod -Uri "$api/pokemon?limit=151").results

TGWindow 'Pokédex (Esc quits)' {
    $pokemon | TGListView -Id list -Width 22 -Height Fill -Display { $_.name } -OnSelectionChanged {
        $entry = Get-TGSelectedItem $this
        (Get-TGView name).Text = "Loading $($entry.name)..."

        $null = Start-ThreadJob -ArgumentList $modulePath, $entry.url {
            param($modulePath, $url)
            Import-Module $modulePath
            $p = Invoke-RestMethod -Uri $url

            $details = @(
                "Types:     $($p.types.type.name -join ', ')"
                "Height:    $($p.height / 10) m"
                "Weight:    $($p.weight / 10) kg"
                "Abilities: $($p.abilities.ability.name -join ', ')"
            ) -join "`n"
            $stats = ($p.stats | ForEach-Object {
                '{0,-16} {1,3} {2}' -f $_.stat.name, $_.base_stat, ('█' * [math]::Ceiling($_.base_stat / 10))
            }) -join "`n"

            # Runs on the UI thread. Skip it if the user already moved on to another Pokémon.
            Invoke-TGOnUIThread -ArgumentList $p.name, $p.id, $details, $stats {
                param($name, $id, $details, $stats)
                if ((Get-TGSelectedItem list).name -ne $name) { return }
                (Get-TGView name).Text = '#{0:000} {1}' -f $id, $name.ToUpper()
                (Get-TGView details).Text = $details
                (Get-TGView stats).Text = $stats
            }
        }
    }

    TGFrameView 'Details' -X 23 -Width Fill -Height Fill {
        TGLabel 'Pick a Pokémon on the left' -Id name -X 1 -Y 0 | Set-TGStyle -Foreground BrightYellow -TextStyle Bold -PassThru
        TGLabel -Id details -X 1 -Y 2 -Width Fill
        TGFrameView 'Base stats' -X 1 -Y 7 -Width Fill-1 -Height 8 {
            TGLabel -Id stats -Width Fill
        } | Set-TGStyle -BorderStyle Rounded -PassThru
    }
} | Start-TGApplication

Get-Job | Remove-Job -Force
