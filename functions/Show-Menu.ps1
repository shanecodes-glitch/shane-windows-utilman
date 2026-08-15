function Show-Menu {
    <#
    .SYNOPSIS
        Displays the main interactive menu and handles user selection.
    .DESCRIPTION
        Presents a text-based menu with all available options.
        Accessible for screen readers and keyboard-only navigation.
    #>
    
    Clear-Host
    
    # ASCII Art Banner
    Write-Host @"
   _____  _   _  ____   _____         ____  _   _   ___   _   _   _____   __  __   _   _   _   _
  / ____|| | | ||  _ \ |  __ \       / __ \| \ | | / _ \ | \ | | |_   _| |  \/  | | \ | | | \ | |
 | (___  | |_| || |_) || |  | |     | |  | ||  \| || | | ||  \| |   | |   | \  / | |  \| | |  \| |
  \___ \ |  _  ||  _ < | |  | |     | |  | || . ` || | | || . ` |   | |   | |\/| | | . ` | | . ` |
  ____) || | | || |_) || |__| |     | |__| || |\  || |_| || |\  |  _| |_  | |  | | | |\  | | |\  |
 |_____/ |_| |_||____/ |_____/       \____/ |_| \_| \___/ |_| \_| |_____| |_|  |_| |_| \_| |_| \_|
                                                                                                    
═══════════════════════════════════════════════════════════════════════════════════════════════════════
  Your Windows, Your Control  |  Version $global:ToolVersion  |  By Shane Nichael Obinguar
═══════════════════════════════════════════════════════════════════════════════════════════════════════
"@
    Write-Host "`n[MAIN MENU]`n"
    Write-Host "  1.  📦 Install Software"
    Write-Host "  2.  ⚡ Apply System Tweaks"
    Write-Host "  3.  🔧 Windows Update Manager"
    Write-Host "  4.  📊 View System Information"
    Write-Host "  5.  🚀 Apply Preset (Standard / Minimal / Advanced)"
    Write-Host "  6.  🔄 Self-Update Utilman"
    Write-Host "  7.  📜 View Log"
    Write-Host "  8.  🧹 Clean Up Temporary Files"
    Write-Host "  9.  ❌ Exit"
    Write-Host "`n───────────────────────────────────────────────────────────────────────────────────────"
    Write-Host "  NOTE: All changes can be reviewed in the log file: $global:LogPath"
    Write-Host "───────────────────────────────────────────────────────────────────────────────────────"
    
    $choice = Read-Host "`nEnter your choice (1-9)"
    
    switch ($choice) {
        "1" { Install-Apps }
        "2" { Apply-Tweaks }
        "3" { Update-Manager }
        "4" { Get-SystemInfo }
        "5" { Invoke-Preset }
        "6" { Self-Update }
        "7" { View-Log }
        "8" { Clean-TempFiles }
        "9" { 
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
    
    # Pause and return to menu after any action
    Write-Host "`nPress any key to return to the main menu..."
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    Show-Menu
}

function View-Log {
    if (Test-Path $global:LogPath) {
        Get-Content $global:LogPath -Tail 50
    } else {
        Write-Host "No log file found at: $global:LogPath" -ForegroundColor Yellow
    }
}

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