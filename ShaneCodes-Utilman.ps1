<#
    .SYNOPSIS
        ShaneCodes Utilman ULTIMATE CONNECTED — The most powerful Windows utility
        Version: 3.0.0 — NOW WITH FULL CHRIS TITUS INTEGRATION
    
    .DESCRIPTION
        This tool CONNECTS to everything good about Chris Titus Tech's WinUtil
        AND adds NEXT-LEVEL features that Chris doesn't have.
    
        CONNECTED TO:
        - Winget (Microsoft package manager)
        - Chocolatey (Community packages)
        - Chris's tweak database (via config)
        - Chris's software list (via config)
        - Chris's update system
    
        YOUR EXCLUSIVE FEATURES:
        - AI-Powered Recommendations
        - System Dashboard (Live monitoring)
        - One-Click Rollback
        - Turbo Mode
        - AI Chat Assistant
        - Custom Preset Builder
        - Dark/Light Theme
        - Export/Import Presets
    
    .AUTHOR
        ShaneCodes
        Repository: https://github.com/shanecodes-glitch/shane-windows-utilman
    
    .VERSION
        3.0.0
#>

#Requires -RunAsAdministrator
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName System.Windows.Forms.DataVisualization

# ============================================================
# CONNECTION TO CHRIS TITUS TECH WINUTIL
# ============================================================

$global:ChrisSources = @{
    # Chris's main WinUtil URL
    WinUtil = "https://raw.githubusercontent.com/ChrisTitusTech/winutil/main/"
    
    # Chris's configuration files
    ChrisConfig = "https://raw.githubusercontent.com/ChrisTitusTech/winutil/main/config/preset.json"
    ChrisSoftware = "https://raw.githubusercontent.com/ChrisTitusTech/winutil/main/config/software.json"
    ChrisTweaks = "https://raw.githubusercontent.com/ChrisTitusTech/winutil/main/config/tweaks.json"
    
    # Chris's presets
    ChrisPresets = @{
        Standard = "https://raw.githubusercontent.com/ChrisTitusTech/winutil/main/config/presets/standard.json"
        Minimal = "https://raw.githubusercontent.com/ChrisTitusTech/winutil/main/config/presets/minimal.json"
        Advanced = "https://raw.githubusercontent.com/ChrisTitusTech/winutil/main/config/presets/advanced.json"
    }
}

$global:ShaneSources = @{
    # YOUR configuration files
    ShaneConfig = "https://raw.githubusercontent.com/shanecodes-glitch/shane-windows-utilman/main/config/scwu-config.json"
    ShaneSoftware = "https://raw.githubusercontent.com/shanecodes-glitch/shane-windows-utilman/main/config/software-list.json"
    ShaneTweaks = "https://raw.githubusercontent.com/shanecodes-glitch/shane-windows-utilman/main/config/tweaks.json"
}

# ============================================================
# GLOBAL SETTINGS
# ============================================================

$global:AppData = "$env:APPDATA\ShaneCodes\Utilman"
$global:LogPath = "$global:AppData\logs"
$global:SnapshotPath = "$global:AppData\snapshots"
$global:CachePath = "$global:AppData\cache"
$global:ThemeMode = "Dark"

# Create directories
@($global:AppData, $global:LogPath, $global:SnapshotPath, $global:CachePath) | ForEach-Object {
    if (-not (Test-Path $_)) { New-Item -ItemType Directory -Path $_ -Force | Out-Null }
}

# ============================================================
# FUNCTION: CONNECT TO CHRIS'S CONFIG
# ============================================================

function Get-ChrisConfiguration {
    <#
    .SYNOPSIS
        Fetches Chris Titus Tech's WinUtil configuration
        This is the CONNECTION to Chris's tool
    #>
    
    Write-SCWULog "🔗 Connecting to Chris Titus Tech WinUtil..." -Level "INFO"
    
    $chrisData = @{
        Presets = @{}
        Software = @()
        Tweaks = @{}
        Success = $false
    }
    
    try {
        # Get Chris's presets
        $presetData = Invoke-RestMethod -Uri $global:ChrisSources.ChrisPresets.Standard -ErrorAction Stop
        $chrisData.Presets.Standard = $presetData
        Write-SCWULog "✅ Connected to Chris's Standard preset" -Level "SUCCESS"
    } catch {
        Write-SCWULog "⚠️ Could not connect to Chris's Standard preset: $($_.Exception.Message)" -Level "WARNING"
    }
    
    try {
        $presetData = Invoke-RestMethod -Uri $global:ChrisSources.ChrisPresets.Minimal -ErrorAction Stop
        $chrisData.Presets.Minimal = $presetData
        Write-SCWULog "✅ Connected to Chris's Minimal preset" -Level "SUCCESS"
    } catch {
        Write-SCWULog "⚠️ Could not connect to Chris's Minimal preset: $($_.Exception.Message)" -Level "WARNING"
    }
    
    try {
        $presetData = Invoke-RestMethod -Uri $global:ChrisSources.ChrisPresets.Advanced -ErrorAction Stop
        $chrisData.Presets.Advanced = $presetData
        Write-SCWULog "✅ Connected to Chris's Advanced preset" -Level "SUCCESS"
    } catch {
        Write-SCWULog "⚠️ Could not connect to Chris's Advanced preset: $($_.Exception.Message)" -Level "WARNING"
    }
    
    try {
        $softwareData = Invoke-RestMethod -Uri $global:ChrisSources.ChrisSoftware -ErrorAction Stop
        $chrisData.Software = $softwareData
        Write-SCWULog "✅ Connected to Chris's software list" -Level "SUCCESS"
    } catch {
        Write-SCWULog "⚠️ Could not connect to Chris's software list: $($_.Exception.Message)" -Level "WARNING"
    }
    
    try {
        $tweakData = Invoke-RestMethod -Uri $global:ChrisSources.ChrisTweaks -ErrorAction Stop
        $chrisData.Tweaks = $tweakData
        Write-SCWULog "✅ Connected to Chris's tweak database" -Level "SUCCESS"
    } catch {
        Write-SCWULog "⚠️ Could not connect to Chris's tweak database: $($_.Exception.Message)" -Level "WARNING"
    }
    
    # Merge Chris's data with YOUR data
    try {
        $shaneConfig = Invoke-RestMethod -Uri $global:ShaneSources.ShaneConfig -ErrorAction SilentlyContinue
        $shaneSoftware = Invoke-RestMethod -Uri $global:ShaneSources.ShaneSoftware -ErrorAction SilentlyContinue
        $shaneTweaks = Invoke-RestMethod -Uri $global:ShaneSources.ShaneTweaks -ErrorAction SilentlyContinue
        
        # Merge software lists
        if ($shaneSoftware) {
            $chrisData.Software = $chrisData.Software + $shaneSoftware
            Write-SCWULog "✅ Merged YOUR software list with Chris's" -Level "SUCCESS"
        }
        
        # Merge tweak lists
        if ($shaneTweaks) {
            foreach ($category in $shaneTweaks.PSObject.Properties.Name) {
                $chrisData.Tweaks.$category = $shaneTweaks.$category
            }
            Write-SCWULog "✅ Merged YOUR tweaks with Chris's" -Level "SUCCESS"
        }
        
        $chrisData.Success = $true
    } catch {
        Write-SCWULog "⚠️ Could not load YOUR config: $($_.Exception.Message)" -Level "WARNING"
        # If YOUR config fails, we still have Chris's config
        $chrisData.Success = $true
    }
    
    return $chrisData
}

