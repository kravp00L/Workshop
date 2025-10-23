Param (
    [String] [parameter(Mandatory=$true)] $inputFile,
    [String] [parameter(Mandatory=$true)] $importColumns,
    [String] [Parameter(Mandatory=$False)] $outfile = ".\data\account_review.xlsx",
    [bool] [Parameter(Mandatory=$False)] $log = $False,
    [String] [Parameter(Mandatory=$False)] $logfile = "script_log_file.log"
)

# Imports
Import-Module AzureAD
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
    $output_array | Select-Object 'username','name','email','active' | Export-Excel -Path $outfile -AutoFilter
}

# Execution starts below
$start_ts = Get-Date
if ($log) { Write-LogMessage -message "Script started" }

###
# New code goes in this section
# Could use any AzureAD PS cmdlets or API calls to any directory service
# Example below using Graph API cmdlets
###

# Importing the list of user accounts
$user_list = Import-Excel -Path $inputFile -ImportColumns @($($importColumns)) -NoHeader -StartRow 2

Connect-Graph -Scopes "User.Read.All"
$lookup_results = @()
foreach ($user_record in $user_list) {
    $user_email = $user_record.P1    
    if ($log) { Write-LogMessage -message "Looking up account information for $($user_email)" }
    try {
        $user_details = Get-AzureADUser -ObjectId $user_email
    }
    catch {
        if ($log) { Write-LogMessage -message "Error trying to retrieve account info for $($user_email)" }
        Write-LogMessage -message "Error details: $($_.Exception.Message)"
    }
    if ($user_details) {
        $current_user = @{
            username = $user_details.UserPrincipalName
            name = $user_details.DisplayName;
            email = $user_details.Mail;
            active = $user_details.AccounEnabled;
        }
    }
    else {
        $current_user = @{
            username = $user_email
            name = $null
            email = $null
            active = $null
        }
    }
    $lookup_results += $current_user
    $user_details = $null
    $current_user = $null
}
# Write analysis output results
Write-AnalysisOutput($lookup_results)
Disconnect-AzureAD
$finish_ts = Get-Date
$runtime = $($finish_ts - $start_ts).TotalSeconds
if ($log) { Write-LogMessage -message $("Script complete in " + $runtime + " seconds.") }