Param (
    [String] [parameter(Mandatory=$true)] $inputFile,
    [String] [parameter(Mandatory=$true)] $importColumns,
    [String] [Parameter(Mandatory=$False)] $outfile = ".\data\account_review.xlsx",
    [bool] [Parameter(Mandatory=$False)] $log = $False,
    [String] [Parameter(Mandatory=$False)] $logfile = "script_log_file.log"
)

# Imports
Import-Module ActiveDirectory
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

Function Write-AnalysisOutput($data_hashtable_array) {
    Write-LogMessage -message "Exporting results"    
    $output_array = @()
    # Array of hashtables (user data) is the input, array of custom objects is output
    foreach ($entry in $data_hashtable_array) {
        $output_object = New-Object psobject -Property $entry
        $output_array += $output_object
    }
    # writes out an Excel file
    $output_array | Select-Object 'username','name','email','active','title','supervisor' `
    | Export-Excel -Path $outfile -AutoFilter
}
# Execution starts below
$start_ts = Get-Date
if ($log) { Write-LogMessage -message "Script started" }

###
# New code goes in this section
# Could use any AzureAD PS cmdlets or API calls to any directory service
# Example below using RSAT PS cmdlets
###

# Importing the list of user accounts
$user_list = Import-Excel -Path $inputFile -ImportColumns @($($importColumns)) -NoHeader -StartRow 2

$lookup_results = @()
foreach ($user_record in $user_list) {
    $user_identifier = $user_record.P1    
    $acctname = $user_identifier.Split('@')[0]
    Write-LogMessage -message "Looking up account information for $($acctname)"
    try {
        $user_details = Get-ADUser -Properties DisplayName,EmailAddress,Title,Manager $acctname
    }
    catch {
        Write-LogMessage -message "Error trying to retrieve account info for $($acctname)"
        Write-LogMessage -message "Error details: $($_.Exception.Message)"
    }
    if ($user_details.Manager) {
        try { 
            $user_manager = Get-ADUser -Properties DisplayName $user_details.Manager
        }
        catch {
            Write-LogMessage -message "Error trying to retrieve manager info for $($acctname)"
            Write-LogMessage -message "Error details: $($_.Exception.Message)"
        }
    }
    if ($user_details) {
        $current_user = @{
            username = $user_details.SAMAccountName
            name = $user_details.DisplayName;
            email = $user_details.EmailAddress;
            active = $user_details.Enabled;
            title = $user_details.Title;
            supervisor = $user_manager.DisplayName;
        }
    }
    else {
        $current_user = @{
            username = $acctname
            name = $null
            email = $null
            active = $null
            title = $null
            supervisor = $null
        }
    }
    $lookup_results += $current_user
    $user_details = $null
    $user_manager = $null
    $current_user = $null
}
# Write analysis output results
Write-AnalysisOutput($lookup_results)

$finish_ts = Get-Date
$runtime = $($finish_ts - $start_ts).TotalSeconds
if ($log) { Write-LogMessage -message $("Script complete in " + $runtime + " seconds.") }