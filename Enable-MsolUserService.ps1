<#
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

[VERSION HISTORY / UPDATES]
 1.0.0 2012???? - RZarka - Created the bare bones.
 1.2.0 20121205 - RZarka - BUGFIX: Issues for users with more than one licence applied.
 2.0.0 20180510 - JBINES - Applied New Services such as teams, simplfied the logic and added logging to Console.

#>

## Functions
# Logging function 
# Author: Aaron Guilmette ; https://www.undocumented-features.com/2018/02/05/yet-another-write-log-function/ 

function Write-Log([string[]]$Message, [string]$LogFile = $Script:LogFile, [switch]$ConsoleOutput, [ValidateSet("SUCCESS", "INFO", "WARN", "ERROR", "DEBUG")][string]$LogLevel)
{
	$Message = $Message + $Input
	If (!$LogLevel) { $LogLevel = "INFO" }
	switch ($LogLevel)
	{
		SUCCESS { $Color = "Green" }
		INFO { $Color = "White" }
		WARN { $Color = "Yellow" }
		ERROR { $Color = "Red" }
		DEBUG { $Color = "Gray" }
	}
	if ($Message -ne $null -and $Message.Length -gt 0)
	{
		$TimeStamp = [System.DateTime]::Now.ToString("yyyy-MM-dd HH:mm:ss")
		if ($LogFile -ne $null -and $LogFile -ne [System.String]::Empty)
		{
			Out-File -Append -FilePath $LogFile -InputObject "[$TimeStamp] [$LogLevel] $Message"
		}
		if ($ConsoleOutput -eq $true)
		{
			Write-Host "[$TimeStamp] [$LogLevel] :: $Message" -ForegroundColor $Color
		}
	}
}


#Set Tenant AccountSkuId User Selection

    $AccountSkuId = "ContosoLab:ENTERPRISEPACK" #E3
    #$AccountSkuId = "ContosoLab:ENTERPRISEPREMIUM" #MS 365 E3

    #Use for CSV Import for selected user processing
    #$LicensedUsers = (Import-Csv "C:\temp\userlist.csv" | Select UserPrincipalName)

    #Bulk Apply Where (IsLicensed -eq $true) -and ($AccountSkuId -eq Above)
    $LicensedUsers = (Get-MsolUser -All | Where { $_.IsLicensed -eq $true } | Select UserPrincipalName)

