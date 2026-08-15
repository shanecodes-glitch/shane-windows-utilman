<#
.SYNOPSIS
    ShaneCodes Windows Utilman - Single File Version
.DESCRIPTION
    A comprehensive system utility for installing software, applying tweaks, managing updates, and more.
    This file contains ALL functions inline for self-contained execution.
.EXAMPLE
    irm https://raw.githubusercontent.com/shanecodes-glitch/shane-windows-utilman/main/ShaneCodes-Utilman.ps1 | iex
.NOTES
    Author: Shane Nichael Obinguar
    Version: 1.0.2
#>

#Requires -RunAsAdministrator

#region [Logging Helper]
function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] [$Level] $Message"
    $global:LogPath = Join-Path $env:TEMP "ShaneCodes-Utilman.log"
    Add-Content -Path $global:LogPath -Value $logEntry -ErrorAction SilentlyContinue
    $color = switch ($Level) {
        "INFO"    { "White" }
        "WARNING" { "Yellow" }
        "ERROR"   { "Red" }
        default   { "White" }
    }
    Write-Host $logEntry -ForegroundColor $color
}
#endregion

#region [App Installation]
function Install-Apps {
    Write-Host "`n[Software Installation]" -ForegroundColor Cyan
    Write-Log "Started software installation menu"
    
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
#endregion

#region [System Tweaks]
function Apply-Tweaks {
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
                @{TweakName="Disable animations"; TweakPath="HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"; TweakValueName="VisualFXSetting"; TweakValue=2; TweakType="DWord"},
                @{TweakName="Disable transparency effects"; TweakPath="HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize"; TweakValueName="EnableTransparency"; TweakValue=0; TweakType="DWord"},
                @{TweakName="Disable startup delay"; TweakPath="HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Serialize"; TweakValueName="StartupDelayInMSec"; TweakValue=0; TweakType="DWord"}
            )
        }
        "2" {
            $tweaks += @(
                @{TweakName="Disable telemetry"; TweakPath="HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection"; TweakValueName="AllowTelemetry"; TweakValue=0; TweakType="DWord"},
                @{TweakName="Disable advertising ID"; TweakPath="HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo"; TweakValueName="Enabled"; TweakValue=0; TweakType="DWord"},
                @{TweakName="Disable Cortana"; TweakPath="HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search"; TweakValueName="AllowCortana"; TweakValue=0; TweakType="DWord"}
            )
        }
        "3" {
            $tweaks += @(
                @{TweakName="Enable dark mode (apps)"; TweakPath="HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize"; TweakValueName="AppsUseLightTheme"; TweakValue=0; TweakType="DWord"},
                @{TweakName="Enable dark mode (system)"; TweakPath="HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize"; TweakValueName="SystemUsesLightTheme"; TweakValue=0; TweakType="DWord"}
            )
        }
        "4" {
            $tweaks += @(
                @{TweakName="Show file extensions"; TweakPath="HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"; TweakValueName="HideFileExt"; TweakValue=0; TweakType="DWord"},
                @{TweakName="Show hidden files"; TweakPath="HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"; TweakValueName="Hidden"; TweakValue=1; TweakType="DWord"},
                @{TweakName="Show super hidden files"; TweakPath="HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"; TweakValueName="ShowSuperHidden"; TweakValue=1; TweakType="DWord"},
                @{TweakName="Show empty drives"; TweakPath="HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"; TweakValueName="ShowEmptyDrives"; TweakValue=1; TweakType="DWord"},
                @{TweakName="Show this PC instead of quick access"; TweakPath="HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"; TweakValueName="LaunchTo"; TweakValue=1; TweakType="DWord"}
            )
        }
        "5" {
            $tweaks += @(
                @{TweakName="Disable telemetry"; TweakPath="HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection"; TweakValueName="AllowTelemetry"; TweakValue=0; TweakType="DWord"},
                @{TweakName="Disable animations"; TweakPath="HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"; TweakValueName="VisualFXSetting"; TweakValue=2; TweakType="DWord"},
                @{TweakName="Show file extensions"; TweakPath="HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"; TweakValueName="HideFileExt"; TweakValue=0; TweakType="DWord"},
                @{TweakName="Show hidden files"; TweakPath="HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"; TweakValueName="Hidden"; TweakValue=1; TweakType="DWord"},
                @{TweakName="Enable dark mode (apps)"; TweakPath="HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize"; TweakValueName="AppsUseLightTheme"; TweakValue=0; TweakType="DWord"}
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
    Write-Log "Applying tweaks: $($tweaks.TweakName -join ', ')"
    
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
        Write-Host "Applying: $($tweak.TweakName)..." -ForegroundColor Yellow
        try {
            $parentPath = Split-Path $tweak.TweakPath -Parent
            if (-not (Test-Path $parentPath)) {
                New-Item -Path $parentPath -Force -ErrorAction SilentlyContinue | Out-Null
            }
            Set-ItemProperty -Path $tweak.TweakPath -Name $tweak.TweakValueName -Value $tweak.TweakValue -Type $tweak.TweakType -Force -ErrorAction Stop
            Write-Host "  ✓ $($tweak.TweakName) applied" -ForegroundColor Green
            Write-Log "Applied tweak: $($tweak.TweakName)"
            $successCount++
        } catch {
            Write-Host "  ✗ Failed to apply $($tweak.TweakName): $_" -ForegroundColor Red
            Write-Log "Failed tweak: $($tweak.TweakName) - $_" "ERROR"
        }
    }
    
    Write-Host "`n$successCount of $($tweaks.Count) tweaks applied successfully." -ForegroundColor Green
    Write-Host "Note: Some changes may require a restart to take effect." -ForegroundColor Yellow
    Write-Log "Tweak summary: $successCount/$($tweaks.Count) successful"
}
#endregion

