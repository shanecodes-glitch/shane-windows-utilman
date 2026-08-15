<#
    .SYNOPSIS
        ShaneCodes Windows Utilman - A complete Windows system utility
        with software installation, system tweaks, and update management.
    
    .DESCRIPTION
        A comprehensive system management tool that connects to YOUR
        repositories for software installations, system tweaks, and updates.
        This script serves as the foundation for your custom utility.
    
    .AUTHOR
        ShaneCodes
        Repository: https://github.com/shanecodes-glitch/shane-windows-utilman
    
    .VERSION
        1.0.0
    
    .NOTES
        This script must be run as Administrator.
        Last Updated: 2024-2026
#>

#Requires -RunAsAdministrator

# ============================================================
# GLOBAL CONFIGURATION
# ============================================================

# THESE URLS ARE NOW CONFIGURED FOR YOUR REPOSITORY!
# ============================================================
$global:SCWU_Config = @{
    # Your GitHub raw URLs - NOW POINTING TO YOUR REPO
    BaseUrl = "https://raw.githubusercontent.com/shanecodes-glitch/shane-windows-utilman/main/"
    
    # Configuration files
    ConfigFile   = "config/scwu-config.json"
    SoftwareFile = "config/software-list.json"
    TweakFile    = "config/tweaks.json"
    
    # Update files
    VersionFile  = "version.txt"
    ScriptFile   = "ShaneCodes-Utilman.ps1"
}

# Build full URLs
$global:SCWU_Config.Urls = @{
    Config   = "$($global:SCWU_Config.BaseUrl)$($global:SCWU_Config.ConfigFile)"
    Software = "$($global:SCWU_Config.BaseUrl)$($global:SCWU_Config.SoftwareFile)"
    Tweaks   = "$($global:SCWU_Config.BaseUrl)$($global:SCWU_Config.TweakFile)"
    Version  = "$($global:SCWU_Config.BaseUrl)$($global:SCWU_Config.VersionFile)"
    Script   = "$($global:SCWU_Config.BaseUrl)$($global:SCWU_Config.ScriptFile)"
}

# Local fallback configuration
$global:LocalConfigPath = "$env:APPDATA\ShaneCodes\Utilman\config.json"
$global:LocalLogPath    = "$env:APPDATA\ShaneCodes\Utilman\logs\"

# ============================================================
# LOGGING FUNCTIONS
# ============================================================

function Write-SCWULog {
    param(
        [string]$Message,
        [string]$Level = "INFO"
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] [$Level] $Message"
    
    # Ensure log directory exists
    if (-not (Test-Path $global:LocalLogPath)) {
        New-Item -ItemType Directory -Path $global:LocalLogPath -Force | Out-Null
    }
    
    $logFile = Join-Path $global:LocalLogPath "scwu-$(Get-Date -Format 'yyyy-MM-dd').log"
    Add-Content -Path $logFile -Value $logEntry
    
    # Also output to console with color
    switch ($Level) {
        "INFO"    { Write-Host $Message -ForegroundColor Cyan }
        "SUCCESS" { Write-Host $Message -ForegroundColor Green }
        "WARNING" { Write-Host $Message -ForegroundColor Yellow }
        "ERROR"   { Write-Host $Message -ForegroundColor Red }
        default   { Write-Host $Message }
    }
}

# ============================================================
# CONFIGURATION MANAGEMENT
# ============================================================

function Get-SCWUConfiguration {
    <#
    .SYNOPSIS
        Retrieves configuration from remote or local source
    .DESCRIPTION
        Attempts to fetch configuration from your GitHub repository.
        Falls back to local configuration if remote is unavailable.
    #>
    
    Write-SCWULog "Loading ShaneCodes Utilman configuration..." -Level "INFO"
    
    $config = $null
    
    # Try to load from remote source first
    try {
        $remoteConfig = Invoke-RestMethod -Uri $global:SCWU_Config.Urls.Config -ErrorAction Stop
        Write-SCWULog "Configuration loaded from remote source" -Level "SUCCESS"
        $config = $remoteConfig
    } catch {
        Write-SCWULog "Remote configuration unavailable: $($_.Exception.Message)" -Level "WARNING"
        
        # Fallback to local configuration
        if (Test-Path $global:LocalConfigPath) {
            try {
                $localConfig = Get-Content -Path $global:LocalConfigPath -Raw | ConvertFrom-Json
                Write-SCWULog "Configuration loaded from local cache" -Level "SUCCESS"
                $config = $localConfig
            } catch {
                Write-SCWULog "Local configuration corrupt or missing" -Level "ERROR"
            }
        }
    }
    
    # If still no config, use hardcoded defaults
    if (-not $config) {
        Write-SCWULog "Using default configuration" -Level "WARNING"
        $config = [PSCustomObject]@{
            version = "1.0.0"
            author = "ShaneCodes"
            utility_name = "ShaneCodes Windows Utilman"
            software_categories = @("Productivity", "Development", "Multimedia", "Utilities", "Communication")
        }
    }
    
    return $config
}

