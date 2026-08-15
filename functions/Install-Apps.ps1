function Install-Apps {
    <#
    .SYNOPSIS
        Installs a curated list of applications using winget.
    .DESCRIPTION
        Displays a list of popular apps and installs selected ones silently.
    #>
    
    Write-Host "`n[Software Installation]" -ForegroundColor Cyan
    Write-Log "Started software installation menu"
    
    # Check if winget is available
    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
        Write-Host "winget is not available. Please install App Installer from the Microsoft Store." -ForegroundColor Red
        Write-Log "winget not found" "ERROR"
        return
    }
    
    Write-Host "`nSelect applications to install (enter numbers separated by commas, e.g., 1,2,3):`n"
    
    $apps = @(
        @{Display="7-Zip"; Id="7zip.7zip"},
        @{Display="Google Chrome"; Id="Google.Chrome"},
        @{Display="Mozilla Firefox"; Id="Mozilla.Firefox"},
        @{Display="VLC Media Player"; Id="VideoLAN.VLC"},
        @{Display="Visual Studio Code"; Id="Microsoft.VisualStudioCode"},
        @{Display="Discord"; Id="Discord.Discord"},
        @{Display="Spotify"; Id="Spotify.Spotify"},
        @{Display="Notepad++"; Id="Notepad++.Notepad++"},
        @{Display="Git"; Id="Git.Git"},
        @{Display="OBS Studio"; Id="OBSProject.OBSStudio"},
        @{Display="ShareX"; Id="ShareX.ShareX"},
        @{Display="Everything"; Id="voidtools.Everything"}
    )
    
    for ($i = 0; $i -lt $apps.Count; $i++) {
        Write-Host "  $($i+1). $($apps[$i].Display)"
    }
    
    $input = Read-Host "`nEnter selection (or 'all' for all apps)"
    
    if ($input -eq "all") {
        $selectedApps = $apps
    } else {
        $selectedIndices = $input -split ',' | ForEach-Object { $_.Trim() }
        $selectedApps = @()
        foreach ($idx in $selectedIndices) {
            if ($idx -match '^\d+$' -and [int]$idx -ge 1 -and [int]$idx -le $apps.Count) {
                $selectedApps += $apps[[int]$idx - 1]
            }
        }
    }
    
    if ($selectedApps.Count -eq 0) {
        Write-Host "No valid apps selected." -ForegroundColor Yellow
        return
    }
    
    Write-Host "`nInstalling $($selectedApps.Count) application(s)...`n" -ForegroundColor Green
    Write-Log "Installing: $($selectedApps.Display -join ', ')"
    
    foreach ($app in $selectedApps) {
        Write-Host "Installing $($app.Display)..." -ForegroundColor Yellow
        try {
            $result = winget install --id $app.Id --silent --accept-package-agreements 2>&1
            if ($LASTEXITCODE -eq 0) {
                Write-Host "  ✓ $($app.Display) installed successfully" -ForegroundColor Green
                Write-Log "Installed $($app.Display) ($($app.Id))"
            } else {
                Write-Host "  ✗ Failed to install $($app.Display)" -ForegroundColor Red
                Write-Log "Failed to install $($app.Display): $result" "ERROR"
            }
        } catch {
            Write-Host "  ✗ Error installing $($app.Display): $_" -ForegroundColor Red
            Write-Log "Error installing $($app.Display): $_" "ERROR"
        }
    }
    
    Write-Host "`nInstallation complete." -ForegroundColor Green
}