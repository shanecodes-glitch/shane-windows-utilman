<#
    .SYNOPSIS
        ShaneCodes Windows Utilman v2.0 — Enhanced Edition
        Now with Preset System and GUI Interface!
    
    .DESCRIPTION
        A comprehensive Windows utility with:
        - 6 professional presets (Standard, Minimal, Advanced, Gaming, Developer, Privacy)
        - Custom preset builder
        - Full GUI interface (Windows Forms)
        - Dark/Light theme support
        - Export/Import functionality
    
    .AUTHOR
        ShaneCodes
        Repository: https://github.com/shanecodes-glitch/shane-windows-utilman
    
    .VERSION
        2.0.0
    
    .NOTES
        Must be run as Administrator.
#>

#Requires -RunAsAdministrator
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# ============================================================
# GLOBAL CONFIGURATION
# ============================================================

$global:SCWU_Config = @{
    BaseUrl = "https://raw.githubusercontent.com/shanecodes-glitch/shane-windows-utilman/main/"
    ConfigFile   = "config/scwu-config.json"
    SoftwareFile = "config/software-list.json"
    TweakFile    = "config/tweaks.json"
    VersionFile  = "version.txt"
    ScriptFile   = "ShaneCodes-Utilman.ps1"
}

$global:LocalConfigPath = "$env:APPDATA\ShaneCodes\Utilman\config.json"
$global:LocalLogPath    = "$env:APPDATA\ShaneCodes\Utilman\logs\"
$global:ThemeMode       = "Dark"  # Dark or Light

# ============================================================
# PRESET SYSTEM — ENHANCED
# ============================================================

$global:Presets = @{
    "Standard" = @{
        description = "⚖️ Balanced defaults for most users"
        icon = "⚖️"
        tweaks = @("performance_light", "privacy_basic", "interface_clean")
        software = @("vscode", "7zip", "git", "notepadplusplus", "everything")
    }
    "Minimal" = @{
        description = "🌱 Minimum changes, maximum compatibility"
        icon = "🌱"
        tweaks = @("performance_light", "privacy_basic")
        software = @("7zip", "everything")
    }
    "Advanced" = @{
        description = "⚡ Deep system optimizations for power users"
        icon = "⚡"
        tweaks = @("performance_heavy", "privacy_full", "interface_advanced", "security_hardened")
        software = @("vscode", "git", "wireshark", "powertoys", "everything")
    }
    "Gaming" = @{
        description = "🎮 Optimized for gaming performance"
        icon = "🎮"
        tweaks = @("performance_gaming", "interface_gaming", "network_gaming")
        software = @("steam", "discord", "obs", "spotify")
    }
    "Developer" = @{
        description = "💻 Full development environment setup"
        icon = "💻"
        tweaks = @("performance_heavy", "interface_developer")
        software = @("vscode", "git", "docker", "nodejs", "python", "powershell", "notepadplusplus")
    }
    "Privacy" = @{
        description = "🛡️ Maximum privacy and security"
        icon = "🛡️"
        tweaks = @("privacy_full", "security_hardened", "interface_privacy")
        software = @("wireshark", "tor", "bitwarden")
    }
}

# ============================================================
# TWEAK DEFINITIONS (For Preset System)
# ============================================================

