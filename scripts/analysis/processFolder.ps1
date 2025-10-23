Param (
    [String] [Parameter(Mandatory=$true)] $inputFolder,
    [bool] [Parameter(Mandatory=$False)] $log = $False,
    [String] [Parameter(Mandatory=$False)] $outfile = ".\email_analysis.xlsx",
    [String] [Parameter(Mandatory=$False)] $logfile = "script_log_file.log"
)

# Imports
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

Function Write-AnalysisOutput($extractedDataArray) {
    if ($log) { Write-LogMessage -message "Exporting results" }
    $output_array = @()
    foreach ($entry in $extractedDataArray) {
        $output_object = New-Object psobject -Property $entry
        $output_array += $output_object
    }
    # writes out Excel file
    $output_array | Select-Object 'Filename','To','From','Reply-To','Return-Path' `
    | Export-Excel -Path $outfile -AutoFilter
    return
}

# Execution starts below
$start_ts = Get-Date
if ($log) { Write-LogMessage -message "Script started" }
###
# New code goes in this section
###
$filenames = Get-ChildItem -Path $inputFolder -File
$analyzed_messages = @()
foreach ($file in $filenames) {
    $email_content = Get-Content -Path $($inputFolder + "\" + $file.Name)
    # pass the content for processing
    $extracted_data = @{}
    # Extract key fields from email
    $header_names = @("To","From","Reply-To","Return-Path")
    foreach ($header in $header_names) {
        # Naive match
        $extracted_data[$header] = $email_content | Select-String -Pattern "^$($header):.+"
        <#
        $matched_content = $email_content | Select-String -Pattern "^$($header):.+"
        # Match inclues the header name, so need to remove that and only store the data
        if ($matched_content -and $matched_content.Count -eq 1) {
            $extracted_data[$header] = ($matched_content -split ":")[1].Trim()
        } elseif ($matched_content -and $matched_content.Count -gt 1) {
            $extracted_data[$header] = ($matched_content[0] -split ":")[1].Trim()
        }
         else {
            $extracted_data[$header] = $matched_content
        }
        #>
        
    }
    $extracted_data["Filename"] = $file.Name
    $analyzed_messages += $extracted_data
}
Write-AnalysisOutput($analyzed_messages)
$finish_ts = Get-Date
$runtime = $($finish_ts - $start_ts).TotalSeconds
if ($log) { Write-LogMessage -message $("Script complete in " + $runtime + " seconds.") }