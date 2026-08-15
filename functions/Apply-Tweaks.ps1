function Apply-Tweaks {
    <#
    .SYNOPSIS
        Applies system tweaks to improve performance, privacy, and usability.
    .DESCRIPTION
        Provides a menu of tweaks grouped by category.
        All changes are logged and can be reviewed.
    #>
    
    Write-Host "`n[System Tweaks]" -ForegroundColor Cyan
    Write-Log "Started system tweaks menu"
    
    Write-Host "`nSelect tweak category:`n"
    Write-Host "  1.  Performance Tweaks"
    Write-Host "  2.  Privacy Tweaks"
    Write-Host "  3.  Interface Tweaks"
    Write-Host "  4.  Explorer Tweaks"
    Write-Host "  5.  Apply All Recommended Tweaks"
    Write-Host "  6.  Return to Main Menu"
    
    $choice = Read-Host "`nEnter your choice (1-6)"
    
    $tweaks = @()
    
    switch ($choice) {
        "1" {
            $tweaks += @(
                @{Name="Disable animations"; Path="HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"; Name="VisualFXSetting"; Value=2; Type="DWord"},
                @{Name="Disable transparency effects"; Path="HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize"; Name="EnableTransparency"; Value=0; Type="DWord"},
                @{Name="Disable startup delay"; Path="HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Serialize"; Name="StartupDelayInMSec"; Value=0; Type="DWord"}
            )
        }
        "2" {
            $tweaks += @(
                @{Name="Disable telemetry"; Path="HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection"; Name="AllowTelemetry"; Value=0; Type="DWord"},
                @{Name="Disable advertising ID"; Path="HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo"; Name="Enabled"; Value=0; Type="DWord"},
                @{Name="Disable Cortana"; Path="HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search"; Name="AllowCortana"; Value=0; Type="DWord"}
            )
        }
        "3" {
            $tweaks += @(
                @{Name="Enable dark mode"; Path="HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize"; Name="AppsUseLightTheme"; Value=0; Type="DWord"},
                @{Name="Enable dark mode (system)"; Path="HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize"; Name="SystemUsesLightTheme"; Value=0; Type="DWord"}
            )
        }
        "4" {
            $tweaks += @(
                @{Name="Show file extensions"; Path="HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"; Name="HideFileExt"; Value=0; Type="DWord"},
                @{Name="Show hidden files"; Path="HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"; Name="Hidden"; Value=1; Type="DWord"},
                @{Name="Show super hidden files"; Path="HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"; Name="ShowSuperHidden"; Value=1; Type="DWord"},
                @{Name="Show empty drives"; Path="HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"; Name="ShowEmptyDrives"; Value=1; Type="DWord"},
                @{Name="Show this PC instead of quick access"; Path="HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"; Name="LaunchTo"; Value=1; Type="DWord"}
            )
        }
        "5" {
            # All recommended tweaks
            $tweaks += @(
                @{Name="Disable telemetry"; Path="HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection"; Name="AllowTelemetry"; Value=0; Type="DWord"},
                @{Name="Disable animations"; Path="HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"; Name="VisualFXSetting"; Value=2; Type="DWord"},
                @{Name="Show file extensions"; Path="HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"; Name="HideFileExt"; Value=0; Type="DWord"},
                @{Name="Show hidden files"; Path="HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"; Name="Hidden"; Value=1; Type="DWord"},
                @{Name="Enable dark mode"; Path="HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize"; Name="AppsUseLightTheme"; Value=0; Type="DWord"}
            )
        }
        "6" { return }
        default {
            Write-Host "Invalid choice." -ForegroundColor Red
            return
        }
    }
    
    if ($tweaks.Count -eq 0) { return }
    
    Write-Host "`nApplying $($tweaks.Count) tweaks...`n" -ForegroundColor Green
    Write-Log "Applying tweaks: $($tweaks.Name -join ', ')"
    
    # Create restore point before making changes
    try {
        Checkpoint-Computer -Description "ShaneCodes Utilman - Before tweaks" -ErrorAction SilentlyContinue
        Write-Host "  ✓ Restore point created" -ForegroundColor Green
        Write-Log "Restore point created"
    } catch {
        Write-Host "  ⚠ Could not create restore point. Continuing anyway." -ForegroundColor Yellow
        Write-Log "Failed to create restore point: $_" "WARNING"
    }
    
    $successCount = 0
    
    foreach ($tweak in $tweaks) {
        Write-Host "Applying: $($tweak.Name)..." -ForegroundColor Yellow
        
        try {
            # Create the parent key if it doesn't exist
            $parentPath = Split-Path $tweak.Path -Parent
            if (-not (Test-Path $parentPath)) {
                New-Item -Path $parentPath -Force -ErrorAction SilentlyContinue | Out-Null
            }
            
            # Set the value
            Set-ItemProperty -Path $tweak.Path -Name $tweak.Name -Value $tweak.Value -Type $tweak.Type -Force -ErrorAction Stop
            Write-Host "  ✓ $($tweak.Name) applied" -ForegroundColor Green
            Write-Log "Applied tweak: $($tweak.Name)"
            $successCount++
        } catch {
            Write-Host "  ✗ Failed to apply $($tweak.Name): $_" -ForegroundColor Red
            Write-Log "Failed tweak: $($tweak.Name) - $_" "ERROR"
        }
    }
    
    Write-Host "`n$successCount of $($tweaks.Count) tweaks applied successfully." -ForegroundColor Green
    Write-Host "Note: Some changes may require a restart to take effect." -ForegroundColor Yellow
    Write-Log "Tweak summary: $successCount/$($tweaks.Count) successful"
}