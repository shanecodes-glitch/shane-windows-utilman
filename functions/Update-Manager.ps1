function Update-Manager {
    <#
    .SYNOPSIS
        Manages Windows Update settings and operations.
    .DESCRIPTION
        Provides options to check for updates, configure settings, and view update history.
    #>
    
    Write-Host "`n[Windows Update Manager]" -ForegroundColor Cyan
    Write-Log "Started update manager"
    
    Write-Host "`nSelect update action:`n"
    Write-Host "  1.  Check for updates"
    Write-Host "  2.  Install available updates"
    Write-Host "  3.  Configure update settings"
    Write-Host "  4.  View update history"
    Write-Host "  5.  Return to main menu"
    
    $choice = Read-Host "`nEnter your choice (1-5)"
    
    switch ($choice) {
        "1" {
            Write-Host "`nChecking for updates..." -ForegroundColor Green
            Write-Log "Checking for updates"
            try {
                $UpdateSession = New-Object -ComObject "Microsoft.Update.Session"
                $UpdateSearcher = $UpdateSession.CreateUpdateSearcher()
                $SearchResult = $UpdateSearcher.Search("IsInstalled=0 and Type='Software'")
                
                if ($SearchResult.Updates.Count -gt 0) {
                    Write-Host "`nFound $($SearchResult.Updates.Count) available updates:" -ForegroundColor Green
                    $i = 1
                    foreach ($Update in $SearchResult.Updates) {
                        Write-Host "  $i. $($Update.Title)"
                        $i++
                    }
                    Write-Log "Found $($SearchResult.Updates.Count) updates"
                } else {
                    Write-Host "`nNo updates available." -ForegroundColor Green
                    Write-Log "No updates found"
                }
            } catch {
                Write-Host "Error checking for updates: $_" -ForegroundColor Red
                Write-Log "Update check error: $_" "ERROR"
            }
        }
        "2" {
            Write-Host "`nInstalling updates... (This may take a while)" -ForegroundColor Green
            Write-Log "Starting update installation"
            try {
                $UpdateSession = New-Object -ComObject "Microsoft.Update.Session"
                $UpdateDownloader = $UpdateSession.CreateUpdateDownloader()
                $UpdateInstaller = $UpdateSession.CreateUpdateInstaller()
                
                # This is a simplified example - full implementation would need more handling
                Write-Host "Please use Windows Settings to install updates for reliability." -ForegroundColor Yellow
                Write-Host "Opening Windows Update in Settings..." -ForegroundColor Green
                Start-Process "ms-settings:windowsupdate-action"
                Write-Log "Opened Windows Update settings"
            } catch {
                Write-Host "Error installing updates: $_" -ForegroundColor Red
                Write-Log "Update installation error: $_" "ERROR"
            }
        }
        "3" {
            Write-Host "`n[Update Settings]" -ForegroundColor Cyan
            Write-Host "Select update behavior:`n"
            Write-Host "  1.  Automatic updates (recommended)"
            Write-Host "  2.  Notify before downloading"
            Write-Host "  3.  Never check for updates (not recommended)"
            
            $setting = Read-Host "`nEnter choice (1-3)"
            
            $auValue = switch ($setting) {
                "1" { 3 }  # Auto download and install
                "2" { 2 }  # Notify before download
                "3" { 1 }  # Never check
                default { 3 }
            }
            
            try {
                Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "AUOptions" -Value $auValue -Type DWord -Force
                Write-Host "`nUpdate settings applied." -ForegroundColor Green
                Write-Log "Updated AUOptions to $auValue"
            } catch {
                Write-Host "Error applying settings: $_" -ForegroundColor Red
                Write-Log "Error applying update settings: $_" "ERROR"
            }
        }
        "4" {
            Write-Host "`n[Update History]" -ForegroundColor Cyan
            try {
                $UpdateSession = New-Object -ComObject "Microsoft.Update.Session"
                $UpdateSearcher = $UpdateSession.CreateUpdateSearcher()
                $HistoryCount = $UpdateSearcher.GetTotalHistoryCount()
                
                if ($HistoryCount -gt 0) {
                    $History = $UpdateSearcher.QueryHistory(0, $HistoryCount)
                    $i = 1
                    foreach ($Entry in $History) {
                        Write-Host "$i. $($Entry.Title) - $($Entry.Date) - Status: $($Entry.ResultCode)"
                        $i++
                        if ($i -gt 20) { 
                            Write-Host "... and $($HistoryCount - 20) more entries" -ForegroundColor Yellow
                            break 
                        }
                    }
                    Write-Log "Viewed update history ($HistoryCount entries)"
                } else {
                    Write-Host "No update history found." -ForegroundColor Green
                }
            } catch {
                Write-Host "Error retrieving history: $_" -ForegroundColor Red
                Write-Log "Update history error: $_" "ERROR"
            }
        }
        "5" { return }
        default {
            Write-Host "Invalid choice." -ForegroundColor Red
        }
    }
}