$global:TweakDefinitions = @{
    "performance_light" = @{
        name = "Performance - Light"
        registry = @{
            "HKCU:\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\VisualEffects" = @{
                "VisualFXSetting" = 2
            }
        }
    }
    "performance_heavy" = @{
        name = "Performance - Heavy"
        registry = @{
            "HKCU:\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\VisualEffects" = @{
                "VisualFXSetting" = 2
            }
            "HKLM:\\SYSTEM\\CurrentControlSet\\Control\\PriorityControl" = @{
                "Win32PrioritySeparation" = 26
            }
        }
    }
    "performance_gaming" = @{
        name = "Performance - Gaming"
        registry = @{
            "HKLM:\\SYSTEM\\CurrentControlSet\\Control\\PriorityControl" = @{
                "Win32PrioritySeparation" = 38
            }
            "HKLM:\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\Multimedia\\SystemProfile" = @{
                "SystemResponsiveness" = 0
            }
        }
    }
    "privacy_basic" = @{
        name = "Privacy - Basic"
        registry = @{
            "HKLM:\\SOFTWARE\\Policies\\Microsoft\\Windows\\DataCollection" = @{
                "AllowTelemetry" = 1
            }
        }
    }
    "privacy_full" = @{
        name = "Privacy - Full"
        registry = @{
            "HKLM:\\SOFTWARE\\Policies\\Microsoft\\Windows\\DataCollection" = @{
                "AllowTelemetry" = 0
            }
            "HKLM:\\SOFTWARE\\Policies\\Microsoft\\Windows\\Windows Search" = @{
                "AllowCortana" = 0
            }
        }
    }
    "interface_clean" = @{
        name = "Interface - Clean"
        registry = @{
            "HKCU:\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\Advanced" = @{
                "HideFileExt" = 0
                "Hidden" = 1
            }
        }
    }
    "interface_advanced" = @{
        name = "Interface - Advanced"
        registry = @{
            "HKCU:\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\Advanced" = @{
                "HideFileExt" = 0
                "Hidden" = 1
                "TaskbarSmallIcons" = 1
            }
        }
    }
    "interface_gaming" = @{
        name = "Interface - Gaming"
        registry = @{
            "HKCU:\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\Advanced" = @{
                "HideFileExt" = 0
                "Hidden" = 1
                "TaskbarSmallIcons" = 1
            }
            "HKCU:\\Control Panel\\Desktop" = @{
                "UserPreferencesMask" = "90 12 03 80 10 00 00 00"
            }
        }
    }
    "interface_developer" = @{
        name = "Interface - Developer"
        registry = @{
            "HKCU:\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\Advanced" = @{
                "HideFileExt" = 0
                "Hidden" = 1
                "ShowSuperHidden" = 1
            }
        }
    }
    "interface_privacy" = @{
        name = "Interface - Privacy"
        registry = @{
            "HKCU:\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\Advanced" = @{
                "HideFileExt" = 0
                "Hidden" = 1
                "Start_TrackProgs" = 0
            }
        }
    }
    "security_hardened" = @{
        name = "Security - Hardened"
        registry = @{
            "HKLM:\\SYSTEM\\CurrentControlSet\\Control\\Terminal Server" = @{
                "fDenyTSConnections" = 1
            }
            "HKCU:\\Software\\Microsoft\\Windows Script Host\\Settings" = @{
                "Enabled" = 0
            }
        }
    }
    "network_gaming" = @{
        name = "Network - Gaming"
        registry = @{
            "HKLM:\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\Multimedia\\SystemProfile" = @{
                "NetworkThrottlingIndex" = "ffffffff"
            }
        }
    }
}

# ============================================================
# GUI INTERFACE — FULL WINDOWS FORMS
# ============================================================

