<#
.SYNOPSIS
    ShaneCodes Windows Utilman - Single Source Launcher
.DESCRIPTION
    A comprehensive system utility for installing software, applying tweaks, managing updates, and more.
.EXAMPLE
    irm https://raw.githubusercontent.com/shanecodes-glitch/shane-windows-utilman/main/ShaneCodes-Utilman.ps1 | iex
.NOTES
    Author: Shane Nichael Obinguar
    Version: 1.0.0
#>

#Requires -RunAsAdministrator

# 1. Check for Administrator rights
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Warning "This utility must be run as Administrator."
    Write-Warning "Please restart PowerShell as Administrator and try again."
    Write-Host "`nPress any key to exit..."
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit 1
}

# 2. Define paths
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$functionsPath = Join-Path $scriptPath "functions"
$configPath = Join-Path $scriptPath "config"
$logPath = Join-Path $env:TEMP "ShaneCodes-Utilman.log"

# 3. Initialize logging
function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] [$Level] $Message"
    Add-Content -Path $logPath -Value $logEntry
    Write-Host $logEntry
}

# 4. Load all functions
if (Test-Path $functionsPath) {
    Write-Log "Loading functions from $functionsPath"
    Get-ChildItem -Path $functionsPath -Filter "*.ps1" | ForEach-Object {
        try {
            . $_.FullName
            Write-Log "Loaded: $($_.Name)"
        } catch {
            Write-Log "Failed to load: $($_.Name) - $_" "ERROR"
        }
    }
} else {
    Write-Log "Functions folder not found at $functionsPath" "ERROR"
    Write-Host "`nPress any key to exit..."
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit 1
}

# 5. Load configuration (presets)
$presetFile = Join-Path $configPath "preset.json"
if (Test-Path $presetFile) {
    try {
        $global:Presets = Get-Content $presetFile | ConvertFrom-Json
        Write-Log "Loaded presets from $presetFile"
    } catch {
        Write-Log "Failed to load presets: $_" "ERROR"
        $global:Presets = $null
    }
} else {
    Write-Log "Preset file not found at $presetFile, using defaults" "WARNING"
    $global:Presets = $null
}

# 6. Define global variables
$global:LogPath = $logPath
$global:ToolVersion = "1.0.0"
$global:RepoURL = "https://raw.githubusercontent.com/shanecodes-glitch/shane-windows-utilman/main"

Write-Log "ShaneCodes Utilman v$global:ToolVersion started"

# 7. Launch the main menu
try {
    Show-Menu
} catch {
    Write-Log "Fatal error in main menu: $_" "ERROR"
    Write-Host "`nAn error occurred. Please check the log at: $logPath"
    Write-Host "`nPress any key to exit..."
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit 1
}

Write-Log "ShaneCodes Utilman finished"