ForEach ($User in $LicensedUsers) {
    $Upn = $User.UserPrincipalName
    $AssignedLicenses = (Get-MsolUser -UserPrincipalName $Upn).Licenses
    
    Write-Log -Message "User: $($Upn)" -LogLevel INFO -ConsoleOutput

    #Set Servcie Variables - Change to Enabled for default changes
    $BPOS_S_TODO_2 = "Disabled"; 

    $FORMS_PLAN_E3 = "Enabled";     #$FORMS_PLAN_E3 = "Disabled"; 

    $STREAM_O365_E3 = "Disabled"; 
    $Deskless = "Disabled"; 
    $FLOW_O365_P2 = "Disabled"; 
    $POWERAPPS_O365_P2 = "Disabled"

    $TEAMS1 = "Enabled";     #$TEAMS1 = "Disabled"; 
    $PROJECTWORKMANAGEMENT = "Enabled";     #$PROJECTWORKMANAGEMENT = "Disabled"; 

    $SWAY = "Disabled"; 
    $INTUNE_O365 = "Disabled"; 
    $YAMMER_ENTERPRISE = "Disabled"; 
    $RMS_S_ENTERPRISE = "Disabled"
    $OFFICESUBSCRIPTION = "Disabled"
    $MCOSTANDARD = "Disabled"; 
    $SHAREPOINTWAC = "Disabled"; 
    $SHAREPOINTENTERPRISE = "Disabled"; 
    $EXCHANGE_S_ENTERPRISE = "Disabled"; 
    $EXCHANGE_S_FOUNDATION = "Disabled"; 
    $ADALLOM_S_DISCOVERY = "Disabled"
    $RMS_S_PREMIUM = "Disabled"; 
    $INTUNE_A = "Disabled"; 
    $RMS_S_ENTERPRISE = "Disabled"; 
    $AAD_PREMIUM = "Disabled"; 
    $MFA_PREMIUM = "Disabled"; 

    #Microsoft 365 E5 
    $PAM_ENTERPRISE = "Disabled"; 
    $BPOS_S_TODO_3 = "Disabled"; 
    $FORMS_PLAN_E5 = "Disabled"; 
    $STREAM_O365_E5 = "Disabled"; 
    $THREAT_INTELLIGENCE = "Disabled"; 
    $FLOW_O365_P3 = "Disabled"; 
    $POWERAPPS_O365_P3 = "Disabled"; 
    $ADALLOM_S_O365 = "Disabled"; 
    $EQUIVIO_ANALYTICS = "Disabled"; 
    $LOCKBOX_ENTERPRISE = "Disabled"; 
    $EXCHANGE_ANALYTICS = "Disabled"; 
    $ATP_ENTERPRISE = "Disabled"; 
    $MCOEV = "Disabled"; 
    $MCOMEETADV = "Disabled"; 
    $BI_AZURE_P2 = "Disabled"; 

    #Create DisabledOptions Array
    $DisabledOptions = @()

    ForEach ($License in $AssignedLicenses) {
        If ($License.AccountSkuId -eq "$AccountSkuId") { 
                        
            Foreach($ServiceStatus in $License.ServiceStatus){  
                             
                Switch ($ServiceStatus.ServicePlan.ServiceName) {

                    "BPOS_S_TODO_2" { If($ServiceStatus.ProvisioningStatus -ne "Disabled") { $BPOS_S_TODO_2 = "Enabled"} Else {If($BPOS_S_TODO_2 -eq "Disabled"){$DisabledOptions += "BPOS_S_TODO_2"}}}
                    "FORMS_PLAN_E3" { If($ServiceStatus.ProvisioningStatus -ne "Disabled") { $FORMS_PLAN_E3 = "Enabled" } Else {If($FORMS_PLAN_E3 -eq "Disabled"){$DisabledOptions += "FORMS_PLAN_E3"}}}
                    "STREAM_O365_E3"{ IF($ServiceStatus.ProvisioningStatus -ne "Disabled") { $STREAM_O365_E3 = "Enabled" } Else {If($STREAM_O365_E3 -eq "Disabled"){$DisabledOptions += "STREAM_O365_E3"}}}
                    "Deskless" { IF($ServiceStatus.ProvisioningStatus -ne "Disabled") { $Deskless = "Enabled" } Else {If($Deskless -eq "Disabled"){$DisabledOptions += "Deskless"}}}
                    "FLOW_O365_P2" { IF($ServiceStatus.ProvisioningStatus -ne "Disabled") { $FLOW_O365_P2 = "Enabled" } Else {If($FLOW_O365_P2 -eq "Disabled"){$DisabledOptions += "FLOW_O365_P2"}}}
                    "POWERAPPS_O365_P2" { IF($ServiceStatus.ProvisioningStatus -ne "Disabled") { $POWERAPPS_O365_P2 = "Enabled" } Else {If($POWERAPPS_O365_P2 -eq "Disabled"){$DisabledOptions += "POWERAPPS_O365_P2"}}}
                    "TEAMS1" { IF($ServiceStatus.ProvisioningStatus -ne "Disabled") { $TEAMS1 = "Enabled" } Else {If($TEAMS1 -eq "Disabled"){$DisabledOptions += "TEAMS1"}}}
                    "PROJECTWORKMANAGEMENT" { IF($ServiceStatus.ProvisioningStatus -ne "Disabled") { $PROJECTWORKMANAGEMENT = "Enabled" } Else {If($PROJECTWORKMANAGEMENT -eq "Disabled"){$DisabledOptions += "PROJECTWORKMANAGEMENT"}}}
                    "SWAY" { IF($ServiceStatus.ProvisioningStatus -ne "Disabled") { $SWAY = "Enabled" } Else {If($SWAY -eq "Disabled"){$DisabledOptions += "SWAY"}}}
                    "INTUNE_O365" { IF($ServiceStatus.ProvisioningStatus -ne "Disabled") { $INTUNE_O365 = "Enabled" }Else {If($INTUNE_O365 -eq "Disabled"){$DisabledOptions += "INTUNE_O365"}}}
                    "YAMMER_ENTERPRISE" { IF ($ServiceStatus.ProvisioningStatus -ne "Disabled") { $YAMMER_ENTERPRISE = "Enabled" }Else {If($YAMMER_ENTERPRISE -eq "Disabled"){$DisabledOptions += "YAMMER_ENTERPRISE"}}}
                    "RMS_S_ENTERPRISE" { IF($ServiceStatus.ProvisioningStatus -ne "Disabled") { $RMS_S_ENTERPRISE = "Enabled" }Else {If($RMS_S_ENTERPRISE -eq "Disabled"){$DisabledOptions += "RMS_S_ENTERPRISE"}}}
                    "OFFICESUBSCRIPTION" { IF($ServiceStatus.ProvisioningStatus -ne "Disabled") { $OFFICESUBSCRIPTION = "Enabled" }Else {If($OFFICESUBSCRIPTION -eq "Disabled"){$DisabledOptions += "OFFICESUBSCRIPTION"}}}
                    "MCOSTANDARD" { If($ServiceStatus.ProvisioningStatus -ne "Disabled") { $MCOSTANDARD = "Enabled"}Else {If($MCOSTANDARD -eq "Disabled"){$DisabledOptions += "MCOSTANDARD"}}}
                    "SHAREPOINTWAC" { If($ServiceStatus.ProvisioningStatus -ne "Disabled") { $SHAREPOINTWAC = "Enabled" }Else {If($SHAREPOINTWAC -eq "Disabled"){$DisabledOptions += "SHAREPOINTWAC"}}}
                    "SHAREPOINTENTERPRISE"{ IF($ServiceStatus.ProvisioningStatus -ne "Disabled") { $SHAREPOINTENTERPRISE = "Enabled" }Else {If($SHAREPOINTENTERPRISE -eq "Disabled"){$DisabledOptions += "SHAREPOINTENTERPRISE"}}}
                    "EXCHANGE_S_ENTERPRISE" { IF($ServiceStatus.ProvisioningStatus -ne "Disabled") { $EXCHANGE_S_ENTERPRISE = "Enabled" }Else {If($EXCHANGE_S_ENTERPRISE -eq "Disabled"){$DisabledOptions += "EXCHANGE_S_ENTERPRISE"}}}
                    "EXCHANGE_S_FOUNDATION" { IF($ServiceStatus.ProvisioningStatus -ne "Disabled") { $EXCHANGE_S_FOUNDATION = "Enabled" }Else {If($EXCHANGE_S_FOUNDATION -eq "Disabled"){$DisabledOptions += "EXCHANGE_S_FOUNDATION"}}}
                    "ADALLOM_S_DISCOVERY" { IF($ServiceStatus.ProvisioningStatus -ne "Disabled") { $ADALLOM_S_DISCOVERY = "Enabled" }Else {If($ADALLOM_S_DISCOVERY -eq "Disabled"){$DisabledOptions += "ADALLOM_S_DISCOVERY"}}}
                    "RMS_S_PREMIUM" { IF($ServiceStatus.ProvisioningStatus -ne "Disabled") { $RMS_S_PREMIUM = "Enabled" }Else {If($RMS_S_PREMIUM -eq "Disabled"){$DisabledOptions += "RMS_S_PREMIUM"}}}
                    "INTUNE_A" { IF($ServiceStatus.ProvisioningStatus -ne "Disabled") { $INTUNE_A = "Enabled" }Else {If($INTUNE_A -eq "Disabled"){$DisabledOptions += "INTUNE_A"}}}
                    "RMS_S_ENTERPRISE" { IF($ServiceStatus.ProvisioningStatus -ne "Disabled") { $RMS_S_ENTERPRISE = "Enabled" }Else {If($RMS_S_ENTERPRISE -eq "Disabled"){$DisabledOptions += "RMS_S_ENTERPRISE"}}}
                    "AAD_PREMIUM" { IF($ServiceStatus.ProvisioningStatus -ne "Disabled") { $AAD_PREMIUM = "Enabled" }Else {If($AAD_PREMIUM -eq "Disabled"){$DisabledOptions += "AAD_PREMIUM"}}}
                    "MFA_PREMIUM" { IF ($ServiceStatus.ProvisioningStatus -ne "Disabled") { $MFA_PREMIUM = "Enabled" }Else {If($MFA_PREMIUM -eq "Disabled"){$DisabledOptions += "MFA_PREMIUM"}}}

                    #Microsoft 365 E5 

                    "PAM_ENTERPRISE" { IF ($ServiceStatus.ProvisioningStatus -ne "Disabled") { $PAM_ENTERPRISE = "Enabled" }Else {If($PAM_ENTERPRISE -eq "Disabled"){$DisabledOptions += "PAM_ENTERPRISE"}}}
                    "BPOS_S_TODO_3" { IF ($ServiceStatus.ProvisioningStatus -ne "Disabled") { $BPOS_S_TODO_3 = "Enabled" }Else {If($BPOS_S_TODO_3 -eq "Disabled"){$DisabledOptions += "BPOS_S_TODO_3"}}}
                    "FORMS_PLAN_E5" { IF ($ServiceStatus.ProvisioningStatus -ne "Disabled") { $FORMS_PLAN_E5 = "Enabled" }Else {If($FORMS_PLAN_E5 -eq "Disabled"){$DisabledOptions += "FORMS_PLAN_E5"}}}
                    "STREAM_O365_E5" { IF ($ServiceStatus.ProvisioningStatus -ne "Disabled") { $STREAM_O365_E5 = "Enabled" }Else {If($STREAM_O365_E5 -eq "Disabled"){$DisabledOptions += "STREAM_O365_E5"}}}
                    "THREAT_INTELLIGENCE" { IF ($ServiceStatus.ProvisioningStatus -ne "Disabled") { $THREAT_INTELLIGENCE = "Enabled" }Else {If($THREAT_INTELLIGENCE -eq "Disabled"){$DisabledOptions += "THREAT_INTELLIGENCE"}}}
                    "FLOW_O365_P3" { IF ($ServiceStatus.ProvisioningStatus -ne "Disabled") { $FLOW_O365_P3 = "Enabled" }Else {If($FLOW_O365_P3 -eq "Disabled"){$DisabledOptions += "FLOW_O365_P3"}}}
                    "POWERAPPS_O365_P3" { IF ($ServiceStatus.ProvisioningStatus -ne "Disabled") { $POWERAPPS_O365_P3 = "Enabled" }Else {If($POWERAPPS_O365_P3 -eq "Disabled"){$DisabledOptions += "POWERAPPS_O365_P3"}}}
                    "ADALLOM_S_O365" { IF ($ServiceStatus.ProvisioningStatus -ne "Disabled") { $ADALLOM_S_O365 = "Enabled" }Else {If($ADALLOM_S_O365 -eq "Disabled"){$DisabledOptions += "ADALLOM_S_O365"}}}
                    "EQUIVIO_ANALYTICS" { IF ($ServiceStatus.ProvisioningStatus -ne "Disabled") { $EQUIVIO_ANALYTICS = "Enabled" }Else {If($EQUIVIO_ANALYTICS -eq "Disabled"){$DisabledOptions += "EQUIVIO_ANALYTICS"}}}
                    "LOCKBOX_ENTERPRISE" { IF ($ServiceStatus.ProvisioningStatus -ne "Disabled") { $LOCKBOX_ENTERPRISE = "Enabled" }Else {If($LOCKBOX_ENTERPRISE -eq "Disabled"){$DisabledOptions += "LOCKBOX_ENTERPRISE"}}}
                    "EXCHANGE_ANALYTICS" { IF ($ServiceStatus.ProvisioningStatus -ne "Disabled") { $EXCHANGE_ANALYTICS = "Enabled" }Else {If($EXCHANGE_ANALYTICS -eq "Disabled"){$DisabledOptions += "EXCHANGE_ANALYTICS"}}}
                    "ATP_ENTERPRISE" { IF ($ServiceStatus.ProvisioningStatus -ne "Disabled") { $ATP_ENTERPRISE = "Enabled" }Else {If($ATP_ENTERPRISE -eq "Disabled"){$DisabledOptions += "ATP_ENTERPRISE"}}}
                    "MCOEV" { IF ($ServiceStatus.ProvisioningStatus -ne "Disabled") { $MCOEV = "Enabled" }Else {If($MCOEV -eq "Disabled"){$DisabledOptions += "MCOEV"}}}
                    "MCOMEETADV" { IF ($ServiceStatus.ProvisioningStatus -ne "Disabled") { $MCOMEETADV = "Enabled" }Else {If($MCOMEETADV -eq "Disabled"){$DisabledOptions += "MCOMEETADV"}}}
                    "BI_AZURE_P2" { IF ($ServiceStatus.ProvisioningStatus -ne "Disabled") { $BI_AZURE_P2 = "Enabled" }Else {If($BI_AZURE_P2 -eq "Disabled"){$DisabledOptions += "BI_AZURE_P2"}}}

                    Default {Write-log -Message "Type of Licence: $($ServiceStatus.ServicePlan.ServiceName) Not found and will be ENABLED by default" -ConsoleOutput -LogLevel WARN }
                }
            }

            $LicenseOptions = New-MsolLicenseOptions -AccountSkuId $AccountSkuId -DisabledPlans $DisabledOptions
            Set-MsolUserLicense -User $Upn -LicenseOptions $LicenseOptions
            
            If($?){Write-Log -Message "CMDlet:Set-MsolUserLicence;UPN:$Upn;AccountSkuId:$AccountSkuId;DisabledPlans:$DisabledOptions" -LogLevel Success -ConsoleOutput}

        }
    }
}