# ============================================================
# MENU SYSTEM
# ============================================================

function Show-SCWUMenu {
    <#
    .SYNOPSIS
        Displays the main interactive menu
    .DESCRIPTION
        Presents a user-friendly menu for navigating the utility's features.
    #>
    
    Clear-Host
    
    # Draw the ASCII header
    Write-Host "╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║                                                                ║" -ForegroundColor Cyan
    Write-Host "║    ███████╗██╗  ██╗ █████╗ ███╗   ██╗███████╗                  ║" -ForegroundColor Yellow
    Write-Host "║    ██╔════╝██║  ██║██╔══██╗████╗  ██║██╔════╝                  ║" -ForegroundColor Yellow
    Write-Host "║    ███████╗███████║███████║██╔██╗ ██║█████╗                    ║" -ForegroundColor Yellow
    Write-Host "║    ╚════██║██╔══██║██╔══██║██║╚██╗██║██╔══╝                    ║" -ForegroundColor Yellow
    Write-Host "║    ███████║██║  ██║██║  ██║██║ ╚████║███████╗                  ║" -ForegroundColor Yellow
    Write-Host "║    ╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝╚══════╝                  ║" -ForegroundColor Yellow
    Write-Host "║      Windows Utilman - Your System, Your Control              ║" -ForegroundColor White
    Write-Host "║                                                                ║" -ForegroundColor Cyan
    Write-Host "╚════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""
    
    Write-Host "  [1] 📦 Install Software" -ForegroundColor White
    Write-Host "  [2] ⚡ Apply System Tweaks" -ForegroundColor White
    Write-Host "  [3] 🔧 Configure Windows Updates" -ForegroundColor White
    Write-Host "  [4] 📊 System Information" -ForegroundColor White
    Write-Host "  [5] 🔄 Update Utilman" -ForegroundColor White
    Write-Host "  [6] ❌ Exit" -ForegroundColor White
    Write-Host ""
    Write-Host "  [7] ⚙️ Advanced Options" -ForegroundColor Gray
    Write-Host ""
}

# ============================================================
# SOFTWARE INSTALLATION
# ============================================================

function Install-SCWUSoftware {
    <#
    .SYNOPSIS
        Installs software from your custom repository
    .DESCRIPTION
        Fetches software list from your GitHub repository and
        provides an interactive installation menu.
    #>
    
    Write-SCWULog "Starting software installation module" -Level "INFO"
    
    # Fetch software list
    $softwareList = $null
    try {
        $softwareList = Invoke-RestMethod -Uri $global:SCWU_Config.Urls.Software -ErrorAction Stop
        Write-SCWULog "Software list retrieved successfully" -Level "SUCCESS"
    } catch {
        Write-SCWULog "Failed to retrieve software list: $($_.Exception.Message)" -Level "ERROR"
        Write-SCWULog "Please check your internet connection and repository URL" -Level "WARNING"
        
        # Check if we have a local cache
        $cachePath = "$env:APPDATA\ShaneCodes\Utilman\cache\software.json"
        if (Test-Path $cachePath) {
            Write-SCWULog "Loading cached software list" -Level "INFO"
            $softwareList = Get-Content -Path $cachePath -Raw | ConvertFrom-Json
        } else {
            Write-SCWULog "No software cache found. Returning to menu." -Level "ERROR"
            return
        }
    }
    
    # Display software categories
    Write-Host "`n📦 Available Software Categories:" -ForegroundColor Yellow
    
    # Get categories from configuration or default
    $config = Get-SCWUConfiguration
    $categories = if ($config.software_categories) { $config.software_categories } else { @("Productivity", "Development", "Multimedia", "Utilities", "Communication") }
    
    $index = 0
    $categoryMap = @{}
    foreach ($category in $categories) {
        $index++
        Write-Host "  [$index] $category" -ForegroundColor White
        $categoryMap[$index] = $category
    }
    Write-Host "  [0] Show All Software" -ForegroundColor Gray
    
    $catChoice = Read-Host "`nSelect a category (number)"
    
    # Filter software by category
    $selectedCategory = $null
    if ($catChoice -ne '0' -and $categoryMap.ContainsKey([int]$catChoice)) {
        $selectedCategory = $categoryMap[[int]$catChoice]
        Write-Host "`n📂 Category: $selectedCategory" -ForegroundColor Cyan
    } else {
        Write-Host "`n📂 Showing all available software" -ForegroundColor Cyan
    }
    
    # Display software in the selected category
    $filteredSoftware = @()
    if ($selectedCategory) {
        $filteredSoftware = $softwareList | Where-Object { $_.category -eq $selectedCategory }
    } else {
        $filteredSoftware = $softwareList
    }
    
    if ($filteredSoftware.Count -eq 0) {
        Write-Host "No software found in this category." -ForegroundColor Yellow
        return
    }
    
    Write-Host "`nAvailable Software:" -ForegroundColor Yellow
    $softwareIndex = 0
    $softwareMap = @{}
    foreach ($item in $filteredSoftware) {
        $softwareIndex++
        Write-Host "  [$softwareIndex] $($item.name)" -ForegroundColor White
        Write-Host "        $($item.description)" -ForegroundColor Gray
        $softwareMap[$softwareIndex] = $item
    }
    
    $selection = Read-Host "`nEnter numbers to install (comma separated, or 'all'): "
    
    if ($selection -eq 'all') {
        foreach ($item in $filteredSoftware) {
            Install-SCWUSingleSoftware $item
        }
    } else {
        $selections = $selection -split ',' | ForEach-Object { $_.Trim() }
        foreach ($num in $selections) {
            if ($softwareMap.ContainsKey([int]$num)) {
                Install-SCWUSingleSoftware $softwareMap[[int]$num]
            } else {
                Write-SCWULog "Invalid selection: $num" -Level "WARNING"
            }
        }
    }
    
    # Cache the software list for offline use
    $cacheDir = "$env:APPDATA\ShaneCodes\Utilman\cache"
    if (-not (Test-Path $cacheDir)) {
        New-Item -ItemType Directory -Path $cacheDir -Force | Out-Null
    }
    $softwareList | ConvertTo-Json -Depth 3 | Out-File -FilePath "$cacheDir\software.json" -Encoding UTF8
}

