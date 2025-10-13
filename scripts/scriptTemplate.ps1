Param (
    [String] [Parameter(Mandatory=$False)] $logfile = "script_log_file.log"
)

# Imports

# Variables

# Functions
Function Write-LogMessage {
    param(
        [string] $message
    )
    $timestamp = Get-Date -format "yyyy-MM-dd HH:mm:ss.fff"
    Write-Host $timestamp $message
    Write-Output "$timestamp $message" | Out-File $logfile ascii -Append
}

# Execution starts below
$start_ts = Get-Date
Set-LogFileName -filename $logfile
Write-LogMessage -message "Script started"

###
# New code goes in this section
###

$finish_ts = Get-Date
$runtime = $($finish_ts - $start_ts).TotalSeconds
Write-LogMessage -message $("Script complete in " + $runtime + " seconds.")