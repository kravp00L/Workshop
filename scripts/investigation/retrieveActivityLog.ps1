Param (
    [String] [Parameter(Mandatory=$true)] $startDate,
    [String] [Parameter(Mandatory=$true)] $endDate,
    [String] [Parameter(Mandatory=$true)] $userId,
    [String] [Parameter(Mandatory=$False)] $outfile = ".\account_activity.xlsx",
    [bool] [Parameter(Mandatory=$False)] $log = $False,
    [String] [Parameter(Mandatory=$False)] $logfile = "script_log_file.log"
)

# Imports
Import-Module ExchangeOnlineManagement
Import-Module ImportExcel

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

Function Write-AnalysisOutput($ps_object_array) {
    if ($log) { Write-LogMessage -message "Exporting results" }
    # Array of PS custom objects is ready to export
    $ps_object_array | Select-Object -Unique -Property CreationTime,UserId,ClientIP,Operation,RuleDetails `
    | Export-Excel -Path $outfile -AutoFilter
}
# Execution starts below
$start_ts = Get-Date
if ($log) { Write-LogMessage -message "Script started" }
###
# New code goes in this section
###
Connect-ExchangeOnline -ShowBanner:$false | Out-Null
$activity_results = Search-UnifiedAuditLog -StartDate $startDate -EndDate $endDate -Operations "New-InboxRule","Set-InboxRule","Remove-InboxRule" -UserIds $userId
# Convert from JSON to PS object
$working_data = $activity_results.AuditData | ConvertFrom-Json
foreach ($record in $working_data) {
    $rule_array = @()
    foreach ($rule_element in $record.Parameters) {
        $rule_array += "$($rule_element.Name): $($rule_element.Value)"
    }
    $rule_info = $rule_array -join "; "
    $record | Add-Member -Force -MemberType NoteProperty -Name "RuleDetails" -Value $rule_info 
}
# Write analysis output results
Write-AnalysisOutput($working_data)
Disconnect-ExchangeOnline -Confirm:$False
$finish_ts = Get-Date
$runtime = $($finish_ts - $start_ts).TotalSeconds
if ($log) { Write-LogMessage -message $("Script complete in " + $runtime + " seconds.") }