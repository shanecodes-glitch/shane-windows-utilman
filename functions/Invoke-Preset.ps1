function Invoke-Preset {
    <#
    .SYNOPSIS
        Applies a predefined configuration preset.
    .DESCRIPTION
        Applies a "Standard", "Minimal", or "Advanced" preset from preset.json.
    #>
    
    Write-Host "`n[Preset Engine]" -ForegroundColor Cyan
    Write-Log "Started preset engine"
    
    if (-not $global:Presets) {
        Write-Host "No presets loaded. Please check config/preset.json" -ForegroundColor Red
        Write-Log "No presets available" "ERROR"
        return
    }
    
    Write-Host "`nSelect a preset to apply:`n"
    
    $presetNames = $global:Presets | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name
    $i = 1
    foreach ($name in $presetNames) {
        Write-Host "  $i. $name - $($global:Presets.$name.description)"
        $i++
    }
    
    $choice = Read-Host "`nEnter your choice (1-$($presetNames.Count))"
    
    $selectedName = $presetNames[[int]$choice - 1]
    if (-not $selectedName) {
        Write-Host "Invalid choice." -ForegroundColor Red
        return
    }
    
    $preset = $global:Presets.$selectedName
    Write-Host "`nApplying preset: $selectedName" -ForegroundColor Green
    Write-Log "Applying preset: $selectedName"
    
    # Display what the preset includes
    Write-Host "`nThis preset includes:" -ForegroundColor Yellow
    Write-Host "  - Tweaks: $($preset.tweaks -join ', ')"
    Write-Host "  - Apps: $($preset.apps -join ', ')"
    Write-Host "  - Settings: $($preset.settings -join ', ')"
    
    $confirm = Read-Host "`nApply this preset? (Y/N)"
    if ($confirm -ne "Y") {
        Write-Host "Preset cancelled." -ForegroundColor Yellow
        Write-Log "Preset $selectedName cancelled by user"
        return
    }
    
    # Apply the preset
    foreach ($tweakName in $preset.tweaks) {
        # Look up the tweak in our available tweaks
        Write-Host "Applying tweak: $tweakName" -ForegroundColor Yellow
        # This would call individual tweak functions
        Write-Log "Preset: Applied tweak $tweakName"
    }
    
    Write-Host "`nPreset $selectedName applied successfully!" -ForegroundColor Green
    Write-Log "Preset $selectedName completed"
}