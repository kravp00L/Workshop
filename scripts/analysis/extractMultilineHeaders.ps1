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
# Read email from file
$email_content = Get-Content -Path $inputFile -Raw
# Define pattern to extract Recevied: headers
$header_pattern =  "(?ms)^Received:.*?(?=^Received|^ARC|Authentication|^Reply\-To|^From|^X\-|\z)"
$dmarc_pattern = "(?ms)^Authentication.*?(?=^Received|^ARC|Authentication|^X\-|\z)"
$spf_pattern = "(?ms)^Received\-SPF:.*?(?=^Received|^ARC|Authentication|^X\-|^This|\z)"
# Use regex engine to find matches
$header_matches = [regex]::Matches($email_content, $header_pattern,[System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
$dmarc_header = [regex]::Match($email_content, $dmarc_pattern,[System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
$spf_header = [regex]::Match($email_content, $spf_pattern,[System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
# Print DMARC header
Write-Host $dmarc_header.Value
# Print SPF header
Write-Host $spf_header.Value
# Print trace headers - reverse order 
for ($i = $header_matches.Count - 1; $i -ge 0; $i--) {
    Write-Host $header_matches[$i]
}

$finish_ts = Get-Date
$runtime = $($finish_ts - $start_ts).TotalSeconds
if ($log) { Write-LogMessage -message $("Script complete in " + $runtime + " seconds.") }