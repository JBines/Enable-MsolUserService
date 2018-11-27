# Enable-MsolUserService
.SYNOPSIS
This script will run a series of cmdlets / functions to allow you to enable selected services without overwriting or changing any existing services that are either enabled or disabled. 

.DESCRIPTION
SCENARIO: User accounts each have an inconsistent mix of service options enabled; some have SharePoint enabled, some have S4B enabled, and not all have Exchange.  How do you assign the Office subscription (for example) to all accounts?  You can’t blindly enable all remaining options, as this would provide access to services which may not be desired.  Removing the license and re-applying it also proves difficult. The solution is to query each user accounts to determine which service options are currently active or inactive, add the service you would like to enable, and assign the results.  

.LINK
Bulk Enable Office 365 License Options -  https://blogs.technet.microsoft.com/zarkatech/2012/12/05/bulk-enable-office-365-license-options/

.NOTES
Run in MSOL remote PowerShell session. Concept applies to E3 (ENTERPRISEPACK) license, but is easily adapted. Please be aware that the if a service can not be found in the list it will be set to to enabled by default. 

[AUTHOR]
 Roman Zarka, Microsoft Services

 https://blogs.technet.microsoft.com/zarkatech/
  
[CONTRIBUTORS]
 Joshua Bines, Consultant

Find me on:
* Web:	    https://theinformationstore.com.au
* LinkedIn:	https://www.linkedin.com/in/joshua-bines-4451534
* Github:	https://github.com/jbines 


#Stuff you need to change!

The Script as created for E3 as above but can be ammended for any Sku just make sure all the services are listed in the switch function. 
```
$AccountSkuId = "TENANTID:ENTERPRISEPACK"
```

Import users from a CSV or apply in bulk across your user set. 
```
$LicensedUsers = (Import-Csv "C:\temp\userlist.csv" | Select UserPrincipalName)
  
$LicensedUsers = (Get-MsolUser -All | Where { $_.IsLicensed -eq $true } | Select UserPrincipalName)
```

All services are set to disable. To enabled a services change the value from "Disabled" to "Enabled".
```
$FORMS_PLAN_E3 = "Enabled";  
```
