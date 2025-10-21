Param (
    [String] [Parameter(Mandatory=$true)] $userId,
    [bool] [Parameter(Mandatory=$False)] $log = $False,
    [String] [Parameter(Mandatory=$False)] $logfile = "script_log_file.log"
)

# Imports
Import-Module Microsoft.Graph.Users.Actions

# Variables
$tenant_id = "" # add your tenant id
$app_id = "" # add your app id
$scopes = "User.ReadWrite.All,Directory.ReadWrite.All" # Graph API scopes

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
###

# open Graph API session
Connect-MgGraph -TenantId $tenant_id -ClientId $app_id -Scopes $scopes

if ($log) {Write-LogMessage -message "Revoking all sign-in sessions for $userId"}
# A UPN can also be used as -UserId.
Revoke-MgUserSignInSession -UserId $userId

Disconnect-MgGraph | Out-Null

$finish_ts = Get-Date
$runtime = $($finish_ts - $start_ts).TotalSeconds
if ($log) { Write-LogMessage -message $("Script complete in " + $runtime + " seconds.") }