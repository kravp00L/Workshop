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

# New code goes in this section
# Read email from file, not using -Raw because don't care about multiline
$email_content = Get-Content -Path $inputFile
# Create hash table to store extracted data
$extracted_data = @{}
# Extract key fields from email
$header_names = @("To","From","Reply-To","Return-Path")
foreach ($header in $header_names) {
    $extracted_data[$header] = $email_content | Select-String -Pattern "^$($header):.+"
}
# Print extracted values
foreach ($key in $extracted_data.Keys) {
    Write-Host $extracted_data[$key]
}
$finish_ts = Get-Date
$runtime = $($finish_ts - $start_ts).TotalSeconds
if ($log) { Write-LogMessage -message $("Script complete in " + $runtime + " seconds.") }