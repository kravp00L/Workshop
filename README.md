# Hack and Defend Workshop October 2025

## Overview
The workshop covers investigation and response tasks based loosely on the [Microsoft Phishing investigation playbook](https://learn.microsoft.com/en-us/security/operations/incident-response-playbook-phishing)

### Samples folder
Artifacts to be examined

### Scripts folder
The scripts and code that take the artifact analysis from manual to automated

### Preparation
The scripts are written in PowerShell. For a Windows system, nothing will need to be done other
than to install several PowerShell modules. For non-Windows systems, you will need to install
PowerShell core and then install the required modules.

#### PowerShell installation for Linux / macOS
- Linux: https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-linux?view=powershell-7.5
- macOS: https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-macos?view=powershell-7.5

#### Module for Exchange Online
```PowerShell
Install-Module ExchangeOnlineManagement -Scope CurrentUser -RequiredVersion 3.9.0 
```
**References**  
https://www.powershellgallery.com/packages/ExchangeOnlineManagement/  
https://learn.microsoft.com/en-us/powershell/exchange/exchange-online-powershell?view=exchange-ps  
Cmdlet permissions  
https://learn.microsoft.com/en-us/powershell/exchange/find-exchange-cmdlet-permissions?view=exchange-ps

#### Module for import and export in Excel format
```PowerShell
Install-Module ImportExcel -Scope CurrentUser
```

#### Microsoft Graph
```PowerShell
Install-Module Microsoft.Graph -Scope CurrentUser -Repository PSGallery -Force
```
**References**  
https://learn.microsoft.com/en-us/powershell/microsoftgraph/installation?view=graph-powershell-1.0  
https://learn.microsoft.com/en-us/powershell/microsoftgraph/find-mg-graph-command?view=graph-powershell-1.0