function Install-SCWUSingleSoftware {
    param(
        [PSCustomObject]$Software
    )
    
    Write-SCWULog "Installing: $($Software.name)" -Level "INFO"
    
    # Determine installation method
    $installed = $false
    
    # Method 1: Winget (Windows Package Manager)
    if ($Software.winget_id -and (Get-Command winget -ErrorAction SilentlyContinue)) {
        try {
            Write-SCWULog "Installing via Winget: $($Software.winget_id)" -Level "INFO"
            winget install $Software.winget_id --silent --accept-package-agreements
            $installed = $true
        } catch {
            Write-SCWULog "Winget installation failed: $($_.Exception.Message)" -Level "WARNING"
        }
    }
    
    # Method 2: Chocolatey
    if (-not $installed -and $Software.choco_id -and (Get-Command choco -ErrorAction SilentlyContinue)) {
        try {
            Write-SCWULog "Installing via Chocolatey: $($Software.choco_id)" -Level "INFO"
            choco install $Software.choco_id -y
            $installed = $true
        } catch {
            Write-SCWULog "Chocolatey installation failed: $($_.Exception.Message)" -Level "WARNING"
        }
    }
    
    # Method 3: Direct download
    if (-not $installed -and $Software.download_url) {
        try {
            Write-SCWULog "Downloading installer: $($Software.download_url)" -Level "INFO"
            $installerPath = "$env:TEMP\$($Software.name -replace ' ', '_')_installer.exe"
            Invoke-WebRequest -Uri $Software.download_url -OutFile $installerPath -ErrorAction Stop
            
            if ($Software.silent_args) {
                Write-SCWULog "Running silent install: $($Software.silent_args)" -Level "INFO"
                Start-Process -FilePath $installerPath -ArgumentList $Software.silent_args -Wait
            } else {
                Write-SCWULog "Running installer (manual interaction required)" -Level "INFO"
                Start-Process -FilePath $installerPath -Wait
            }
            $installed = $true
        } catch {
            Write-SCWULog "Direct download installation failed: $($_.Exception.Message)" -Level "ERROR"
        }
    }
    
    if ($installed) {
        Write-SCWULog "Successfully installed: $($Software.name)" -Level "SUCCESS"
    } else {
        Write-SCWULog "Failed to install: $($Software.name)" -Level "ERROR"
        Write-SCWULog "Please install this software manually." -Level "WARNING"
    }
}

# ============================================================
# SYSTEM TWEAKS
# ============================================================