function Show-SCWUGUI {
    <#
    .SYNOPSIS
        Displays the full GUI interface for ShaneCodes Utilman
    .DESCRIPTION
        Creates a Windows Forms interface with:
        - Preset selection with preview
        - Theme toggle (Dark/Light)
        - Progress bar
        - Log viewer
        - Export/Import functionality
    #>
    
    # Create main form
    $form = New-Object System.Windows.Forms.Form
    $form.Text = "ShaneCodes Windows Utilman v2.0"
    $form.Size = New-Object System.Drawing.Size(900, 650)
    $form.StartPosition = "CenterScreen"
    $form.BackColor = if ($global:ThemeMode -eq "Dark") { [System.Drawing.Color]::FromArgb(30, 30, 30) } else { [System.Drawing.Color]::White }
    $form.ForeColor = if ($global:ThemeMode -eq "Dark") { [System.Drawing.Color]::White } else { [System.Drawing.Color]::Black }
    $form.FormBorderStyle = "FixedDialog"
    $form.MaximizeBox = $false
    
    # ==========================================================
    # HEADER PANEL
    # ==========================================================
    
    $headerPanel = New-Object System.Windows.Forms.Panel
    $headerPanel.Dock = "Top"
    $headerPanel.Height = 60
    $headerPanel.BackColor = if ($global:ThemeMode -eq "Dark") { [System.Drawing.Color]::FromArgb(50, 50, 50) } else { [System.Drawing.Color]::FromArgb(240, 240, 240) }
    
    $titleLabel = New-Object System.Windows.Forms.Label
    $titleLabel.Text = "🚀 ShaneCodes Windows Utilman"
    $titleLabel.Font = New-Object System.Drawing.Font("Segoe UI", 18, [System.Drawing.FontStyle]::Bold)
    $titleLabel.Location = New-Object System.Drawing.Point(20, 15)
    $titleLabel.AutoSize = $true
    $titleLabel.ForeColor = if ($global:ThemeMode -eq "Dark") { [System.Drawing.Color]::FromArgb(0, 180, 255) } else { [System.Drawing.Color]::FromArgb(0, 100, 200) }
    
    $headerPanel.Controls.Add($titleLabel)
    $form.Controls.Add($headerPanel)
    
    # ==========================================================
    # PRESET SELECTION PANEL
    # ==========================================================
    
    $presetPanel = New-Object System.Windows.Forms.Panel
    $presetPanel.Location = New-Object System.Drawing.Point(20, 80)
    $presetPanel.Size = New-Object System.Drawing.Size(400, 420)
    $presetPanel.BackColor = if ($global:ThemeMode -eq "Dark") { [System.Drawing.Color]::FromArgb(40, 40, 40) } else { [System.Drawing.Color]::FromArgb(245, 245, 245) }
    $presetPanel.BorderStyle = "FixedSingle"
    
    # Preset Label
    $presetLabel = New-Object System.Windows.Forms.Label
    $presetLabel.Text = "🎯 Select Preset"
    $presetLabel.Font = New-Object System.Drawing.Font("Segoe UI", 14, [System.Drawing.FontStyle]::Bold)
    $presetLabel.Location = New-Object System.Drawing.Point(15, 10)
    $presetLabel.AutoSize = $true
    $presetPanel.Controls.Add($presetLabel)
    
    # Preset ListBox
    $presetList = New-Object System.Windows.Forms.ListBox
    $presetList.Location = New-Object System.Drawing.Point(15, 45)
    $presetList.Size = New-Object System.Drawing.Size(365, 250)
    $presetList.BackColor = if ($global:ThemeMode -eq "Dark") { [System.Drawing.Color]::FromArgb(50, 50, 50) } else { [System.Drawing.Color]::White }
    $presetList.ForeColor = if ($global:ThemeMode -eq "Dark") { [System.Drawing.Color]::White } else { [System.Drawing.Color]::Black }
    $presetList.Font = New-Object System.Drawing.Font("Segoe UI", 11)
    
    # Populate presets
    foreach ($preset in $global:Presets.Keys) {
        $presetList.Items.Add("$($global:Presets[$preset].icon) $preset - $($global:Presets[$preset].description)")
    }
    $presetList.SelectedIndex = 0
    $presetPanel.Controls.Add($presetList)
    
    # Preset Description Box
    $presetDesc = New-Object System.Windows.Forms.TextBox
    $presetDesc.Location = New-Object System.Drawing.Point(15, 310)
    $presetDesc.Size = New-Object System.Drawing.Size(365, 80)
    $presetDesc.Multiline = $true
    $presetDesc.ReadOnly = $true
    $presetDesc.BackColor = if ($global:ThemeMode -eq "Dark") { [System.Drawing.Color]::FromArgb(50, 50, 50) } else { [System.Drawing.Color]::FromArgb(240, 240, 240) }
    $presetDesc.ForeColor = if ($global:ThemeMode -eq "Dark") { [System.Drawing.Color]::White } else { [System.Drawing.Color]::Black }
    $presetDesc.Font = New-Object System.Drawing.Font("Segoe UI", 10)
    $presetPanel.Controls.Add($presetDesc)
    
    # Show details on selection change
    $presetList.Add_SelectedIndexChanged({
        if ($presetList.SelectedItem) {
            $selectedText = $presetList.SelectedItem.ToString()
            $presetName = ($selectedText -split ' ')[1]  # Get the preset name
            $presetDesc.Text = "Tweaks: " + ($global:Presets[$presetName].tweaks -join ", ") + "`r`nSoftware: " + ($global:Presets[$presetName].software -join ", ")
        }
    })
    
    $form.Controls.Add($presetPanel)
    
    # ==========================================================
    # DETAILS PANEL (Right Side)
    # ==========================================================
    
    $detailPanel = New-Object System.Windows.Forms.Panel
    $detailPanel.Location = New-Object System.Drawing.Point(440, 80)
    $detailPanel.Size = New-Object System.Drawing.Size(430, 420)
    $detailPanel.BackColor = if ($global:ThemeMode -eq "Dark") { [System.Drawing.Color]::FromArgb(40, 40, 40) } else { [System.Drawing.Color]::FromArgb(245, 245, 245) }
    $detailPanel.BorderStyle = "FixedSingle"
    
    # Action Buttons
    $applyPresetBtn = New-Object System.Windows.Forms.Button
    $applyPresetBtn.Text = "✅ Apply Preset"
    $applyPresetBtn.Location = New-Object System.Drawing.Point(15, 15)
    $applyPresetBtn.Size = New-Object System.Drawing.Size(190, 45)
    $applyPresetBtn.Font = New-Object System.Drawing.Font("Segoe UI", 12, [System.Drawing.FontStyle]::Bold)
    $applyPresetBtn.BackColor = [System.Drawing.Color]::FromArgb(0, 150, 0)
    $applyPresetBtn.ForeColor = [System.Drawing.Color]::White
    $applyPresetBtn.FlatStyle = "Flat"
    $detailPanel.Controls.Add($applyPresetBtn)
    
    $customPresetBtn = New-Object System.Windows.Forms.Button
    $customPresetBtn.Text = "🔧 Custom Preset Builder"
    $customPresetBtn.Location = New-Object System.Drawing.Point(215, 15)
    $customPresetBtn.Size = New-Object System.Drawing.Size(195, 45)
    $customPresetBtn.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
    $customPresetBtn.BackColor = if ($global:ThemeMode -eq "Dark") { [System.Drawing.Color]::FromArgb(60, 60, 60) } else { [System.Drawing.Color]::FromArgb(220, 220, 220) }
    $customPresetBtn.FlatStyle = "Flat"
    $detailPanel.Controls.Add($customPresetBtn)
    
    # Progress Bar
    $progressBar = New-Object System.Windows.Forms.ProgressBar
    $progressBar.Location = New-Object System.Drawing.Point(15, 75)
    $progressBar.Size = New-Object System.Drawing.Size(395, 30)
    $progressBar.Style = "Continuous"
    $detailPanel.Controls.Add($progressBar)
    
    # Log Viewer
    $logLabel = New-Object System.Windows.Forms.Label
    $logLabel.Text = "📋 Log Viewer"
    $logLabel.Font = New-Object System.Drawing.Font("Segoe UI", 12, [System.Drawing.FontStyle]::Bold)
    $logLabel.Location = New-Object System.Drawing.Point(15, 120)
    $logLabel.AutoSize = $true
    $detailPanel.Controls.Add($logLabel)
    
    $logBox = New-Object System.Windows.Forms.TextBox
    $logBox.Location = New-Object System.Drawing.Point(15, 150)
    $logBox.Size = New-Object System.Drawing.Size(395, 200)
    $logBox.Multiline = $true
    $logBox.ReadOnly = $true
    $logBox.ScrollBars = "Vertical"
    $logBox.BackColor = if ($global:ThemeMode -eq "Dark") { [System.Drawing.Color]::FromArgb(30, 30, 30) } else { [System.Drawing.Color]::White }
    $logBox.ForeColor = if ($global:ThemeMode -eq "Dark") { [System.Drawing.Color]::FromArgb(0, 255, 0) } else { [System.Drawing.Color]::Black }
    $logBox.Font = New-Object System.Drawing.Font("Consolas", 9)
    $detailPanel.Controls.Add($logBox)
    
    # Export/Import Buttons
    $exportBtn = New-Object System.Windows.Forms.Button
    $exportBtn.Text = "📤 Export Preset"
    $exportBtn.Location = New-Object System.Drawing.Point(15, 365)
    $exportBtn.Size = New-Object System.Drawing.Size(190, 35)
    $exportBtn.Font = New-Object System.Drawing.Font("Segoe UI", 10)
    $exportBtn.FlatStyle = "Flat"
    $detailPanel.Controls.Add($exportBtn)
    
    $importBtn = New-Object System.Windows.Forms.Button
    $importBtn.Text = "📥 Import Preset"
    $importBtn.Location = New-Object System.Drawing.Point(215, 365)
    $importBtn.Size = New-Object System.Drawing.Size(195, 35)
    $importBtn.Font = New-Object System.Drawing.Font("Segoe UI", 10)
    $importBtn.FlatStyle = "Flat"
    $detailPanel.Controls.Add($importBtn)
    
    # Theme Toggle
    $themeBtn = New-Object System.Windows.Forms.Button
    $themeBtn.Text = if ($global:ThemeMode -eq "Dark") { "☀️ Light Mode" } else { "🌙 Dark Mode" }
    $themeBtn.Location = New-Object System.Drawing.Point(15, 410)
    $themeBtn.Size = New-Object System.Drawing.Size(395, 35)
    $themeBtn.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
    $themeBtn.FlatStyle = "Flat"
    $themeBtn.BackColor = if ($global:ThemeMode -eq "Dark") { [System.Drawing.Color]::FromArgb(60, 60, 60) } else { [System.Drawing.Color]::FromArgb(220, 220, 220) }
    $detailPanel.Controls.Add($themeBtn)
    
    $form.Controls.Add($detailPanel)
    
    # ==========================================================
    # EVENT HANDLERS
    # ==========================================================
    
    # Apply Preset
    $applyPresetBtn.Add_Click({
        if ($presetList.SelectedItem) {
            $selectedText = $presetList.SelectedItem.ToString()
            $presetName = ($selectedText -split ' ')[1]
            $preset = $global:Presets[$presetName]
            
            $logBox.AppendText("`n=== Applying Preset: $presetName ===`n")
            $progressBar.Value = 0
            
            # Apply tweaks
            $i = 0
            foreach ($tweakName in $preset.tweaks) {
                $i++
                $progressBar.Value = [math]::Round(($i / $preset.tweaks.Count) * 50)
                $logBox.AppendText("[Tweak] Applying: $tweakName`n")
                Apply-SCWUTweakByName $tweakName
            }
            
            $progressBar.Value = 50
            
            # Install software
            $j = 0
            foreach ($app in $preset.software) {
                $j++
                $progressBar.Value = 50 + [math]::Round(($j / $preset.software.Count) * 50)
                $logBox.AppendText("[Software] Installing: $app`n")
                Install-SCWUSoftwareByName $app
            }
            
            $progressBar.Value = 100
            $logBox.AppendText("`n✅ Preset '$presetName' applied successfully!`n")
            [System.Windows.Forms.MessageBox]::Show("Preset '$presetName' applied successfully!", "Success", "OK", "Information")
        }
    })
    
    # Custom Preset Builder
    $customPresetBtn.Add_Click({
        Show-SCWUCustomPresetBuilder
    })
    
    # Theme Toggle
    $themeBtn.Add_Click({
        if ($global:ThemeMode -eq "Dark") {
            $global:ThemeMode = "Light"
            $themeBtn.Text = "🌙 Dark Mode"
        } else {
            $global:ThemeMode = "Dark"
            $themeBtn.Text = "☀️ Light Mode"
        }
        # Reload form with new theme
        $form.Close()
        Show-SCWUGUI
    })
    
    # Export
    $exportBtn.Add_Click({
        $saveDialog = New-Object System.Windows.Forms.SaveFileDialog
        $saveDialog.Filter = "JSON Files (*.json)|*.json"
        $saveDialog.Title = "Export Preset Configuration"
        if ($saveDialog.ShowDialog() -eq "OK") {
            $selectedText = $presetList.SelectedItem.ToString()
            $presetName = ($selectedText -split ' ')[1]
            $preset = $global:Presets[$presetName]
            $preset | ConvertTo-Json -Depth 3 | Out-File -FilePath $saveDialog.FileName
            $logBox.AppendText("`n✅ Preset '$presetName' exported to: $($saveDialog.FileName)`n")
        }
    })
    
    # Import
    $importBtn.Add_Click({
        $openDialog = New-Object System.Windows.Forms.OpenFileDialog
        $openDialog.Filter = "JSON Files (*.json)|*.json"
        $openDialog.Title = "Import Preset Configuration"
        if ($openDialog.ShowDialog() -eq "OK") {
            try {
                $importedPreset = Get-Content -Path $openDialog.FileName -Raw | ConvertFrom-Json
                $presetName = "Imported_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
                $global:Presets[$presetName] = @{
                    description = "📥 Imported preset"
                    icon = "📥"
                    tweaks = $importedPreset.tweaks
                    software = $importedPreset.software
                }
                $presetList.Items.Add("📥 $presetName - Imported Preset")
                $logBox.AppendText("`n✅ Preset imported successfully as: $presetName`n")
                [System.Windows.Forms.MessageBox]::Show("Preset imported successfully!", "Success", "OK", "Information")
            } catch {
                $logBox.AppendText("`n❌ Failed to import preset: $($_.Exception.Message)`n")
            }
        }
    })
    
    # Show form
    $form.ShowDialog() | Out-Null
}

