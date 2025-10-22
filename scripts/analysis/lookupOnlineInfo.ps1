Param (
    [String] [Parameter(Mandatory=$true, ParameterSetName="ByDomain")] $domain,
    [String] [Parameter(Mandatory=$true, ParameterSetName="ByUrl")] $url,
    [bool] [Parameter(Mandatory=$False)] $log = $False,
    [String] [Parameter(Mandatory=$False)] $logfile = "script_log_file.log"
)

switch ($PSCmdlet.ParameterSetName) {
    'ByDomain' {if ($log) { Write-LogMessage -message "Looking up domain" }}
    'ByUrl' {if ($log) { Write-LogMessage -message "Looking up URL" }}
    default {if ($log) { Write-LogMessage -message "No valid input provided for analysis" }}
}
# Imports

# Variables
$vt_api_key = "463acbaf4fae087e0eac62838edae90b67878eab8a94ff3c0d1c1fe7f36df542"

# Functions
Function Write-LogMessage {
    param(
        [string] $message
    )
    $timestamp = Get-Date -format "yyyy-MM-dd HH:mm:ss.fff"
    Write-Host $timestamp $message
    Write-Output "$timestamp $message" | Out-File $logfile ascii -Append
}

Function Submit-VirusTotalDomainQuery($domain) {
    # API reference: https://docs.virustotal.com/reference/domain-info
    $api_domain_base_url = "https://www.virustotal.com/api/v3/domains/"
    $lookup_url = $api_domain_base_url + $domain
    # Header x-apikey required for authentication to API
    $auth_header = @{"x-apikey" = $vt_api_key; "accept" = "application/json"}
    $domain_result = Invoke-RestMethod -Method GET -Uri $lookup_url -Headers $auth_header
    return $domain_result
}

Function Submit-VirusTotalUrlQuery($url) {
    # API reference: https://docs.virustotal.com/reference/url-info
    $api_url_base_url = "https://www.virustotal.com/api/v3/urls/"
    $lookup_url = $api_url_base_url + $url
    # Header x-apikey required for authentication to API
    $auth_header = @{"x-apikey" = $vt_api_key; "accept" = "application/json"}
    $url_result = Invoke-RestMethod -Method GET -Uri $lookup_url -Headers $auth_header
    return $url_result
}

# Execution starts below
$start_ts = Get-Date
if ($log) { Write-LogMessage -message "Script started" }

###
# New code goes in this section
###
if ($null -eq $url -and $null -eq $domain) {
    if ($log) { Write-LogMessage -message "No input provided for analysis" }
    break
} elseif ($url) {
    if ($log) { Write-LogMessage -message "Performing VT API lookup on URL $url" }
    $lookup_results = Submit-VirusTotalUrlQuery -domain $url
    Write-Host $lookup_results
} elseif ($domain) {
    if ($log) { Write-LogMessage -message "Performing VT API lookup on domain $domain" }
    $lookup_results = Submit-VirusTotalDomainQuery -domain $domain
    Write-Host $lookup_results.data.attributes.categories
    Write-Host $lookup_results.data.attributes.popularity_ranks
}
$finish_ts = Get-Date
$runtime = $($finish_ts - $start_ts).TotalSeconds
if ($log) { Write-LogMessage -message $("Script complete in " + $runtime + " seconds.") }