function Apply-SCWUTweaks {
    <#
    .SYNOPSIS
        Applies system tweaks from your custom configuration
    .DESCRIPTION
        Retrieves tweak definitions from your repository and
        applies them to the Windows system.
    #>
    
    Write-SCWULog "Starting system tweaks module" -Level "INFO"
    
    # Fetch tweaks list
    $tweakData = $null
    try {
        $tweakData = Invoke-RestMethod -Uri $global:SCWU_Config.Urls.Tweaks -ErrorAction Stop
        Write-SCWULog "Tweaks retrieved successfully" -Level "SUCCESS"
    } catch {
        Write-SCWULog "Failed to retrieve tweaks: $($_.Exception.Message)" -Level "ERROR"
        return
    }
    
    # Display tweak categories
    Write-Host "`n⚡ Available Tweak Categories:" -ForegroundColor Yellow
    
    $categories = $tweakData.PSObject.Properties.Name
    $index = 0
    $categoryMap = @{}
    foreach ($category in $categories) {
        $index++
        Write-Host "  [$index] $category" -ForegroundColor White
        if ($tweakData.$category.description) {
            Write-Host "        $($tweakData.$category.description)" -ForegroundColor Gray
        }
        $categoryMap[$index] = $category
    }
    
    $catChoice = Read-Host "`nSelect a tweak category (number)"
    
    if ($categoryMap.ContainsKey([int]$catChoice)) {
        $selectedCategory = $categoryMap[[int]$catChoice]
        $tweaks = $tweakData.$selectedCategory.tweaks
        
        Write-Host "`n📂 Category: $selectedCategory" -ForegroundColor Cyan
        Write-Host "Available tweaks in this category:" -ForegroundColor Yellow
        
        $tweakIndex = 0
        $tweakMap = @{}
        foreach ($tweak in $tweaks) {
            $tweakIndex++
            Write-Host "  [$tweakIndex] $($tweak.name)" -ForegroundColor White
            Write-Host "        $($tweak.description)" -ForegroundColor Gray
            $tweakMap[$tweakIndex] = $tweak
        }
        
        $selection = Read-Host "`nEnter numbers to apply (comma separated, or 'all'): "
        
        $selectedTweaks = @()
        if ($selection -eq 'all') {
            $selectedTweaks = $tweaks
        } else {
            $selections = $selection -split ',' | ForEach-Object { $_.Trim() }
            foreach ($num in $selections) {
                if ($tweakMap.ContainsKey([int]$num)) {
                    $selectedTweaks += $tweakMap[[int]$num]
                }
            }
        }
        
        # Apply selected tweaks
        foreach ($tweak in $selectedTweaks) {
            Apply-SCWUSingleTweak $tweak
        }
        
        Write-SCWULog "Tweak application complete" -Level "SUCCESS"
        Write-Host "`nSome changes may require a reboot to take effect." -ForegroundColor Yellow
    } else {
        Write-SCWULog "Invalid category selection" -Level "WARNING"
    }
}

function Apply-SCWUSingleTweak {
    param(
        [PSCustomObject]$Tweak
    )
    
    Write-SCWULog "Applying tweak: $($Tweak.name)" -Level "INFO"
    
    switch ($Tweak.type) {
        "Registry" {
            try {
                # Ensure registry path exists
                $regPath = $Tweak.registry_path
                if ($regPath -match '^HKCU:') {
                    # User-specific tweak
                    if (-not (Test-Path $regPath)) {
                        New-Item -Path $regPath -Force | Out-Null
                    }
                } elseif ($regPath -match '^HKLM:') {
                    # System-wide tweak (requires admin)
                    if (-not (Test-Path $regPath)) {
                        New-Item -Path $regPath -Force | Out-Null
                    }
                }
                
                # Set registry value
                Set-ItemProperty -Path $Tweak.registry_path -Name $Tweak.value_name -Value $Tweak.value_data -Type $Tweak.value_type -Force
                Write-SCWULog "Registry tweak applied: $($Tweak.name)" -Level "SUCCESS"
            } catch {
                Write-SCWULog "Failed to apply registry tweak: $($_.Exception.Message)" -Level "ERROR"
            }
        }
        
        "Service" {
            try {
                $serviceName = $Tweak.service_name
                switch ($Tweak.action) {
                    "Disable" {
                        Stop-Service -Name $serviceName -Force -ErrorAction SilentlyContinue
                        Set-Service -Name $serviceName -StartupType Disabled
                        Write-SCWULog "Service disabled: $serviceName" -Level "SUCCESS"
                    }
                    "Enable" {
                        Set-Service -Name $serviceName -StartupType Automatic
                        Start-Service -Name $serviceName -ErrorAction SilentlyContinue
                        Write-SCWULog "Service enabled: $serviceName" -Level "SUCCESS"
                    }
                }
            } catch {
                Write-SCWULog "Failed to modify service: $($_.Exception.Message)" -Level "ERROR"
            }
        }
        
        "PowerShell" {
            try {
                Invoke-Expression $Tweak.script
                Write-SCWULog "PowerShell tweak applied: $($Tweak.name)" -Level "SUCCESS"
            } catch {
                Write-SCWULog "Failed to apply PowerShell tweak: $($_.Exception.Message)" -Level "ERROR"
            }
        }
        
        default {
            Write-SCWULog "Unknown tweak type: $($Tweak.type)" -Level "WARNING"
        }
    }
}

