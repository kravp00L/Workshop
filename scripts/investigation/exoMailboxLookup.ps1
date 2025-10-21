Param (
    [String] [Parameter(Mandatory=$true)] $mailbox,
    [bool] [Parameter(Mandatory=$False)] $log = $False,
    [String] [Parameter(Mandatory=$False)] $logfile = "script_log_file.log"
)

# Imports
Import-Module ExchangeOnlineManagement

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
###

# open EXO Management session
Connect-ExchangeOnline -ShowBanner:$false

# Get all mailbox rules
$mbox = Get-Mailbox -Identity $mailbox
Write-LogMessage -message "Mailbox SMTP forwarding settings"
if ($mbox.ForwardingSMTPAddress -or $mbox.DeliverToMailboxAndForward) {
    $mbox | Format-List UserPrincipalName,DeliverToMailboxAndForward,ForwardingSMTPAddress
}
else {
    Write-LogMessage "Mailbox is not configured for SMTP forwarding"
}
Write-LogMessage -message "Mailbox rules"
$rules = Get-InboxRule -Mailbox $mailbox -IncludeHidden
$rules | Format-Table Name,Enabled,Priority,RuleIdentity

do {
    $stop = Read-Host -Prompt "Perform rule detail lookups (Y/N)?"
    if ($stop.ToUpper() -eq "Y") {
        $lookup_rule = $true    
    }
    else {
        break
    }
    $ruleid = Read-Host -Prompt "Enter rule id"
    # Properties: Description, From, ForwardTo
    Get-InboxRule -Mailbox $mailbox -Identity $ruleid | Format-List From,ForwardTo,Description
} while ($lookup_rule)

Disconnect-ExchangeOnline -Confirm:$false

$finish_ts = Get-Date
$runtime = $($finish_ts - $start_ts).TotalSeconds
if ($log) { Write-LogMessage -message $("Script complete in " + $runtime + " seconds.") }