#region [Update Manager]
function Update-Manager {
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
            Write-Host "Opening Windows Update in Settings..." -ForegroundColor Green
            Start-Process "ms-settings:windowsupdate-action"
            Write-Log "Opened Windows Update settings"
        }
        "3" {
            Write-Host "`n[Update Settings]" -ForegroundColor Cyan
            Write-Host "Select update behavior:`n"
            Write-Host "  1.  Automatic updates (recommended)"
            Write-Host "  2.  Notify before downloading"
            Write-Host "  3.  Never check for updates (not recommended)"
            $setting = Read-Host "`nEnter choice (1-3)"
            $auValue = switch ($setting) {
                "1" { 3 }
                "2" { 2 }
                "3" { 1 }
                default { 3 }
            }
            try {
                # Ensure parent key exists
                $parentPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU"
                if (-not (Test-Path $parentPath)) {
                    New-Item -Path $parentPath -Force | Out-Null
                }
                Set-ItemProperty -Path $parentPath -Name "AUOptions" -Value $auValue -Type DWord -Force
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
                    $History = $UpdateSearcher.QueryHistory(0, [Math]::Min($HistoryCount, 20))
                    $i = 1
                    foreach ($Entry in $History) {
                        Write-Host "$i. $($Entry.Title) - $($Entry.Date) - Status: $($Entry.ResultCode)"
                        $i++
                    }
                    if ($HistoryCount -gt 20) {
                        Write-Host "... and $($HistoryCount - 20) more entries" -ForegroundColor Yellow
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
#endregion

#region [System Information]
function Get-SystemInfo {
    Write-Host "`n[System Information]" -ForegroundColor Cyan
    Write-Log "Displayed system information"
    
    try {
        $computerInfo = Get-ComputerInfo
        $os = Get-CimInstance -ClassName Win32_OperatingSystem
        $cpu = Get-CimInstance -ClassName Win32_Processor
        $ram = Get-CimInstance -ClassName Win32_PhysicalMemory
        $disk = Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DriveType=3"
        $gpu = Get-CimInstance -ClassName Win32_VideoController | Where-Object { $_.Name -notlike "*Remote*" -and $_.Name -notlike "*Basic*" }
        
        Write-Host @"
╔═══════════════════════════════════════════════════════════════════╗
║                       SYSTEM INFORMATION                         ║
╠═══════════════════════════════════════════════════════════════════╣
║  OS NAME           : $($os.Caption)
║  OS VERSION        : $($os.Version) (Build $($os.BuildNumber))
║  OS ARCHITECTURE   : $($os.OSArchitecture)
║  INSTALL DATE      : $($os.InstallDate)
║  LAST BOOT         : $($os.LastBootUpTime)
║  COMPUTER NAME     : $($computerInfo.CsName)
║  DOMAIN            : $($computerInfo.CsDomain)
║  MANUFACTURER      : $($computerInfo.CsManufacturer)
║  MODEL             : $($computerInfo.CsModel)
╠═══════════════════════════════════════════════════════════════════╣
║  PROCESSOR         : $($cpu.Name)
║  CORES             : $($cpu.NumberOfCores)
║  LOGICAL PROCESSORS: $($cpu.NumberOfLogicalProcessors)
║  MAX CLOCK SPEED   : $($cpu.MaxClockSpeed) MHz
╠═══════════════════════════════════════════════════════════════════╣
║  TOTAL RAM         : $([math]::Round(($ram | Measure-Object -Property Capacity -Sum).Sum / 1GB, 2)) GB
║  RAM SLOTS USED    : $($ram.Count)
╠═══════════════════════════════════════════════════════════════════╣
"@
        foreach ($drive in $disk) {
            $freePercent = [math]::Round(($drive.FreeSpace / $drive.Size) * 100, 2)
            Write-Host "║  DRIVE $($drive.DeviceID) : $([math]::Round($drive.Size/1GB, 2)) GB total, $([math]::Round($drive.FreeSpace/1GB, 2)) GB free ($freePercent%)"
        }
        
        Write-Host @"
╠═══════════════════════════════════════════════════════════════════╣
║  GRAPHICS          : $($gpu[0].Name)
║  GPU MEMORY        : $([math]::Round($gpu[0].AdapterRAM / 1GB, 2)) GB (approx)
╠═══════════════════════════════════════════════════════════════════╣
║  SERIAL NUMBER     : $($os.SerialNumber)
║  USERNAME          : $env:USERNAME
║  USER DOMAIN       : $env:USERDOMAIN
╚═══════════════════════════════════════════════════════════════════╝
"@
    } catch {
        Write-Host "Error retrieving system information: $_" -ForegroundColor Red
        Write-Log "System info error: $_" "ERROR"
    }
}
#endregion

#region [Self-Update]
function Self-Update {
    Write-Host "`n[Self-Update]" -ForegroundColor Cyan
    Write-Log "Started self-update check"
    
    $remoteVersionUrl = "https://raw.githubusercontent.com/shanecodes-glitch/shane-windows-utilman/main/version.txt"
    $localVersion = "1.0.2"
    
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
        $remoteScriptUrl = "https://raw.githubusercontent.com/shanecodes-glitch/shane-windows-utilman/main/ShaneCodes-Utilman.ps1"
        $tempScript = Join-Path $env:TEMP "ShaneCodes-Utilman_updated.ps1"
        
        Invoke-WebRequest -Uri $remoteScriptUrl -OutFile $tempScript -UseBasicParsing -ErrorAction Stop
        
        Write-Host "Update downloaded. Please run the new version manually from: $tempScript" -ForegroundColor Green
        Write-Log "Self-update: Downloaded version $remoteVersion"
        Write-Host "`nThe update will be applied on next run." -ForegroundColor Yellow
        
    } catch {
        Write-Host "`nError checking for updates: $_" -ForegroundColor Red
        Write-Log "Self-update error: $_" "ERROR"
    }
}
#endregion

#region [Clean Temp Files]
function Clean-TempFiles {
    Write-Host "`n[Cleaning Temporary Files]" -ForegroundColor Cyan
    Write-Log "Starting temp files cleanup"
    
    $tempPaths = @(
        "$env:TEMP\*",
        "$env:WINDIR\Temp\*",
        "$env:WINDIR\Prefetch\*"
    )
    
    $deletedCount = 0
    $deletedSize = 0
    
    foreach ($path in $tempPaths) {
        if (Test-Path $path) {
            Get-ChildItem -Path $path -Recurse -Force -ErrorAction SilentlyContinue | ForEach-Object {
                try {
                    $size = $_.Length
                    Remove-Item -Path $_.FullName -Force -ErrorAction SilentlyContinue
                    $deletedCount++
                    $deletedSize += $size
                } catch {
                    # Skip files that can't be deleted
                }
            }
        }
    }
    
    Write-Host "Deleted $deletedCount files, freeing ~$([math]::Round($deletedSize/1MB, 2)) MB"
    Write-Log "Cleaned $deletedCount files ($([math]::Round($deletedSize/1MB, 2)) MB)"
}
#endregion

#region [View Log]
function View-Log {
    if (Test-Path $global:LogPath) {
        Get-Content $global:LogPath -Tail 50
    } else {
        Write-Host "No log file found at: $global:LogPath" -ForegroundColor Yellow
    }
}
#endregion

#region [Main Menu]
function Show-Menu {
    Clear-Host
    
    Write-Host @"
   _____  _   _  ____   _____         ____  _   _   ___   _   _   _____   __  __   _   _   _   _
  / ____|| | | ||  _ \ |  __ \       / __ \| \ | | / _ \ | \ | | |_   _| |  \/  | | \ | | | \ | |
 | (___  | |_| || |_) || |  | |     | |  | ||  \| || | | ||  \| |   | |   | \  / | |  \| | |  \| |
  \___ \ |  _  ||  _ < | |  | |     | |  | || . ` || | | || . ` |   | |   | |\/| | | . ` | | . ` |
  ____) || | | || |_) || |__| |     | |__| || |\  || |_| || |\  |  _| |_  | |  | | | |\  | | |\  |
 |_____/ |_| |_||____/ |_____/       \____/ |_| \_| \___/ |_| \_| |_____| |_|  |_| |_| \_| |_| \_|
                                                                                                    
═══════════════════════════════════════════════════════════════════════════════════════════════════════
  Your Windows, Your Control  |  Version 1.0.2  |  By Shane Nichael Obinguar
═══════════════════════════════════════════════════════════════════════════════════════════════════════
"@
    Write-Host "`n[MAIN MENU]`n"
    Write-Host "  1.  📦 Install Software"
    Write-Host "  2.  ⚡ Apply System Tweaks"
    Write-Host "  3.  🔧 Windows Update Manager"
    Write-Host "  4.  📊 View System Information"
    Write-Host "  5.  🔄 Self-Update Utilman"
    Write-Host "  6.  📜 View Log"
    Write-Host "  7.  🧹 Clean Up Temporary Files"
    Write-Host "  8.  ❌ Exit"
    Write-Host "`n───────────────────────────────────────────────────────────────────────────────────────"
    Write-Host "  NOTE: All changes can be reviewed in the log file: $global:LogPath"
    Write-Host "───────────────────────────────────────────────────────────────────────────────────────"
    
    $choice = Read-Host "`nEnter your choice (1-8)"
    
    switch ($choice) {
        "1" { Install-Apps }
        "2" { Apply-Tweaks }
        "3" { Update-Manager }
        "4" { Get-SystemInfo }
        "5" { Self-Update }
        "6" { View-Log }
        "7" { Clean-TempFiles }
        "8" { 
            Write-Host "`nExiting ShaneCodes Utilman. Goodbye!" -ForegroundColor Green
            Write-Log "User exited"
            exit 0
        }
        default {
            Write-Host "`nInvalid choice. Press any key to return to the menu..." -ForegroundColor Red
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
            Show-Menu
        }
    }
    
    Write-Host "`nPress any key to return to the main menu..."
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    Show-Menu
}
#endregion

#region [Launcher Entry Point]
# Check for Administrator rights
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Warning "This utility must be run as Administrator."
    Write-Warning "Please restart PowerShell as Administrator and try again."
    Write-Host "`nPress any key to exit..."
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit 1
}

# Initialize global variables
$global:LogPath = Join-Path $env:TEMP "ShaneCodes-Utilman.log"
$global:ToolVersion = "1.0.2"

Write-Log "ShaneCodes Utilman v$global:ToolVersion started"

# Launch the main menu directly (no external file dependencies)
try {
    Show-Menu
} catch {
    Write-Log "Fatal error in main menu: $_" "ERROR"
    Write-Host "`nAn error occurred. Please check the log at: $global:LogPath"
    Write-Host "`nPress any key to exit..."
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit 1
}

Write-Log "ShaneCodes Utilman finished"
#endregion