# ============================================================
# WINDOWS UPDATE MANAGEMENT
# ============================================================

function Manage-SCWUUpdates {
    <#
    .SYNOPSIS
        Manages Windows Update configuration
    .DESCRIPTION
        Provides options for configuring Windows Update settings
        and checking for updates.
    #>
    
    Write-SCWULog "Starting Windows Update management" -Level "INFO"
    
    Write-Host "`n🔧 Windows Update Configuration:" -ForegroundColor Yellow
    Write-Host "  [1] Check for updates now"
    Write-Host "  [2] Configure update settings"
    Write-Host "  [3] View update history"
    Write-Host "  [4] Return to main menu"
    
    $choice = Read-Host "`nSelect an option (1-4)"
    
    switch ($choice) {
        '1' {
            Write-SCWULog "Checking for Windows Updates..." -Level "INFO"
            try {
                $updateSession = New-Object -ComObject Microsoft.Update.Session
                $updateSearcher = $updateSession.CreateUpdateSearcher()
                $searchResult = $updateSearcher.Search("IsInstalled=0")
                
                if ($searchResult.Updates.Count -eq 0) {
                    Write-Host "No updates available." -ForegroundColor Green
                } else {
                    Write-Host "Found $($searchResult.Updates.Count) available updates:" -ForegroundColor Yellow
                    $i = 1
                    foreach ($update in $searchResult.Updates) {
                        Write-Host "  [$i] $($update.Title)" -ForegroundColor White
                        $i++
                    }
                    
                    $installChoice = Read-Host "`nInstall all available updates? (y/n)"
                    if ($installChoice -eq 'y') {
                        $downloader = $updateSession.CreateUpdateDownloader()
                        $downloader.Updates = $searchResult.Updates
                        $downloadResult = $downloader.Download()
                        
                        if ($downloadResult.ResultCode -eq 2) { # Downloaded
                            $installer = $updateSession.CreateUpdateInstaller()
                            $installer.Updates = $searchResult.Updates
                            $installResult = $installer.Install()
                            Write-SCWULog "Updates installed: $($installResult.InstalledUpdates.Count)" -Level "SUCCESS"
                        }
                    }
                }
            } catch {
                Write-SCWULog "Failed to check for updates: $($_.Exception.Message)" -Level "ERROR"
            }
        }
        '2' {
            Write-Host "`nUpdate Settings Configuration:" -ForegroundColor Yellow
            Write-Host "  [1] Set to Automatic (Recommended)"
            Write-Host "  [2] Set to Notify before download"
            Write-Host "  [3] Set to Never check for updates"
            
            $settingChoice = Read-Host "`nSelect option (1-3)"
            
            $regPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU"
            switch ($settingChoice) {
                '1' {
                    Set-ItemProperty -Path $regPath -Name "AUOptions" -Value 4 -Type DWord -Force
                    Set-ItemProperty -Path $regPath -Name "ScheduledInstallDay" -Value 0 -Type DWord -Force
                    Write-Host "Automatic updates enabled." -ForegroundColor Green
                }
                '2' {
                    Set-ItemProperty -Path $regPath -Name "AUOptions" -Value 3 -Type DWord -Force
                    Write-Host "Notifications enabled." -ForegroundColor Green
                }
                '3' {
                    Set-ItemProperty -Path $regPath -Name "AUOptions" -Value 1 -Type DWord -Force
                    Write-Host "Automatic updates disabled." -ForegroundColor Yellow
                }
            }
        }
        '3' {
            Write-Host "`nUpdate History:" -ForegroundColor Yellow
            try {
                $updateSession = New-Object -ComObject Microsoft.Update.Session
                $updateSearcher = $updateSession.CreateUpdateSearcher()
                $historyCount = $updateSearcher.GetTotalHistoryCount()
                $history = $updateSearcher.QueryHistory(0, [Math]::Min(20, $historyCount))
                
                if ($historyCount -eq 0) {
                    Write-Host "No update history found." -ForegroundColor Gray
                } else {
                    Write-Host "Last $([Math]::Min(20, $historyCount)) updates:" -ForegroundColor Cyan
                    foreach ($item in $history) {
                        $status = @("Failed", "Succeeded", "Cancelled")[$item.ResultCode]
                        Write-Host "  [$status] $($item.Title)" -ForegroundColor White
                    }
                }
            } catch {
                Write-SCWULog "Failed to retrieve update history: $($_.Exception.Message)" -Level "ERROR"
            }
        }
        '4' { return }
        default { Write-Host "Invalid option." -ForegroundColor Red }
    }
}

