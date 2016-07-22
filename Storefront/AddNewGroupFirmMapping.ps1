param(
    [string]$FIRMID="930585",                
    [string]$ENVIRONMENT,
    [string]$COMPANYNAME="Geneva",
    [string]$SITE="US",
    [string]$assignedGroup="930585-Geneva-Prod-PowerUsers",
    [string]$SSUSERNAME,
    [string]$SSPASSWORD
)
Import-Module "$currentPath\Modules\sspslib.psm1"
Import-Module "$currentPath\Modules\CitrixStoreFrontOperations.psm1"
Write-Host $Site1SFServer1
Write-Host $Site2SFServer1
Write-Host $Site1CitrixSiteName
Write-Host $Site2CitrixSiteName
#########################################################################################
#Specify the Group SID
$GetADGroupDetails=Get-ADGroup -Filter * | Where-Object {$_.name -eq $assignedGroup}
if($GetADGroupDetails -eq $null)
{
 Write-Host $assignedGroup is Not exists
 Exit
 }
#Get SID for Prod Group
$GroupSID=$GetADGroupDetails.SID.Value
#########################################################################################
#Get Secret Server for Invoke-Command
#SS paramter information
$domain = 'advent.com'
$url = 'https://vmsfclandestine.advent.com/webservices/sswebservice.asmx'
$connection = connectss $url $domain $SSUSERNAME $SSPASSWORD
$adminpass = getsspassword $connection.tokenid $connection.proxyid "hosting\mcalabrese"
##################################################################################################

##################################################################################################
#Creddentails to Invoke-Command
$Username1="hosting\mcalabrese"
$password1=convertto-securestring $adminpass -asplaintext -force
$credentials1=New-object -typename System.Management.Automation.PSCredential -argumentlist $Username1,$password1
Write-Host Creating Machine Catlaog for $Site1SFServer1 for Group 
Invoke-Command -Credential $credentials1 -ComputerName $Site1SFServer1 -ScriptBlock ${function:FirmBasedMapping} -ArgumentList $Site1CitrixSiteName,$Site2CitrixSiteName,$assignedGroup,$GroupSID,"Firm_$assignedGroup"
#Write-Host Creating Machine Catlaog for $Site2SFServer1 for Group 
#Invoke-Command -Credential $credentials1 -ComputerName $Site2SFServer1 -ScriptBlock ${function:FirmBasedMapping} -ArgumentList $Site1CitrixSiteName,$Site2CitrixSiteName,$assignedGroup,$GroupSID,"Firm_$assignedGroup"
