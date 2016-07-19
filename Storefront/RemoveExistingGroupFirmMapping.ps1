param(
    [string]$FIRMID="930585",                
    [string]$ENVIRONMENT,
    [string]$COMPANYNAME="Geneva",
    [string]$SITE="US",
    [string]$assignedGroup="930585-Geneva-Prod-PowerUsers"
)
Import-Module C:\CitrixScripts\Modules\CitriSiteDetails_Module.psm1
Import-Module C:\CitrixScripts\Modules\CitrixStoreFrontOperations.psm1
$SiteDetails=GetSiteDetails $SITE
Write-Host $SiteDetails.Site1SFServer1
Write-Host $SiteDetails.Site2SFServer1
Write-Host $SiteDetails.Site1CitrixSiteName
Write-Host $SiteDetails.Site2CitrixSiteName
##################################################################################################
#Creddentails to Invoke-Command
$Username1="hosting\mcalabrese"
$password1=convertto-securestring "34erdfCVBN" -asplaintext -force
$credentials1=New-object -typename System.Management.Automation.PSCredential -argumentlist $Username1,$password1
Write-Host Creating Machine Catlaog for $SiteDetails.Site1SFServer1 for Group 
Invoke-Command -Credential $credentials1 -ComputerName $SiteDetails.Site1SFServer1 -ScriptBlock ${function:RemoveGroupFirmMapping} -ArgumentList "Firm_$assignedGroup"
#Write-Host Creating Machine Catlaog for $SiteDetails.Site2SFServer1 for Group 
#Invoke-Command -Credential $credentials1 -ComputerName $SiteDetails.Site2SFServer1 -ScriptBlock ${function:FirmBasedMapping} -ArgumentList $SiteDetails.Site1CitrixSiteName,$SiteDetails.Site2CitrixSiteName,$assignedGroup,$GroupSID,"Firm_$assignedGroup"