# ============================================================
# PRESET BUILDER GUI
# ============================================================

function Show-SCWUCustomPresetBuilder {
    <#
    .SYNOPSIS
        Custom preset builder interface
    .DESCRIPTION
        Allows users to create their own presets by selecting tweaks and software
    #>
    
    $builderForm = New-Object System.Windows.Forms.Form
    $builderForm.Text = "🔧 Custom Preset Builder"
    $builderForm.Size = New-Object System.Drawing.Size(700, 500)
    $builderForm.StartPosition = "CenterScreen"
    $builderForm.BackColor = if ($global:ThemeMode -eq "Dark") { [System.Drawing.Color]::FromArgb(30, 30, 30) } else { [System.Drawing.Color]::White }
    $builderForm.ForeColor = if ($global:ThemeMode -eq "Dark") { [System.Drawing.Color]::White } else { [System.Drawing.Color]::Black }
    $builderForm.FormBorderStyle = "FixedDialog"
    $builderForm.MaximizeBox = $false
    
    # Left panel: Tweaks
    $tweakPanel = New-Object System.Windows.Forms.Panel
    $tweakPanel.Location = New-Object System.Drawing.Point(10, 10)
    $tweakPanel.Size = New-Object System.Drawing.Size(330, 400)
    $tweakPanel.BackColor = if ($global:ThemeMode -eq "Dark") { [System.Drawing.Color]::FromArgb(40, 40, 40) } else { [System.Drawing.Color]::FromArgb(240, 240, 240) }
    $tweakPanel.BorderStyle = "FixedSingle"
    
    $tweakLabel = New-Object System.Windows.Forms.Label
    $tweakLabel.Text = "⚡ Select Tweaks"
    $tweakLabel.Font = New-Object System.Drawing.Font("Segoe UI", 12, [System.Drawing.FontStyle]::Bold)
    $tweakLabel.Location = New-Object System.Drawing.Point(10, 10)
    $tweakLabel.AutoSize = $true
    $tweakPanel.Controls.Add($tweakLabel)
    
    # CheckedListBox for tweaks
    $tweakCheckList = New-Object System.Windows.Forms.CheckedListBox
    $tweakCheckList.Location = New-Object System.Drawing.Point(10, 40)
    $tweakCheckList.Size = New-Object System.Drawing.Size(305, 310)
    $tweakCheckList.BackColor = if ($global:ThemeMode -eq "Dark") { [System.Drawing.Color]::FromArgb(50, 50, 50) } else { [System.Drawing.Color]::White }
    $tweakCheckList.ForeColor = if ($global:ThemeMode -eq "Dark") { [System.Drawing.Color]::White } else { [System.Drawing.Color]::Black }
    $tweakCheckList.Font = New-Object System.Drawing.Font("Segoe UI", 10)
    foreach ($tweak in $global:TweakDefinitions.Keys) {
        $tweakCheckList.Items.Add($global:TweakDefinitions[$tweak].name)
    }
    $tweakPanel.Controls.Add($tweakCheckList)
    $builderForm.Controls.Add($tweakPanel)
    
    # Right panel: Software
    $softwarePanel = New-Object System.Windows.Forms.Panel
    $softwarePanel.Location = New-Object System.Drawing.Point(350, 10)
    $softwarePanel.Size = New-Object System.Drawing.Size(330, 400)
    $softwarePanel.BackColor = if ($global:ThemeMode -eq "Dark") { [System.Drawing.Color]::FromArgb(40, 40, 40) } else { [System.Drawing.Color]::FromArgb(240, 240, 240) }
    $softwarePanel.BorderStyle = "FixedSingle"
    
    $softwareLabel = New-Object System.Windows.Forms.Label
    $softwareLabel.Text = "📦 Select Software"
    $softwareLabel.Font = New-Object System.Drawing.Font("Segoe UI", 12, [System.Drawing.FontStyle]::Bold)
    $softwareLabel.Location = New-Object System.Drawing.Point(10, 10)
    $softwareLabel.AutoSize = $true
    $softwarePanel.Controls.Add($softwareLabel)
    
    # CheckedListBox for software
    $softwareCheckList = New-Object System.Windows.Forms.CheckedListBox
    $softwareCheckList.Location = New-Object System.Drawing.Point(10, 40)
    $softwareCheckList.Size = New-Object System.Drawing.Size(305, 310)
    $softwareCheckList.BackColor = if ($global:ThemeMode -eq "Dark") { [System.Drawing.Color]::FromArgb(50, 50, 50) } else { [System.Drawing.Color]::White }
    $softwareCheckList.ForeColor = if ($global:ThemeMode -eq "Dark") { [System.Drawing.Color]::White } else { [System.Drawing.Color]::Black }
    $softwareCheckList.Font = New-Object System.Drawing.Font("Segoe UI", 10)
    
    # Populate software list
    $softwareList = $null
    try {
        $softwareList = Invoke-RestMethod -Uri $global:SCWU_Config.Urls.Software -ErrorAction Stop
        foreach ($sw in $softwareList) {
            $softwareCheckList.Items.Add($sw.name)
        }
    } catch {
        # Default software list
        $defaultSoftware = @("7-Zip", "Visual Studio Code", "Git", "Notepad++", "Discord", "Spotify", "Steam", "Wireshark", "Everything", "PowerToys")
        foreach ($sw in $defaultSoftware) {
            $softwareCheckList.Items.Add($sw)
        }
    }
    $softwarePanel.Controls.Add($softwareCheckList)
    $builderForm.Controls.Add($softwarePanel)
    
    # Bottom buttons
    $savePresetBtn = New-Object System.Windows.Forms.Button
    $savePresetBtn.Text = "💾 Save Custom Preset"
    $savePresetBtn.Location = New-Object System.Drawing.Point(200, 425)
    $savePresetBtn.Size = New-Object System.Drawing.Size(200, 40)
    $savePresetBtn.Font = New-Object System.Drawing.Font("Segoe UI", 12, [System.Drawing.FontStyle]::Bold)
    $savePresetBtn.BackColor = [System.Drawing.Color]::FromArgb(0, 150, 0)
    $savePresetBtn.ForeColor = [System.Drawing.Color]::White
    $savePresetBtn.FlatStyle = "Flat"
    $builderForm.Controls.Add($savePresetBtn)
    
    $cancelBtn = New-Object System.Windows.Forms.Button
    $cancelBtn.Text = "Cancel"
    $cancelBtn.Location = New-Object System.Drawing.Point(420, 425)
    $cancelBtn.Size = New-Object System.Drawing.Size(100, 40)
    $cancelBtn.Font = New-Object System.Drawing.Font("Segoe UI", 10)
    $cancelBtn.FlatStyle = "Flat"
    $builderForm.Controls.Add($cancelBtn)
    
    # Event handlers
    $savePresetBtn.Add_Click({
        # Get selected tweaks
        $selectedTweaks = @()
        for ($i = 0; $i -lt $tweakCheckList.Items.Count; $i++) {
            if ($tweakCheckList.GetItemChecked($i)) {
                $tweakName = ($tweakCheckList.Items[$i] -split " - ")[0]
                $selectedTweaks += $tweakName
            }
        }
        
        # Get selected software
        $selectedSoftware = @()
        for ($i = 0; $i -lt $softwareCheckList.Items.Count; $i++) {
            if ($softwareCheckList.GetItemChecked($i)) {
                $selectedSoftware += $softwareCheckList.Items[$i]
            }
        }
        
        if ($selectedTweaks.Count -eq 0 -and $selectedSoftware.Count -eq 0) {
            [System.Windows.Forms.MessageBox]::Show("Please select at least one tweak or software.", "Warning", "OK", "Warning")
            return
        }
        
        # Create custom preset
        $presetName = "Custom_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
        $global:Presets[$presetName] = @{
            description = "🔧 Custom preset"
            icon = "🔧"
            tweaks = $selectedTweaks
            software = $selectedSoftware
        }
        
        [System.Windows.Forms.MessageBox]::Show("Custom preset '$presetName' created successfully!", "Success", "OK", "Information")
        $builderForm.Close()
    })
    
    $cancelBtn.Add_Click({
        $builderForm.Close()
    })
    
    $builderForm.ShowDialog() | Out-Null
}

# ============================================================
# HELPER FUNCTIONS
# ============================================================

function Apply-SCWUTweakByName {
    param($tweakName)
    
    $tweak = $global:TweakDefinitions[$tweakName]
    if (-not $tweak) { return }
    
    if ($tweak.registry) {
        foreach ($path in $tweak.registry.Keys) {
            $values = $tweak.registry[$path]
            foreach ($valueName in $values.Keys) {
                try {
                    if (-not (Test-Path $path)) {
                        New-Item -Path $path -Force | Out-Null
                    }
                    Set-ItemProperty -Path $path -Name $valueName -Value $values[$valueName] -Type DWord -Force
                } catch {
                    # Silently continue
                }
            }
        }
    }
}

function Install-SCWUSoftwareByName {
    param($appName)
    
    try {
        # Try Winget first
        if (Get-Command winget -ErrorAction SilentlyContinue) {
            winget install $appName --silent --accept-package-agreements -ErrorAction SilentlyContinue
        }
    } catch {
        # Silently continue
    }
}

# ============================================================
# MAIN ENTRY POINT
# ============================================================

# Check for admin
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "Administrator privileges required!" -ForegroundColor Red
    exit 1
}

# Show GUI
Show-SCWUGUI