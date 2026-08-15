function Self-Update {
    <#
    .SYNOPSIS
        Checks for and applies updates to the utilman itself.
    .DESCRIPTION
        Compares the current version with the remote version and updates if newer.
    #>
    
    Write-Host "`n[Self-Update]" -ForegroundColor Cyan
    Write-Log "Started self-update check"
    
    $remoteVersionUrl = "$global:RepoURL/version.txt"
    $localVersion = $global:ToolVersion
    
    try {
        Write-Host "Checking for updates..." -ForegroundColor Green
        $remoteVersion = (Invoke-WebRequest -Uri $remoteVersionUrl -UseBasicParsing -ErrorAction Stop).Content.Trim()
        
        Write-Host "Local version: $localVersion" -ForegroundColor Yellow
        Write-Host "Remote version: $remoteVersion" -ForegroundColor Yellow
        
        if ($remoteVersion -eq $localVersion) {
            Write-Host "`nYou are already using the latest version." -ForegroundColor Green
            Write-Log "Self-update: Already latest ($localVersion)"
            return
        }
        
        Write-Host "`nA new version is available! ($remoteVersion)" -ForegroundColor Green
        $confirm = Read-Host "Do you want to update now? (Y/N)"
        
        if ($confirm -ne "Y") {
            Write-Host "Update cancelled." -ForegroundColor Yellow
            Write-Log "Self-update: Cancelled by user"
            return
        }
        
        Write-Host "`nDownloading update..." -ForegroundColor Green
        $remoteScriptUrl = "$global:RepoURL/ShaneCodes-Utilman.ps1"
        $tempScript = Join-Path $env:TEMP "ShaneCodes-Utilman_updated.ps1"
        
        Invoke-WebRequest -Uri $remoteScriptUrl -OutFile $tempScript -UseBasicParsing -ErrorAction Stop
        
        Write-Host "Update downloaded. Applying update..." -ForegroundColor Green
        Write-Log "Self-update: Downloaded version $remoteVersion"
        
        # Get the current script path
        $currentScript = $MyInvocation.MyCommand.Path
        
        # Overwrite the current script with the new version
        if (Test-Path $currentScript) {
            Copy-Item -Path $tempScript -Destination $currentScript -Force
            Write-Host "`nUpdate applied successfully!" -ForegroundColor Green
            Write-Log "Self-update: Applied version $remoteVersion"
        } else {
            Write-Host "`nCould not determine current script location. Please update manually." -ForegroundColor Red
            Write-Log "Self-update: Failed to locate current script" "ERROR"
            return
        }
        
        Write-Host "`nRestarting utilman with new version..." -ForegroundColor Green
        Write-Log "Self-update: Restarting"
        
        # Restart the updated script
        & $currentScript
        exit 0
        
    } catch {
        Write-Host "`nError checking for updates: $_" -ForegroundColor Red
        Write-Log "Self-update error: $_" "ERROR"
    }
}