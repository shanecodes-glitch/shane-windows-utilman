function Get-SystemInfo {
    <#
    .SYNOPSIS
        Displays detailed system information.
    .DESCRIPTION
        Shows OS, hardware, and system configuration details.
    #>
    
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
║  RAM SLOTS USED    : $($ram.Count) / $(if((Get-CimInstance -ClassName Win32_PhysicalMemoryArray).MemoryDevices) { (Get-CimInstance -ClassName Win32_PhysicalMemoryArray).MemoryDevices } else { "Unknown" })
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
        Write-Log "System info displayed"
    } catch {
        Write-Host "Error retrieving system information: $_" -ForegroundColor Red
        Write-Log "System info error: $_" "ERROR"
    }
}