# ============================================================
# SYSTEM INFORMATION
# ============================================================

function Show-SCWUSystemInfo {
    <#
    .SYNOPSIS
        Displays detailed system information
    .DESCRIPTION
        Retrieves and displays comprehensive system information.
    #>
    
    Write-SCWULog "Gathering system information" -Level "INFO"
    
    Clear-Host
    Write-Host "╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║                    SYSTEM INFORMATION                          ║" -ForegroundColor Cyan
    Write-Host "╚════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""
    
    # OS Information
    $os = Get-CimInstance -ClassName Win32_OperatingSystem
    Write-Host "  Operating System:" -ForegroundColor Yellow
    Write-Host "    $($os.Caption) $($os.Version)" -ForegroundColor White
    Write-Host "    Build: $($os.BuildNumber)" -ForegroundColor Gray
    Write-Host ""
    
    # Hardware Information
    $computer = Get-CimInstance -ClassName Win32_ComputerSystem
    Write-Host "  Hardware:" -ForegroundColor Yellow
    Write-Host "    Manufacturer: $($computer.Manufacturer)" -ForegroundColor White
    Write-Host "    Model: $($computer.Model)" -ForegroundColor White
    Write-Host "    Total RAM: $([math]::Round($computer.TotalPhysicalMemory / 1GB, 2)) GB" -ForegroundColor White
    Write-Host ""
    
    # Processor Information
    $cpu = Get-CimInstance -ClassName Win32_Processor
    Write-Host "  Processor:" -ForegroundColor Yellow
    Write-Host "    Name: $($cpu.Name)" -ForegroundColor White
    Write-Host "    Cores: $($cpu.NumberOfCores)" -ForegroundColor White
    Write-Host "    Logical Processors: $($cpu.NumberOfLogicalProcessors)" -ForegroundColor White
    Write-Host ""
    
    # Disk Information
    Write-Host "  Storage:" -ForegroundColor Yellow
    $drives = Get-PSDrive -PSProvider FileSystem
    foreach ($drive in $drives) {
        if ($drive.Used -gt 0) {
            $usedGB = [math]::Round($drive.Used / 1GB, 2)
            $freeGB = [math]::Round($drive.Free / 1GB, 2)
            $totalGB = [math]::Round(($drive.Used + $drive.Free) / 1GB, 2)
            Write-Host "    $($drive.Name): $usedGB GB used / $freeGB GB free / $totalGB GB total" -ForegroundColor White
        }
    }
    Write-Host ""
    
    # Network Information
    Write-Host "  Network:" -ForegroundColor Yellow
    $adapters = Get-NetAdapter -Physical | Where-Object { $_.Status -eq 'Up' }
    foreach ($adapter in $adapters) {
        $ip = (Get-NetIPAddress -InterfaceIndex $adapter.InterfaceIndex -AddressFamily IPv4 | Where-Object { $_.AddressState -eq 'Preferred' }).IPAddress
        Write-Host "    $($adapter.Name): $ip" -ForegroundColor White
    }
    Write-Host ""
    
    # BIOS Information
    $bios = Get-CimInstance -ClassName Win32_BIOS
    Write-Host "  BIOS:" -ForegroundColor Yellow
    Write-Host "    Version: $($bios.SMBIOSBIOSVersion)" -ForegroundColor White
    Write-Host "    Serial: $($bios.SerialNumber)" -ForegroundColor White
    Write-Host ""
    
    # Utilman Status
    Write-Host "  ShaneCodes Utilman:" -ForegroundColor Yellow
    Write-Host "    Version: $($global:SCWU_Config.Version -replace '\.ps1$', '')" -ForegroundColor White
    Write-Host "    Config: $(if (Test-Path $global:LocalConfigPath) { 'Local cached' } else { 'Remote' })" -ForegroundColor White
    Write-Host "    Logs: $global:LocalLogPath" -ForegroundColor Gray
    
    Write-Host "`nPress any key to continue..."
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}

# ============================================================
# UPDATE UTILITY
# ============================================================

