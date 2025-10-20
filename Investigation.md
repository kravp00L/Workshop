# Investigation

## Overview of investigation objectives
- Continuing with some of the tasks in the playbook, the shift is now from having established the message as malicious and determining what else may have happened. 
- For the purposes of this workshop, we will stipulate that the message had a link that was clicked and that the account was compromised.  

## Automating the investigative data retrieval
- Building off the foundations of automation from the analysis module, the investigation will leverage PowerShell to retrieve relevant data from the Microsoft environment.

### Unified Audit Log
- The Unified Audit Log (UAL) is a key investigative resource in the Microsoft cloud environment.
- The UAL records all actions taken in the core Microsoft 365 services (Exchange, OneDrive, SharePoint, Teams)
- The UAL is enabled by default for tenants created October 2021 and later
- Tenants created before that time need to have the UAL enabled
- Logs go back a minimum of 180 days and can extend much longer based on your license level

#### Searching the UAL
The PowerShell cmdlet below is used to search the UAL.
```PowerShell
Search-UnifiedAuditLog -StartDate -EndDate -ResultSize 5000 -SessionCommand ReturnNextPreviewPage -UserIds
```