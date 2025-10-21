Param (
    [String] [Parameter(Mandatory=$true)] $inputFile,
    [bool] [Parameter(Mandatory=$False)] $log = $False,
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
if ($log) { Write-LogMessage -message "Script started" }

###
# New code goes in this section
# Need to read the data
# Options: Get-Content & Select-String
# Select-String ideal for single line matches
# [regex]::Matches() better choice for multi-line data
# Use -match or [regex]::Match() or [regex]::Matches() with Get-Content
###

$finish_ts = Get-Date
$runtime = $($finish_ts - $start_ts).TotalSeconds
if ($log) { Write-LogMessage -message $("Script complete in " + $runtime + " seconds.") }