function Update-SCWUUtility {
    <#
    .SYNOPSIS
        Updates the ShaneCodes Utilman script
    .DESCRIPTION
        Checks for and installs updates to the utility itself.
    #>
    
    Write-SCWULog "Checking for Utilman updates" -Level "INFO"
    
    try {
        # Get remote version
        $remoteVersion = Invoke-RestMethod -Uri $global:SCWU_Config.Urls.Version -ErrorAction Stop
        $localVersion = "1.0.0" # This should be updated with each release
        
        Write-Host "`nCurrent version: $localVersion" -ForegroundColor Cyan
        Write-Host "Remote version: $remoteVersion" -ForegroundColor Cyan
        
        if ($remoteVersion -gt $localVersion) {
            Write-Host "`n🔄 New version available!" -ForegroundColor Green
            
            $confirm = Read-Host "Download and install update? (y/n)"
            if ($confirm -eq 'y') {
                # Download new script
                $newScript = Invoke-RestMethod -Uri $global:SCWU_Config.Urls.Script -ErrorAction Stop
                
                # Backup current script
                $backupPath = "$PSScriptRoot\ShaneCodes-Utilman_Backup_$(Get-Date -Format 'yyyyMMdd_HHmmss').ps1"
                Copy-Item $MyInvocation.MyCommand.Path $backupPath
                Write-SCWULog "Backup created: $backupPath" -Level "SUCCESS"
                
                # Save new script
                $newScript | Out-File -FilePath $MyInvocation.MyCommand.Path -Encoding UTF8
                Write-SCWULog "Update installed successfully!" -Level "SUCCESS"
                Write-Host "`nPlease restart the script to apply the update." -ForegroundColor Yellow
                Read-Host "Press Enter to exit"
                exit 0
            }
        } else {
            Write-SCWULog "Utility is up to date" -Level "SUCCESS"
            Write-Host "`n✅ You have the latest version of ShaneCodes Utilman." -ForegroundColor Green
        }
    } catch {
        Write-SCWULog "Failed to check for updates: $($_.Exception.Message)" -Level "ERROR"
        Write-Host "`nUnable to check for updates. Please check your internet connection." -ForegroundColor Yellow
    }
    
    Read-Host "`nPress Enter to continue"
}

# ============================================================
# ADVANCED OPTIONS
# ============================================================

function Show-SCWUAdvanced {
    <#
    .SYNOPSIS
        Displays advanced options menu
    .DESCRIPTION
        Provides access to advanced features and configurations.
    #>
    
    Write-Host "`n⚙️ Advanced Options:" -ForegroundColor Yellow
    Write-Host "  [1] Clear configuration cache"
    Write-Host "  [2] Reset all settings to default"
    Write-Host "  [3] Export current configuration"
    Write-Host "  [4] View log files"
    Write-Host "  [5] Return to main menu"
    
    $choice = Read-Host "`nSelect an option (1-5)"
    
    switch ($choice) {
        '1' {
            Write-SCWULog "Clearing configuration cache" -Level "INFO"
            $cachePath = "$env:APPDATA\ShaneCodes\Utilman\cache"
            if (Test-Path $cachePath) {
                Remove-Item -Path $cachePath -Recurse -Force
                Write-Host "Cache cleared successfully." -ForegroundColor Green
            } else {
                Write-Host "No cache to clear." -ForegroundColor Yellow
            }
        }
        '2' {
            Write-Host "WARNING: This will reset all settings to default." -ForegroundColor Red
            $confirm = Read-Host "Continue? (y/n)"
            if ($confirm -eq 'y') {
                $configPath = "$env:APPDATA\ShaneCodes\Utilman"
                if (Test-Path $configPath) {
                    Remove-Item -Path $configPath -Recurse -Force
                    Write-Host "Settings reset to default." -ForegroundColor Green
                }
            }
        }
        '3' {
            $exportPath = "$env:USERPROFILE\Desktop\SCWU_Export_$(Get-Date -Format 'yyyyMMdd_HHmmss').json"
            $config = Get-SCWUConfiguration
            $config | ConvertTo-Json -Depth 3 | Out-File -FilePath $exportPath -Encoding UTF8
            Write-Host "Configuration exported to: $exportPath" -ForegroundColor Green
        }
        '4' {
            $logFiles = Get-ChildItem -Path $global:LocalLogPath -Filter "*.log" -ErrorAction SilentlyContinue
            if ($logFiles) {
                Write-Host "`n📋 Log Files:" -ForegroundColor Yellow
                foreach ($file in $logFiles) {
                    Write-Host "  $($file.Name) - $($file.LastWriteTime)" -ForegroundColor White
                }
                
                $fileChoice = Read-Host "`nEnter filename to view (or 'all' for all logs)"
                if ($fileChoice -eq 'all') {
                    foreach ($file in $logFiles) {
                        Write-Host "`n--- $($file.Name) ---" -ForegroundColor Cyan
                        Get-Content -Path $file.FullName | Select-Object -Last 20
                    }
                } else {
                    $selectedFile = $logFiles | Where-Object { $_.Name -eq $fileChoice }
                    if ($selectedFile) {
                        Get-Content -Path $selectedFile.FullName | Select-Object -Last 30
                    } else {
                        Write-Host "File not found." -ForegroundColor Red
                    }
                }
            } else {
                Write-Host "No log files found." -ForegroundColor Yellow
            }
        }
        '5' { return }
        default { Write-Host "Invalid option." -ForegroundColor Red }
    }
    
    Read-Host "`nPress Enter to continue"
}

