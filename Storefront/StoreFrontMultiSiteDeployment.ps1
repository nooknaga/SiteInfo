param(
    [string]$FIRMID,                
    [string]$Site1SFServer1,
    [string]$Site2SFServer1,
    [string]$Site1CitrixSiteName,
    [string]$Site2CitrixSiteName
)

Import-Module .\Modules\CitrixStoreFrontOperations.psm1
Write-Host $Site1SFServer1
Write-Host $Site2SFServer1
Write-Host $Site1CitrixSiteName
Write-Host $Site2CitrixSiteName
$assignedGroupProd = "$FIRMID-Geneva-Prod-Users"
$assignedGroupStg = "$FIRMID-Geneva-Stg-Users"
$assignedPowerGroupProd = "$FIRMID-Geneva-Prod-PowerUsers"
$assignedPowerGroupStg = "$FIRMID-Geneva-Stg-PowerUsers"
#Importing ActiveDirectory Module
Write-Host "Importing ActiveDirectory Module"
Import-Module ActiveDirectory
#Check for AD Group if already exists then skip the execution
#########################################################################################
$GetADStgGroupDetails=Get-ADGroup -Filter * | Where-Object {$_.name -eq $assignedGroupStg}
if($GetADStgGroupDetails -eq $null)
{
 Write-Host $assignedGroupStg is Not exists
 Exit
 }
#Get SID for Stg Group
$StgGroupSID=$GetADStgGroupDetails.SID.Value
##########################################################################################
$GetADProdGroupDetails=Get-ADGroup -Filter * | Where-Object {$_.name -eq $assignedGroupProd}
if($GetADProdGroupDetails -eq $null)
{
 Write-Host $assignedGroupProd is Not exists
 Exit
 }
#Get SID for Prod Group
$ProdGroupSID=$GetADProdGroupDetails.SID.Value
#########################################################################################
$GetADStgPowerGroupDetails=Get-ADGroup -Filter * | Where-Object {$_.name -eq $assignedPowerGroupStg}
if($GetADStgPowerGroupDetails -eq $null)
{
 Write-Host $assignedPowerGroupStg is Not exists
 Exit
 }
#Get SID for StgPower Group
$StgPowerGroupSID=$GetADStgPowerGroupDetails.SID.Value
#########################################################################################
#Specify the Node Level of XML File
$GetADProdPowerGroupDetails=Get-ADGroup -Filter * | Where-Object {$_.name -eq $assignedPowerGroupProd}
if($GetADProdPowerGroupDetails -eq $null)
{
 Write-Host $assignedPowerGroupProd is Not exists
 Exit
 }
#Get SID for Prod Group
$ProdPowerGroupSID=$GetADProdPowerGroupDetails.SID.Value
#########################################################################################

##################################################################################################
#Creddentails to Invoke-Command
$Username1="hosting\mcalabrese"
$password1=convertto-securestring "34erdfCVBN" -asplaintext -force
$credentials1=New-object -typename System.Management.Automation.PSCredential -argumentlist $Username1,$password1
Write-Host Creating Machine Catlaog for $SiteDetails.Site1SFServer1 for Group 
Invoke-Command -Credential $credentials1 -ComputerName $Site1SFServer1 -ScriptBlock ${function:FirmBasedMapping} -ArgumentList $Site1CitrixSiteName,$Site2CitrixSiteName,$assignedGroupProd,$ProdGroupSID,"Firm_$assignedGroupProd"
Invoke-Command -Credential $credentials1 -ComputerName $Site1SFServer1 -ScriptBlock ${function:FirmBasedMapping} -ArgumentList $Site1CitrixSiteName,$Site2CitrixSiteName,$assignedPowerGroupProd,$ProdPowerGroupSID,"Firm_$assignedPowerGroupProd"
Invoke-Command -Credential $credentials1 -ComputerName $Site1SFServer1 -ScriptBlock ${function:FirmBasedMapping} -ArgumentList $Site1CitrixSiteName,$Site2CitrixSiteName,$assignedGroupStg,$StgGroupSID,"Firm_$assignedGroupStg"
Invoke-Command -Credential $credentials1 -ComputerName $Site1SFServer1 -ScriptBlock ${function:FirmBasedMapping} -ArgumentList $Site1CitrixSiteName,$Site2CitrixSiteName,$assignedPowerGroupStg,$StgPowerGroupSID,"Firm_$assignedPowerGroupStg"
#Write-Host Creating Machine Catlaog for $SiteDetails.Site2SFServer1 for Group $StgCatalogGroup
#Invoke-Command -Credential $credentials1 -ComputerName $Site2SFServer1 -ScriptBlock ${function:FirmBasedMapping} -ArgumentList $Site1CitrixSiteName,$Site2CitrixSiteName,$assignedGroupProd,$ProdGroupSID,"Firm_$assignedGroupProd"
#Invoke-Command -Credential $credentials1 -ComputerName $Site2SFServer1 -ScriptBlock ${function:FirmBasedMapping} -ArgumentList $Site1CitrixSiteName,$Site2CitrixSiteName,$assignedPowerGroupProd,$ProdPowerGroupSID,"Firm_$assignedPowerGroupProd"
#Invoke-Command -Credential $credentials1 -ComputerName $Site2SFServer1 -ScriptBlock ${function:FirmBasedMapping} -ArgumentList $Site1CitrixSiteName,$Site2CitrixSiteName,$assignedGroupStg,$StgGroupSID,"Firm_$assignedGroupStg"
#Invoke-Command -Credential $credentials1 -ComputerName $Site2SFServer1 -ScriptBlock ${function:FirmBasedMapping} -ArgumentList $Site1CitrixSiteName,$Site2CitrixSiteName,$assignedPowerGroupStg,$StgPowerGroupSID,"Firm_$assignedPowerGroupStg"
