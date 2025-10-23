Param (
    [String] [parameter(Mandatory=$true)] $userId,
    [bool] [Parameter(Mandatory=$False)] $log = $False,
    [String] [Parameter(Mandatory=$False)] $logfile = "script_log_file.log"
)

# Imports
Import-Module ActiveDirectory

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
# Could use any AzureAD, Graph PS cmdlets or API calls to any directory service
# Example below using RSAT PS cmdlets
###

if ($log) { Write-LogMessage -message "Looking up account information for $($userId)" }
try {
    $user_details = Get-ADUser -Properties DisplayName,EmailAddress,Title,Manager $userId
}
catch {
    Write-LogMessage -message "Error trying to retrieve account info for $($userId)"
    Write-LogMessage -message "Error details: $($_.Exception.Message)"
}
$user_details | Select-Object -Property DisplayName,EmailAddress,UserPrincipalName,SAMAccountName,Title | Format-List
$finish_ts = Get-Date
$runtime = $($finish_ts - $start_ts).TotalSeconds
if ($log) { Write-LogMessage -message $("Script complete in " + $runtime + " seconds.") }