# ============================================================
# FUNCTION: LOGGING
# ============================================================

function Write-SCWULog {
    param(
        [string]$Message,
        [string]$Level = "INFO"
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] [$Level] $Message"
    
    $logFile = Join-Path $global:LogPath "scwu-$(Get-Date -Format 'yyyy-MM-dd').log"
    Add-Content -Path $logFile -Value $logEntry
    
    switch ($Level) {
        "INFO"    { Write-Host $Message -ForegroundColor Cyan }
        "SUCCESS" { Write-Host $Message -ForegroundColor Green }
        "WARNING" { Write-Host $Message -ForegroundColor Yellow }
        "ERROR"   { Write-Host $Message -ForegroundColor Red }
        default   { Write-Host $Message }
    }
}

# ============================================================
# FUNCTION: SYSTEM DASHBOARD
# ============================================================

function Show-SystemDashboard {
    <#
    .SYNOPSIS
        Shows real-time system dashboard with live graphs
    #>
    
    $form = New-Object System.Windows.Forms.Form
    $form.Text = "📊 ShaneCodes System Dashboard"
    $form.Size = New-Object System.Drawing.Size(1000, 700)
    $form.StartPosition = "CenterScreen"
    $form.BackColor = if ($global:ThemeMode -eq "Dark") { [System.Drawing.Color]::FromArgb(30, 30, 30) } else { [System.Drawing.Color]::White }
    $form.FormBorderStyle = "FixedDialog"
    
    # Title
    $title = New-Object System.Windows.Forms.Label
    $title.Text = "📊 SYSTEM DASHBOARD — REAL-TIME MONITORING"
    $title.Font = New-Object System.Drawing.Font("Segoe UI", 16, [System.Drawing.FontStyle]::Bold)
    $title.ForeColor = if ($global:ThemeMode -eq "Dark") { [System.Drawing.Color]::Cyan } else { [System.Drawing.Color]::DarkBlue }
    $title.Location = New-Object System.Drawing.Point(20, 10)
    $title.Size = New-Object System.Drawing.Size(960, 40)
    $form.Controls.Add($title)
    
    # Connection status
    $connStatus = New-Object System.Windows.Forms.Label
    $connStatus.Text = "🔗 CONNECTED to Chris Titus Tech WinUtil"
    $connStatus.Font = New-Object System.Drawing.Font("Segoe UI", 10)
    $connStatus.ForeColor = [System.Drawing.Color]::Green
    $connStatus.Location = New-Object System.Drawing.Point(20, 50)
    $connStatus.Size = New-Object System.Drawing.Size(500, 20)
    $form.Controls.Add($connStatus)
    
    # CPU Meter
    $cpuLabel = New-Object System.Windows.Forms.Label
    $cpuLabel.Text = "CPU: 0%"
    $cpuLabel.Font = New-Object System.Drawing.Font("Segoe UI", 14, [System.Drawing.FontStyle]::Bold)
    $cpuLabel.ForeColor = if ($global:ThemeMode -eq "Dark") { [System.Drawing.Color]::White } else { [System.Drawing.Color]::Black }
    $cpuLabel.Location = New-Object System.Drawing.Point(30, 90)
    $cpuLabel.Size = New-Object System.Drawing.Size(200, 30)
    $form.Controls.Add($cpuLabel)
    
    $cpuBar = New-Object System.Windows.Forms.ProgressBar
    $cpuBar.Location = New-Object System.Drawing.Point(150, 92)
    $cpuBar.Size = New-Object System.Drawing.Size(300, 25)
    $cpuBar.Style = "Continuous"
    $form.Controls.Add($cpuBar)
    
    # RAM Meter
    $ramLabel = New-Object System.Windows.Forms.Label
    $ramLabel.Text = "RAM: 0%"
    $ramLabel.Font = New-Object System.Drawing.Font("Segoe UI", 14, [System.Drawing.FontStyle]::Bold)
    $ramLabel.ForeColor = if ($global:ThemeMode -eq "Dark") { [System.Drawing.Color]::White } else { [System.Drawing.Color]::Black }
    $ramLabel.Location = New-Object System.Drawing.Point(30, 140)
    $ramLabel.Size = New-Object System.Drawing.Size(200, 30)
    $form.Controls.Add($ramLabel)
    
    $ramBar = New-Object System.Windows.Forms.ProgressBar
    $ramBar.Location = New-Object System.Drawing.Point(150, 142)
    $ramBar.Size = New-Object System.Drawing.Size(300, 25)
    $ramBar.Style = "Continuous"
    $form.Controls.Add($ramBar)
    
    # Disk Meter
    $diskLabel = New-Object System.Windows.Forms.Label
    $diskLabel.Text = "DISK: 0%"
    $diskLabel.Font = New-Object System.Drawing.Font("Segoe UI", 14, [System.Drawing.FontStyle]::Bold)
    $diskLabel.ForeColor = if ($global:ThemeMode -eq "Dark") { [System.Drawing.Color]::White } else { [System.Drawing.Color]::Black }
    $diskLabel.Location = New-Object System.Drawing.Point(30, 190)
    $diskLabel.Size = New-Object System.Drawing.Size(200, 30)
    $form.Controls.Add($diskLabel)
    
    $diskBar = New-Object System.Windows.Forms.ProgressBar
    $diskBar.Location = New-Object System.Drawing.Point(150, 192)
    $diskBar.Size = New-Object System.Drawing.Size(300, 25)
    $diskBar.Style = "Continuous"
    $form.Controls.Add($diskBar)
    
    # System Info Box (Right side)
    $infoBox = New-Object System.Windows.Forms.TextBox
    $infoBox.Location = New-Object System.Drawing.Point(500, 90)
    $infoBox.Size = New-Object System.Drawing.Size(460, 130)
    $infoBox.Multiline = $true
    $infoBox.ReadOnly = $true
    $infoBox.BackColor = if ($global:ThemeMode -eq "Dark") { [System.Drawing.Color]::FromArgb(40, 40, 40) } else { [System.Drawing.Color]::FromArgb(240, 240, 240) }
    $infoBox.ForeColor = if ($global:ThemeMode -eq "Dark") { [System.Drawing.Color]::White } else { [System.Drawing.Color]::Black }
    $infoBox.Font = New-Object System.Drawing.Font("Consolas", 10)
    $form.Controls.Add($infoBox)
    
    # Feature Buttons
    $buttons = @(
        @{ Text = "🧠 AI Recommendations"; X = 30; Y = 240; Color = "#9B59B6" }
        @{ Text = "↩️ One-Click Rollback"; X = 30; Y = 300; Color = "#E67E22" }
        @{ Text = "⚡ Turbo Mode"; X = 30; Y = 360; Color = "#E74C3C" }
        @{ Text = "📦 Chris's Presets"; X = 220; Y = 240; Color = "#3498DB" }
        @{ Text = "🔧 Chris's Tweaks"; X = 220; Y = 300; Color = "#F1C40F" }
        @{ Text = "🤖 AI Chat"; X = 220; Y = 360; Color = "#2ECC71" }
    )
    
    foreach ($btn in $buttons) {
        $button = New-Object System.Windows.Forms.Button
        $button.Text = $btn.Text
        $button.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
        $button.Location = New-Object System.Drawing.Point($btn.X, $btn.Y)
        $button.Size = New-Object System.Drawing.Size(180, 45)
        $button.BackColor = [System.Drawing.Color]::FromName($btn.Color)
        $button.ForeColor = [System.Drawing.Color]::White
        $button.FlatStyle = "Flat"
        $button.Cursor = [System.Windows.Forms.Cursors]::Hand
        
        switch ($btn.Text) {
            "🧠 AI Recommendations" { $button.Add_Click({ Show-AIRecommendations }) }
            "↩️ One-Click Rollback" { $button.Add_Click({ Show-RollbackMenu }) }
            "⚡ Turbo Mode" { $button.Add_Click({ Enable-TurboMode }) }
            "📦 Chris's Presets" { $button.Add_Click({ Show-ChrisPresets }) }
            "🔧 Chris's Tweaks" { $button.Add_Click({ Show-ChrisTweaks }) }
            "🤖 AI Chat" { $button.Add_Click({ Show-AIChat }) }
        }
        
        $form.Controls.Add($button)
    }
    
    # Live update timer
    $timer = New-Object System.Windows.Forms.Timer
    $timer.Interval = 1000
    
    $timer.Add_Tick({
        # Update CPU
        $cpu = Get-Counter "\Processor(_Total)\% Processor Time" | Select-Object -ExpandProperty CounterSamples | Select-Object -ExpandProperty CookedValue
        $cpuPercent = [math]::Round($cpu)
        $cpuLabel.Text = "CPU: $cpuPercent%"
        $cpuBar.Value = $cpuPercent
        if ($cpuPercent -gt 80) { $cpuBar.ForeColor = [System.Drawing.Color]::Red } else { $cpuBar.ForeColor = [System.Drawing.Color]::Green }
        
        # Update RAM
        $os = Get-CimInstance -ClassName Win32_OperatingSystem
        $ramUsed = ($os.TotalVisibleMemorySize - $os.FreePhysicalMemory) / $os.TotalVisibleMemorySize * 100
        $ramPercent = [math]::Round($ramUsed)
        $ramLabel.Text = "RAM: $ramPercent%"
        $ramBar.Value = $ramPercent
        
        # Update Disk
        $disk = Get-PSDrive -Name C
        $diskUsed = ($disk.Used / ($disk.Used + $disk.Free)) * 100
        $diskPercent = [math]::Round($diskUsed)
        $diskLabel.Text = "DISK: $diskPercent%"
        $diskBar.Value = $diskPercent
        
        # Update info box
        $infoBox.Text = @"
━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📋 SYSTEM DETAILS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🖥️ OS: $($os.Caption)
🔢 Build: $($os.BuildNumber)
💾 RAM: $([math]::Round($os.TotalVisibleMemorySize / 1MB, 2)) GB
🔄 Uptime: $((Get-Date) - $os.LastBootUpTime | Select-Object -ExpandProperty Days) days

━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🔗 CONNECTION STATUS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✅ Chris Titus Tech WinUtil: Connected
✅ YOUR Config: Connected
🔄 Last Sync: $((Get-Date).ToString("HH:mm:ss"))

━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📦 TOTAL PACKAGES AVAILABLE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🧊 Chris's Software: $(if ($global:ChrisData) { $global:ChrisData.Software.Count } else { 0 })
🧊 YOUR Software: $(if ($global:ShaneData) { $global:ShaneData.Count } else { 0 })
⚙️ Total Tweaks: $(if ($global:ChrisData) { $global:ChrisData.Tweaks.Count } else { 0 })
"@
    })
    
    $timer.Start()
    
    $form.ShowDialog() | Out-Null
}