# ============================================================
# UTILITY FUNCTIONS
# ============================================================

function Test-SCWUPrerequisites {
    <#
    .SYNOPSIS
        Tests if all prerequisites are met
    .DESCRIPTION
        Checks for internet connectivity and required components.
    #>
    
    Write-SCWULog "Checking prerequisites..." -Level "INFO"
    
    # Check internet connectivity
    try {
        $test = Invoke-WebRequest -Uri "https://github.com" -UseBasicParsing -ErrorAction Stop
        Write-SCWULog "Internet connection: OK" -Level "SUCCESS"
    } catch {
        Write-SCWULog "Internet connection: FAILED" -Level "ERROR"
        Write-Host "`nNo internet connection detected. Some features may be unavailable." -ForegroundColor Yellow
        return $false
    }
    
    # Check for admin privileges
    if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
        Write-SCWULog "Administrator privileges: MISSING" -Level "ERROR"
        Write-Host "`nThis script must be run as Administrator." -ForegroundColor Red
        return $false
    } else {
        Write-SCWULog "Administrator privileges: OK" -Level "SUCCESS"
    }
    
    # Create application directory
    $appDir = "$env:APPDATA\ShaneCodes\Utilman"
    if (-not (Test-Path $appDir)) {
        New-Item -ItemType Directory -Path $appDir -Force | Out-Null
        Write-SCWULog "Application directory created: $appDir" -Level "INFO"
    }
    
    return $true
}

# ============================================================
# MAIN EXECUTION
# ============================================================

function Main {
    <#
    .SYNOPSIS
        Main entry point for ShaneCodes Windows Utilman
    .DESCRIPTION
        Controls the primary execution flow of the utility.
    #>
    
    # Set console window title
    $Host.UI.RawUI.WindowTitle = "ShaneCodes Windows Utilman v1.0"
    
    # Run prerequisite checks
    if (-not (Test-SCWUPrerequisites)) {
        Write-Host "`nPress any key to exit..."
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        exit 1
    }
    
    Write-SCWULog "ShaneCodes Windows Utilman started" -Level "INFO"
    
    # Main menu loop
    do {
        Show-SCWUMenu
        $choice = Read-Host "`nPlease select an option (1-7)"
        
        switch ($choice) {
            '1' { Install-SCWUSoftware }
            '2' { Apply-SCWUTweaks }
            '3' { Manage-SCWUUpdates }
            '4' { Show-SCWUSystemInfo }
            '5' { Update-SCWUUtility }
            '6' { 
                Write-SCWULog "Exiting ShaneCodes Windows Utilman" -Level "INFO"
                Write-Host "`nThank you for using ShaneCodes Windows Utilman!" -ForegroundColor Cyan
                break 
            }
            '7' { Show-SCWUAdvanced }
            default { 
                Write-Host "Invalid selection. Please try again." -ForegroundColor Red
                Start-Sleep -Seconds 1
            }
        }
        
        if ($choice -ne '6') {
            Write-Host "`nPress any key to return to the menu..."
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        }
        
    } while ($choice -ne '6')
    
    Write-SCWULog "Utility session ended" -Level "INFO"
}

# ============================================================
# SCRIPT ENTRY POINT
# ============================================================

# Verify Administrator privileges before starting
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Red
    Write-Host "║                    ADMINISTRATOR REQUIRED                      ║" -ForegroundColor Red
    Write-Host "╠════════════════════════════════════════════════════════════════╣" -ForegroundColor Red
    Write-Host "║                                                                ║" -ForegroundColor Red
    Write-Host "║  This script must be run as Administrator to function properly. ║" -ForegroundColor Yellow
    Write-Host "║                                                                ║" -ForegroundColor Red
    Write-Host "║  Please restart PowerShell as Administrator and run again.     ║" -ForegroundColor Yellow
    Write-Host "║                                                                ║" -ForegroundColor Red
    Write-Host "╚════════════════════════════════════════════════════════════════╝" -ForegroundColor Red
    Start-Sleep -Seconds 3
    exit 1
}

# Start the main program
Main