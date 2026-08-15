function Write-Log {
    <#
    .SYNOPSIS
        Writes a message to the log file and console.
    .DESCRIPTION
        Centralized logging function with timestamp and level.
    .PARAMETER Message
        The message to log.
    .PARAMETER Level
        The log level (INFO, WARNING, ERROR).
    #>
    
    param(
        [Parameter(Mandatory=$true)]
        [string]$Message,
        [Parameter(Mandatory=$false)]
        [ValidateSet("INFO", "WARNING", "ERROR")]
        [string]$Level = "INFO"
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] [$Level] $Message"
    
    # Write to console with color
    $color = switch ($Level) {
        "INFO"    { "White" }
        "WARNING" { "Yellow" }
        "ERROR"   { "Red" }
        default   { "White" }
    }
    Write-Host $logEntry -ForegroundColor $color
    
    # Write to log file
    try {
        Add-Content -Path $global:LogPath -Value $logEntry -ErrorAction SilentlyContinue
    } catch {
        # Silently fail if log can't be written
    }
}