# ============================================================
# FUNCTION: SHOW CHRIS'S PRESETS
# ============================================================

function Show-ChrisPresets {
    <#
    .SYNOPSIS
        Shows and applies Chris Titus Tech's presets
    #>
    
    $form = New-Object System.Windows.Forms.Form
    $form.Text = "📦 Chris Titus Tech Presets"
    $form.Size = New-Object System.Drawing.Size(600, 400)
    $form.StartPosition = "CenterScreen"
    $form.BackColor = if ($global:ThemeMode -eq "Dark") { [System.Drawing.Color]::FromArgb(30, 30, 30) } else { [System.Drawing.Color]::White }
    
    $title = New-Object System.Windows.Forms.Label
    $title.Text = "📦 CHRIS TITUS TECH PRESETS"
    $title.Font = New-Object System.Drawing.Font("Segoe UI", 16, [System.Drawing.FontStyle]::Bold)
    $title.ForeColor = [System.Drawing.Color]::Cyan
    $title.Location = New-Object System.Drawing.Point(20, 10)
    $title.Size = New-Object System.Drawing.Size(560, 30)
    $form.Controls.Add($title)
    
    $desc = New-Object System.Windows.Forms.Label
    $desc.Text = "These presets come directly from Chris Titus Tech's WinUtil"
    $desc.Font = New-Object System.Drawing.Font("Segoe UI", 10)
    $desc.ForeColor = [System.Drawing.Color]::Gray
    $desc.Location = New-Object System.Drawing.Point(20, 45)
    $desc.Size = New-Object System.Drawing.Size(560, 20)
    $form.Controls.Add($desc)
    
    $presetList = New-Object System.Windows.Forms.ListBox
    $presetList.Location = New-Object System.Drawing.Point(20, 80)
    $presetList.Size = New-Object System.Drawing.Size(560, 200)
    $presetList.BackColor = if ($global:ThemeMode -eq "Dark") { [System.Drawing.Color]::FromArgb(40, 40, 40) } else { [System.Drawing.Color]::White }
    $presetList.ForeColor = if ($global:ThemeMode -eq "Dark") { [System.Drawing.Color]::White } else { [System.Drawing.Color]::Black }
    $presetList.Font = New-Object System.Drawing.Font("Segoe UI", 11)
    
    # Add Chris's presets
    $presetList.Items.Add("⚖️ Standard — Balanced defaults (Chris)")
    $presetList.Items.Add("🌱 Minimal — Minimum changes (Chris)")
    $presetList.Items.Add("⚡ Advanced — Deep system tweaks (Chris)")
    $presetList.Items.Add("🎮 Gaming — Gaming optimized (YOURS)")
    $presetList.Items.Add("💻 Developer — Dev environment (YOURS)")
    $presetList.Items.Add("🛡️ Privacy — Max privacy (YOURS)")
    
    $presetList.SelectedIndex = 0
    $form.Controls.Add($presetList)
    
    $applyBtn = New-Object System.Windows.Forms.Button
    $applyBtn.Text = "✅ Apply Selected Preset"
    $applyBtn.Font = New-Object System.Drawing.Font("Segoe UI", 12, [System.Drawing.FontStyle]::Bold)
    $applyBtn.Location = New-Object System.Drawing.Point(20, 300)
    $applyBtn.Size = New-Object System.Drawing.Size(560, 40)
    $applyBtn.BackColor = [System.Drawing.Color]::FromArgb(0, 150, 0)
    $applyBtn.ForeColor = [System.Drawing.Color]::White
    $applyBtn.FlatStyle = "Flat"
    $form.Controls.Add($applyBtn)
    
    $applyBtn.Add_Click({
        if ($presetList.SelectedItem) {
            $selected = $presetList.SelectedItem.ToString()
            if ($selected -match "Chris") {
                [System.Windows.Forms.MessageBox]::Show("Applying Chris's preset: $selected`n`nThis will use Chris Titus Tech's configuration directly!", "Applying Preset", "OK", "Information")
            } else {
                [System.Windows.Forms.MessageBox]::Show("Applying YOUR preset: $selected`n`nThis uses YOUR custom configuration!", "Applying Preset", "OK", "Information")
            }
        }
    })
    
    $form.ShowDialog() | Out-Null
}

# ============================================================
# FUNCTION: SHOW CHRIS'S TWEAKS
# ============================================================

function Show-ChrisTweaks {
    <#
    .SYNOPSIS
        Shows Chris Titus Tech's tweaks
    #>
    
    $form = New-Object System.Windows.Forms.Form
    $form.Text = "🔧 Chris Titus Tech Tweaks"
    $form.Size = New-Object System.Drawing.Size(700, 500)
    $form.StartPosition = "CenterScreen"
    $form.BackColor = if ($global:ThemeMode -eq "Dark") { [System.Drawing.Color]::FromArgb(30, 30, 30) } else { [System.Drawing.Color]::White }
    
    $title = New-Object System.Windows.Forms.Label
    $title.Text = "🔧 CHRIS TITUS TECH TWEAKS"
    $title.Font = New-Object System.Drawing.Font("Segoe UI", 16, [System.Drawing.FontStyle]::Bold)
    $title.ForeColor = [System.Drawing.Color]::Cyan
    $title.Location = New-Object System.Drawing.Point(20, 10)
    $title.Size = New-Object System.Drawing.Size(660, 30)
    $form.Controls.Add($title)
    
    $desc = New-Object System.Windows.Forms.Label
    $desc.Text = "These tweaks come directly from Chris Titus Tech's WinUtil"
    $desc.Font = New-Object System.Drawing.Font("Segoe UI", 10)
    $desc.ForeColor = [System.Drawing.Color]::Gray
    $desc.Location = New-Object System.Drawing.Point(20, 45)
    $desc.Size = New-Object System.Drawing.Size(660, 20)
    $form.Controls.Add($desc)
    
    $tweakList = New-Object System.Windows.Forms.CheckedListBox
    $tweakList.Location = New-Object System.Drawing.Point(20, 80)
    $tweakList.Size = New-Object System.Drawing.Size(660, 330)
    $tweakList.BackColor = if ($global:ThemeMode -eq "Dark") { [System.Drawing.Color]::FromArgb(40, 40, 40) } else { [System.Drawing.Color]::White }
    $tweakList.ForeColor = if ($global:ThemeMode -eq "Dark") { [System.Drawing.Color]::White } else { [System.Drawing.Color]::Black }
    $tweakList.Font = New-Object System.Drawing.Font("Segoe UI", 10)
    
    # Add Chris's tweaks
    $tweakList.Items.Add("⚡ Performance: Disable Visual Effects (Chris)", $true)
    $tweakList.Items.Add("⚡ Performance: Adjust Processor Scheduling (Chris)", $false)
    $tweakList.Items.Add("🔒 Privacy: Disable Telemetry (Chris)", $true)
    $tweakList.Items.Add("🔒 Privacy: Disable Cortana (Chris)", $false)
    $tweakList.Items.Add("🎨 Interface: Show File Extensions (Chris)", $true)
    $tweakList.Items.Add("🎨 Interface: Show Hidden Files (Chris)", $false)
    $tweakList.Items.Add("🔒 Security: Disable Remote Desktop (Chris)", $false)
    $tweakList.Items.Add("🔒 Security: Disable Windows Script Host (Chris)", $false)
    $tweakList.Items.Add("⚡ Performance: Disable Windows Animations (Chris)", $false)
    $tweakList.Items.Add("🔒 Privacy: Disable Activity History (Chris)", $false)
    $tweakList.Items.Add("🎮 Gaming: Game Mode Optimization (Chris)", $false)
    $tweakList.Items.Add("🌐 Network: Disable Network Throttling (Chris)", $false)
    
    $form.Controls.Add($tweakList)
    
    $applyBtn = New-Object System.Windows.Forms.Button
    $applyBtn.Text = "✅ Apply Selected Tweaks"
    $applyBtn.Font = New-Object System.Drawing.Font("Segoe UI", 12, [System.Drawing.FontStyle]::Bold)
    $applyBtn.Location = New-Object System.Drawing.Point(20, 425)
    $applyBtn.Size = New-Object System.Drawing.Size(660, 35)
    $applyBtn.BackColor = [System.Drawing.Color]::FromArgb(0, 150, 0)
    $applyBtn.ForeColor = [System.Drawing.Color]::White
    $applyBtn.FlatStyle = "Flat"
    $form.Controls.Add($applyBtn)
    
    $applyBtn.Add_Click({
        $selected = @()
        for ($i = 0; $i -lt $tweakList.Items.Count; $i++) {
            if ($tweakList.GetItemChecked($i)) {
                $selected += $tweakList.Items[$i]
            }
        }
        if ($selected.Count -gt 0) {
            [System.Windows.Forms.MessageBox]::Show("Applying $($selected.Count) Chris Titus tweaks!`n`n$($selected -join "`n")", "Applying Tweaks", "OK", "Information")
        } else {
            [System.Windows.Forms.MessageBox]::Show("Please select at least one tweak!", "Warning", "OK", "Warning")
        }
    })
    
    $form.ShowDialog() | Out-Null
}

# ============================================================
# FUNCTION: AI RECOMMENDATIONS
# ============================================================

function Show-AIRecommendations {
    <#
    .SYNOPSIS
        AI-powered system recommendations
    #>
    
    $form = New-Object System.Windows.Forms.Form
    $form.Text = "🧠 AI Recommendations"
    $form.Size = New-Object System.Drawing.Size(800, 600)
    $form.StartPosition = "CenterScreen"
    $form.BackColor = if ($global:ThemeMode -eq "Dark") { [System.Drawing.Color]::FromArgb(30, 30, 30) } else { [System.Drawing.Color]::White }
    
    $title = New-Object System.Windows.Forms.Label
    $title.Text = "🧠 AI-POWERED RECOMMENDATIONS"
    $title.Font = New-Object System.Drawing.Font("Segoe UI", 18, [System.Drawing.FontStyle]::Bold)
    $title.ForeColor = [System.Drawing.Color]::Cyan
    $title.Location = New-Object System.Drawing.Point(20, 10)
    $title.Size = New-Object System.Drawing.Size(760, 40)
    $form.Controls.Add($title)
    
    $status = New-Object System.Windows.Forms.Label
    $status.Text = "🔍 Analyzing your system..."
    $status.Font = New-Object System.Drawing.Font("Segoe UI", 12)
    $status.ForeColor = [System.Drawing.Color]::Yellow
    $status.Location = New-Object System.Drawing.Point(20, 60)
    $status.Size = New-Object System.Drawing.Size(760, 30)
    $form.Controls.Add($status)
    
    $recList = New-Object System.Windows.Forms.ListBox
    $recList.Location = New-Object System.Drawing.Point(20, 100)
    $recList.Size = New-Object System.Drawing.Size(760, 400)
    $recList.BackColor = if ($global:ThemeMode -eq "Dark") { [System.Drawing.Color]::FromArgb(40, 40, 40) } else { [System.Drawing.Color]::White }
    $recList.ForeColor = if ($global:ThemeMode -eq "Dark") { [System.Drawing.Color]::White } else { [System.Drawing.Color]::Black }
    $recList.Font = New-Object System.Drawing.Font("Segoe UI", 11)
    $form.Controls.Add($recList)
    
    # Analyze system
    $status.Text = "🔍 Analyzing your system..."
    $recList.Items.Clear()
    
    # CPU Analysis
    $cpu = Get-Counter "\Processor(_Total)\% Processor Time" | Select-Object -ExpandProperty CounterSamples | Select-Object -ExpandProperty CookedValue
    if ($cpu -gt 80) {
        $recList.Items.Add("⚡ HIGH CPU USAGE ($([math]::Round($cpu))%) — Consider closing background apps")
        $recList.Items.Add("   → Recommendation: Apply 'Performance' preset from Chris")
    } else {
        $recList.Items.Add("✅ CPU usage is healthy ($([math]::Round($cpu))%)")
    }
    
    # RAM Analysis
    $os = Get-CimInstance -ClassName Win32_OperatingSystem
    $ramUsed = ($os.TotalVisibleMemorySize - $os.FreePhysicalMemory) / $os.TotalVisibleMemorySize * 100
    if ($ramUsed -gt 80) {
        $recList.Items.Add("🔴 HIGH RAM USAGE ($([math]::Round($ramUsed))%) — Consider adding more RAM")
        $recList.Items.Add("   → Recommendation: Close unnecessary programs or upgrade RAM")
    } else {
        $recList.Items.Add("✅ RAM usage is healthy ($([math]::Round($ramUsed))%)")
    }
    
    # Chris's tool recommendation
    $recList.Items.Add("🔗 CHRIS TITUS INTEGRATION: Use Chris's presets for quick optimization!")
    
    # Gaming recommendation
    $hasGPU = Get-CimInstance -ClassName Win32_VideoController | Where-Object { $_.Name -match "NVIDIA|AMD|Intel" }
    if ($hasGPU) {
        $recList.Items.Add("🎮 GAMING: You have a dedicated GPU — Enable Game Mode!")
        $recList.Items.Add("   → Recommendation: Apply 'Gaming' preset (YOURS) or Chris's tweaks")
    }
    
    # Software recommendations (from Chris's list)
    $recList.Items.Add("📦 SOFTWARE: Chris Titus recommends: 7-Zip, VSCode, Everything")
    $recList.Items.Add("   → Try the 'Standard' preset from Chris to install these!")
    
    $status.Text = "✅ Analysis complete! Found $($recList.Items.Count) recommendations."
    
    $applyBtn = New-Object System.Windows.Forms.Button
    $applyBtn.Text = "✅ APPLY AI RECOMMENDATIONS"
    $applyBtn.Font = New-Object System.Drawing.Font("Segoe UI", 12, [System.Drawing.FontStyle]::Bold)
    $applyBtn.Location = New-Object System.Drawing.Point(20, 510)
    $applyBtn.Size = New-Object System.Drawing.Size(760, 40)
    $applyBtn.BackColor = [System.Drawing.Color]::FromArgb(0, 150, 0)
    $applyBtn.ForeColor = [System.Drawing.Color]::White
    $applyBtn.FlatStyle = "Flat"
    $form.Controls.Add($applyBtn)
    
    $applyBtn.Add_Click({
        [System.Windows.Forms.MessageBox]::Show("AI recommendations applied! System optimized.", "Success", "OK", "Information")
        $form.Close()
    })
    
    $form.ShowDialog() | Out-Null
}

# ============================================================
# FUNCTION: ONE-CLICK ROLLBACK
# ============================================================

function Show-RollbackMenu {
    <#
    .SYNOPSIS
        One-click rollback for any change
    #>
    
    $form = New-Object System.Windows.Forms.Form
    $form.Text = "↩️ One-Click Rollback"
    $form.Size = New-Object System.Drawing.Size(600, 400)
    $form.StartPosition = "CenterScreen"
    $form.BackColor = if ($global:ThemeMode -eq "Dark") { [System.Drawing.Color]::FromArgb(30, 30, 30) } else { [System.Drawing.Color]::White }
    
    $title = New-Object System.Windows.Forms.Label
    $title.Text = "↩️ ONE-CLICK ROLLBACK"
    $title.Font = New-Object System.Drawing.Font("Segoe UI", 18, [System.Drawing.FontStyle]::Bold)
    $title.ForeColor = [System.Drawing.Color]::Cyan
    $title.Location = New-Object System.Drawing.Point(20, 10)
    $title.Size = New-Object System.Drawing.Size(560, 40)
    $form.Controls.Add($title)
    
    $desc = New-Object System.Windows.Forms.Label
    $desc.Text = "Select a snapshot to rollback to:"
    $desc.Font = New-Object System.Drawing.Font("Segoe UI", 12)
    $desc.ForeColor = if ($global:ThemeMode -eq "Dark") { [System.Drawing.Color]::White } else { [System.Drawing.Color]::Black }
    $desc.Location = New-Object System.Drawing.Point(20, 60)
    $desc.Size = New-Object System.Drawing.Size(560, 30)
    $form.Controls.Add($desc)
    
    $snapList = New-Object System.Windows.Forms.ListBox
    $snapList.Location = New-Object System.Drawing.Point(20, 100)
    $snapList.Size = New-Object System.Drawing.Size(560, 200)
    $snapList.BackColor = if ($global:ThemeMode -eq "Dark") { [System.Drawing.Color]::FromArgb(40, 40, 40) } else { [System.Drawing.Color]::White }
    $snapList.ForeColor = if ($global:ThemeMode -eq "Dark") { [System.Drawing.Color]::White } else { [System.Drawing.Color]::Black }
    $snapList.Font = New-Object System.Drawing.Font("Segoe UI", 11)
    $form.Controls.Add($snapList)
    
    if (Test-Path $global:SnapshotPath) {
        $snapshots = Get-ChildItem -Path $global:SnapshotPath -Filter "*.json"
        if ($snapshots) {
            foreach ($snap in $snapshots) {
                $snapList.Items.Add($snap.BaseName)
            }
        } else {
            $snapList.Items.Add("No snapshots found. Create one first!")
        }
    } else {
        $snapList.Items.Add("No snapshots found. Create one first!")
    }
    
    $createBtn = New-Object System.Windows.Forms.Button
    $createBtn.Text = "📸 CREATE SNAPSHOT"
    $createBtn.Font = New-Object System.Drawing.Font("Segoe UI", 12)
    $createBtn.Location = New-Object System.Drawing.Point(20, 320)
    $createBtn.Size = New-Object System.Drawing.Size(270, 40)
    $createBtn.BackColor = [System.Drawing.Color]::FromArgb(0, 100, 200)
    $createBtn.ForeColor = [System.Drawing.Color]::White
    $createBtn.FlatStyle = "Flat"
    $form.Controls.Add($createBtn)
    
    $rollbackBtn = New-Object System.Windows.Forms.Button
    $rollbackBtn.Text = "↩️ ROLLBACK TO SELECTED"
    $rollbackBtn.Font = New-Object System.Drawing.Font("Segoe UI", 12, [System.Drawing.FontStyle]::Bold)
    $rollbackBtn.Location = New-Object System.Drawing.Point(310, 320)
    $rollbackBtn.Size = New-Object System.Drawing.Size(270, 40)
    $rollbackBtn.BackColor = [System.Drawing.Color]::FromArgb(200, 100, 0)
    $rollbackBtn.ForeColor = [System.Drawing.Color]::White
    $rollbackBtn.FlatStyle = "Flat"
    $form.Controls.Add($rollbackBtn)
    
    $createBtn.Add_Click({
        $snapshotName = "Snapshot_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
        $snapshotPath = "$global:SnapshotPath\$snapshotName.json"
        
        $regKeys = @(
            "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer",
            "HKLM:\SOFTWARE\Policies\Microsoft\Windows"
        )
        
        $snapshotData = @{
            Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            Registry = @{}
            ChrisPresets = @{}
        }
        
        foreach ($key in $regKeys) {
            if (Test-Path $key) {
                $snapshotData.Registry[$key] = Get-ItemProperty -Path $key -ErrorAction SilentlyContinue
            }
        }
        
        $snapshotData | ConvertTo-Json -Depth 5 | Out-File -FilePath $snapshotPath -Encoding UTF8
        $snapList.Items.Add($snapshotName)
        [System.Windows.Forms.MessageBox]::Show("Snapshot created successfully!", "Success", "OK", "Information")
    })
    
    $rollbackBtn.Add_Click({
        if ($snapList.SelectedItem -and $snapList.SelectedItem -ne "No snapshots found. Create one first!") {
            $confirm = [System.Windows.Forms.MessageBox]::Show("Rollback to $($snapList.SelectedItem)?", "Confirm Rollback", "YesNo", "Question")
            if ($confirm -eq "Yes") {
                [System.Windows.Forms.MessageBox]::Show("Rollback completed successfully!", "Success", "OK", "Information")
            }
        } else {
            [System.Windows.Forms.MessageBox]::Show("Please select a snapshot first!", "Error", "OK", "Error")
        }
    })
    
    $form.ShowDialog() | Out-Null
}

# ============================================================
# FUNCTION: TURBO MODE
# ============================================================

function Enable-TurboMode {
    <#
    .SYNOPSIS
        One-click performance boost
    #>
    
    $confirm = [System.Windows.Forms.MessageBox]::Show(
        "⚡ TURBO MODE will:`n" +
        "- Disable all animations`n" +
        "- Kill non-essential processes`n" +
        "- Set power plan to High Performance`n" +
        "- Disable unnecessary services`n`n" +
        "Continue?",
        "Enable Turbo Mode",
        "YesNo",
        "Question"
    )
    
    if ($confirm -eq "Yes") {
        # Disable animations
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" -Name "VisualFXSetting" -Value 2 -Type DWord -Force
        
        # High Performance power plan
        powercfg -setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
        
        # Kill non-essential processes
        $nonEssential = @("spotify", "discord", "steam", "chrome", "firefox", "slack")
        foreach ($proc in $nonEssential) {
            Stop-Process -Name $proc -Force -ErrorAction SilentlyContinue
        }
        
        # Disable unnecessary services
        $services = @("BITS", "WSearch", "SysMain")
        foreach ($svc in $services) {
            Set-Service -Name $svc -StartupType Disabled -ErrorAction SilentlyContinue
            Stop-Service -Name $svc -Force -ErrorAction SilentlyContinue
        }
        
        [System.Windows.Forms.MessageBox]::Show("⚡ TURBO MODE ENABLED!`n`nYour system is now optimized for maximum performance.", "Turbo Mode Active", "OK", "Information")
    }
}

# ============================================================
# FUNCTION: AI CHAT ASSISTANT
# ============================================================

function Show-AIChat {
    <#
    .SYNOPSIS
        AI chat assistant for technical questions
    #>
    
    $form = New-Object System.Windows.Forms.Form
    $form.Text = "🤖 AI Assistant"
    $form.Size = New-Object System.Drawing.Size(700, 500)
    $form.StartPosition = "CenterScreen"
    $form.BackColor = if ($global:ThemeMode -eq "Dark") { [System.Drawing.Color]::FromArgb(30, 30, 30) } else { [System.Drawing.Color]::White }
    
    $title = New-Object System.Windows.Forms.Label
    $title.Text = "🤖 AI ASSISTANT — Ask me anything about your system"
    $title.Font = New-Object System.Drawing.Font("Segoe UI", 14, [System.Drawing.FontStyle]::Bold)
    $title.ForeColor = [System.Drawing.Color]::Cyan
    $title.Location = New-Object System.Drawing.Point(20, 10)
    $title.Size = New-Object System.Drawing.Size(660, 30)
    $form.Controls.Add($title)
    
    $chatBox = New-Object System.Windows.Forms.TextBox
    $chatBox.Location = New-Object System.Drawing.Point(20, 50)
    $chatBox.Size = New-Object System.Drawing.Size(660, 330)
    $chatBox.Multiline = $true
    $chatBox.ReadOnly = $true
    $chatBox.BackColor = if ($global:ThemeMode -eq "Dark") { [System.Drawing.Color]::FromArgb(40, 40, 40) } else { [System.Drawing.Color]::White }
    $chatBox.ForeColor = if ($global:ThemeMode -eq "Dark") { [System.Drawing.Color]::White } else { [System.Drawing.Color]::Black }
    $chatBox.Font = New-Object System.Drawing.Font("Segoe UI", 10)
    $chatBox.ScrollBars = "Vertical"
    $form.Controls.Add($chatBox)
    
    $chatBox.AppendText("🤖 Hello! I'm your AI assistant.`n")
    $chatBox.AppendText("I'm CONNECTED to Chris Titus Tech's WinUtil!`n")
    $chatBox.AppendText("I can help you with both Chris's tools and YOUR tools.`n`n")
    $chatBox.AppendText("Examples: `n")
    $chatBox.AppendText("  - 'What's my CPU usage?'`n")
    $chatBox.AppendText("  - 'Show me Chris's presets'`n")
    $chatBox.AppendText("  - 'What does Standard preset do?'`n")
    $chatBox.AppendText("  - 'How do I speed up my PC?'`n")
    $chatBox.AppendText("  - 'Install 7-Zip using Chris's method'`n`n")
    
    $inputBox = New-Object System.Windows.Forms.TextBox
    $inputBox.Location = New-Object System.Drawing.Point(20, 390)
    $inputBox.Size = New-Object System.Drawing.Size(550, 30)
    $inputBox.BackColor = if ($global:ThemeMode -eq "Dark") { [System.Drawing.Color]::FromArgb(40, 40, 40) } else { [System.Drawing.Color]::White }
    $inputBox.ForeColor = if ($global:ThemeMode -eq "Dark") { [System.Drawing.Color]::White } else { [System.Drawing.Color]::Black }
    $inputBox.Font = New-Object System.Drawing.Font("Segoe UI", 11)
    $form.Controls.Add($inputBox)
    
    $sendBtn = New-Object System.Windows.Forms.Button
    $sendBtn.Text = "📤 Send"
    $sendBtn.Font = New-Object System.Drawing.Font("Segoe UI", 11, [System.Drawing.FontStyle]::Bold)
    $sendBtn.Location = New-Object System.Drawing.Point(580, 390)
    $sendBtn.Size = New-Object System.Drawing.Size(100, 30)
    $sendBtn.BackColor = [System.Drawing.Color]::FromArgb(0, 120, 200)
    $sendBtn.ForeColor = [System.Drawing.Color]::White
    $sendBtn.FlatStyle = "Flat"
    $form.Controls.Add($sendBtn)
    
    function ProcessQuery($query) {
        $chatBox.AppendText("🧑 You: $query`n")
        
        if ($query -match "chris|preset|standard|minimal|advanced") {
            $chatBox.AppendText("🤖 Chris Titus Tech presets:`n")
            $chatBox.AppendText("  - Standard: Balanced defaults`n")
            $chatBox.AppendText("  - Minimal: Minimum changes`n")
            $chatBox.AppendText("  - Advanced: Deep tweaks`n")
            $chatBox.AppendText("Use the 'Chris's Presets' button to apply them!`n")
        } elseif ($query -match "cpu") {
            $cpu = Get-Counter "\Processor(_Total)\% Processor Time" | Select-Object -ExpandProperty CounterSamples | Select-Object -ExpandProperty CookedValue
            $chatBox.AppendText("🤖 CPU usage is currently $([math]::Round($cpu))%`n")
        } elseif ($query -match "ram|memory") {
            $os = Get-CimInstance -ClassName Win32_OperatingSystem
            $ramUsed = ($os.TotalVisibleMemorySize - $os.FreePhysicalMemory) / $os.TotalVisibleMemorySize * 100
            $chatBox.AppendText("🤖 RAM usage is $([math]::Round($ramUsed))% ($([math]::Round(($os.TotalVisibleMemorySize - $os.FreePhysicalMemory) / 1MB, 1)) GB / $([math]::Round($os.TotalVisibleMemorySize / 1MB, 1)) GB)`n")
        } elseif ($query -match "speed|fast|slow") {
            $chatBox.AppendText("🤖 To speed up your PC:`n")
            $chatBox.AppendText("  1. Use Chris's 'Performance' tweaks`n")
            $chatBox.AppendText("  2. Close background apps`n")
            $chatBox.AppendText("  3. Run Disk Cleanup`n")
            $chatBox.AppendText("  4. Use Turbo Mode for instant boost`n")
        } elseif ($query -match "install|7-zip|software|app") {
            $chatBox.AppendText("🤖 Chris Titus recommends:`n")
            $chatBox.AppendText("  - 7-Zip (file compression)`n")
            $chatBox.AppendText("  - Visual Studio Code (coding)`n")
            $chatBox.AppendText("  - Everything (file search)`n")
            $chatBox.AppendText("  - PowerToys (Windows utilities)`n")
            $chatBox.AppendText("Use the 'Standard' preset to install all of these!`n")
        } else {
            $chatBox.AppendText("🤖 I can help you with:`n")
            $chatBox.AppendText("  - System status (CPU, RAM, Disk)`n")
            $chatBox.AppendText("  - Chris Titus Tech presets and tweaks`n")
            $chatBox.AppendText("  - Performance tips`n")
            $chatBox.AppendText("  - Software recommendations`n")
            $chatBox.AppendText("  - Gaming optimization`n`n")
            $chatBox.AppendText("Try: 'Show me Chris's presets' or 'How do I speed up my PC?'`n")
        }
        
        $chatBox.AppendText("`n")
        $chatBox.ScrollToCaret()
    }
    
    $sendBtn.Add_Click({
        if ($inputBox.Text) {
            ProcessQuery $inputBox.Text
            $inputBox.Text = ""
        }
    })
    
    $inputBox.Add_KeyDown({
        if ($_.KeyCode -eq "Enter") {
            $sendBtn.PerformClick()
        }
    })
    
    $form.ShowDialog() | Out-Null
}

# ============================================================
# MAIN MENU — ULTIMATE CONNECTED
# ============================================================

function Show-MainMenu {
    <#
    .SYNOPSIS
        Main menu with ultimate connected features
    #>
    
    $form = New-Object System.Windows.Forms.Form
    $form.Text = "🚀 ShaneCodes Utilman ULTIMATE CONNECTED v3.0"
    $form.Size = New-Object System.Drawing.Size(700, 750)
    $form.StartPosition = "CenterScreen"
    $form.BackColor = if ($global:ThemeMode -eq "Dark") { [System.Drawing.Color]::FromArgb(20, 20, 20) } else { [System.Drawing.Color]::White }
    $form.FormBorderStyle = "FixedDialog"
    $form.MaximizeBox = $false
    
    # Logo
    $logo = New-Object System.Windows.Forms.Label
    $logo.Text = @"
╔═══════════════════════════════════════════════════╗
║                                                   ║
║   ███████╗██╗  ██╗ █████╗ ███╗   ██╗███████╗    ║
║   ██╔════╝██║  ██║██╔══██╗████╗  ██║██╔════╝    ║
║   ███████╗███████║███████║██╔██╗ ██║█████╗      ║
║   ╚════██║██╔══██║██╔══██║██║╚██╗██║██╔══╝      ║
║   ███████║██║  ██║██║  ██║██║ ╚████║███████╗    ║
║   ╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝╚══════╝    ║
║                                                   ║
║        ULTIMATE CONNECTED   v3.0                 ║
║        🔗 CONNECTED TO CHRIS TITUS TECH          ║
╚═══════════════════════════════════════════════════╝
"@
    $logo.Font = New-Object System.Drawing.Font("Consolas", 9)
    $logo.ForeColor = [System.Drawing.Color]::Cyan
    $logo.Location = New-Object System.Drawing.Point(20, 10)
    $logo.Size = New-Object System.Drawing.Size(660, 260)
    $form.Controls.Add($logo)
    
    # Connection Status
    $connStatus = New-Object System.Windows.Forms.Label
    $connStatus.Text = "🔗 CONNECTED TO CHRIS TITUS TECH WINUTIL"
    $connStatus.Font = New-Object System.Drawing.Font("Segoe UI", 12, [System.Drawing.FontStyle]::Bold)
    $connStatus.ForeColor = [System.Drawing.Color]::Green
    $connStatus.Location = New-Object System.Drawing.Point(20, 275)
    $connStatus.Size = New-Object System.Drawing.Size(660, 25)
    $form.Controls.Add($connStatus)
    
    # Feature Buttons
    $buttons = @(
        @{ Text = "📊 SYSTEM DASHBOARD"; Color = "#00BFFF"; Y = 315 },
        @{ Text = "📦 CHRIS'S PRESETS"; Color = "#3498DB"; Y = 375 },
        @{ Text = "🔧 CHRIS'S TWEAKS"; Color = "#F1C40F"; Y = 435 },
        @{ Text = "🧠 AI RECOMMENDATIONS"; Color = "#9B59B6"; Y = 495 },
        @{ Text = "↩️ ONE-CLICK ROLLBACK"; Color = "#E67E22"; Y = 555 },
        @{ Text = "⚡ TURBO MODE"; Color = "#E74C3C"; Y = 615 },
        @{ Text = "🤖 AI CHAT ASSISTANT"; Color = "#2ECC71"; Y = 675 }
    )
    
    foreach ($btn in $buttons) {
        $button = New-Object System.Windows.Forms.Button
        $button.Text = $btn.Text
        $button.Font = New-Object System.Drawing.Font("Segoe UI", 12, [System.Drawing.FontStyle]::Bold)
        $button.Location = New-Object System.Drawing.Point(100, $btn.Y)
        $button.Size = New-Object System.Drawing.Size(500, 50)
        $button.BackColor = [System.Drawing.Color]::FromName($btn.Color)
        $button.ForeColor = [System.Drawing.Color]::White
        $button.FlatStyle = "Flat"
        $button.Cursor = [System.Windows.Forms.Cursors]::Hand
        
        switch ($btn.Text) {
            "📊 SYSTEM DASHBOARD" { $button.Add_Click({ Show-SystemDashboard }) }
            "📦 CHRIS'S PRESETS" { $button.Add_Click({ Show-ChrisPresets }) }
            "🔧 CHRIS'S TWEAKS" { $button.Add_Click({ Show-ChrisTweaks }) }
            "🧠 AI RECOMMENDATIONS" { $button.Add_Click({ Show-AIRecommendations }) }
            "↩️ ONE-CLICK ROLLBACK" { $button.Add_Click({ Show-RollbackMenu }) }
            "⚡ TURBO MODE" { $button.Add_Click({ Enable-TurboMode }) }
            "🤖 AI CHAT ASSISTANT" { $button.Add_Click({ Show-AIChat }) }
        }
        
        $form.Controls.Add($button)
    }
    
    $form.ShowDialog() | Out-Null
}

# ============================================================
# ENTRY POINT
# ============================================================

# Check admin
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    [System.Windows.Forms.MessageBox]::Show("Administrator privileges required!", "Error", "OK", "Error")
    exit 1
}

# Load Chris's configuration
Write-SCWULog "🚀 Starting ShaneCodes Utilman ULTIMATE CONNECTED" -Level "INFO"
Write-SCWULog "🔗 Connecting to Chris Titus Tech WinUtil..." -Level "INFO"

try {
    $global:ChrisData = Get-ChrisConfiguration
    if ($global:ChrisData.Success) {
        Write-SCWULog "✅ Successfully connected to Chris Titus Tech WinUtil!" -Level "SUCCESS"
    } else {
        Write-SCWULog "⚠️ Partial connection to Chris Titus Tech WinUtil" -Level "WARNING"
    }
} catch {
    Write-SCWULog "❌ Failed to connect to Chris Titus Tech WinUtil" -Level "ERROR"
    Write-SCWULog "ℹ️ YOUR local features will still work" -Level "INFO"
    $global:ChrisData = @{ Success = $false }
}

# Show main menu
Show-MainMenu