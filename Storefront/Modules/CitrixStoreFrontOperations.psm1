function FirmBasedMapping($PrimarySiteName,$SecondarySiteName,$GroupName,$GroupSID,$FirmMappingName)
{
#Powershell script to add group to store front HAA
#Path to StoreFront1 Server
#Write-Host "The StoreFront Server is" $StoreFrontServer
Write-Host $PrimarySiteName
Write-Host $SecondarySiteName
Write-Host $GroupName
Write-Host $GroupSID
$XMLFilePath = "C:\inetpub\wwwroot\Citrix\Geneva\web.config"
$SourceName = "userFarmMapping"
$DestinationName = "userFarmMapping"
[xml]$UserFarmMapping = Get-Content $XMLFilePath
$ParentNode = $UserFarmMapping.configuration.'citrix.deliveryservices'.resourcesCommon.resourcesWingConfigurations.resourcesWingConfiguration.userFarmMappings
$CheckFirmID=$ParentNode.userFarmMapping.name | Where-Object {$_ -eq $FirmMappingName}
Write-Host $ParentNode
#Check for Firm is already Exist or not
if($CheckFirmID -ne $null)
{
 Write-Host "The Firm is already exists"
Exit 
} 
[xml]$CloneNode = '<userFarmMapping name="Firm_0005"><groups><group name="0005-Stg-Users" sid="S-1-5-21-4224367106-2064298830-2600144919-1125" /></groups><equivalentFarmSets><equivalentFarmSet name="FirmSet0005" loadBalanceMode="Failover" aggregationGroup="AggregationGroup1"><primaryFarmRefs><farm name="UKCitrixSite" /><farm name="USCitrixSite" /></primaryFarmRefs><backupFarmRefs><farm name="USCitrixSite" /></backupFarmRefs></equivalentFarmSet><equivalentFarmSet name="UKCitrixSite" loadBalanceMode="Failover" aggregationGroup="AggregationGroup1"><primaryFarmRefs><farm name="UKCitrixSite" /></primaryFarmRefs></equivalentFarmSet></equivalentFarmSets></userFarmMapping>'
$NewNode = $UserFarmMapping.CreateElement($DestinationName)
$NewNode.SetAttribute("name",$FirmMappingName)
$NewNode.InnerXML = ($CloneNode.userFarmMapping).InnerXML
$NewNode.groups.group.name=$GroupName
$NewNode.groups.group.sid=$GroupSID
$NewNode.equivalentFarmSets.equivalentFarmSet[0].name="FirmSetPrimary"+$FirmMappingName
($NewNode.equivalentFarmSets.equivalentFarmSet[0].primaryFarmRefs.farm)[0].name=$PrimarySiteName
($NewNode.equivalentFarmSets.equivalentFarmSet[0].primaryFarmRefs.farm)[1].name=$SecondarySiteName
($NewNode.equivalentFarmSets.equivalentFarmSet[0].backupFarmRefs.farm).name=$SecondarySiteName
$NewNode.equivalentFarmSets.equivalentFarmSet[1].name="FirmSetSecondary"+$FirmMappingName
$NewNode.equivalentFarmSets.equivalentFarmSet[1].primaryFarmRefs.farm.name=$PrimarySiteName
[void]$ParentNode.AppendChild($NewNode)
$UserFarmMapping.Save($XMLFilePath)
}
##########################################################################################
#Function to remove the group Firm 
###########################################################################
function RemoveGroupFirmMapping($FirmMappingName)
{
#Powershell script to add group to store front HAA
#Path to StoreFront1 Server
#Write-Host "The StoreFront Server is" $StoreFrontServer
$XMLFilePath = "C:\inetpub\wwwroot\Citrix\Geneva\web.config"
$SourceName = "userFarmMapping"
$DestinationName = "userFarmMapping"
[xml]$UserFarmMapping = Get-Content $XMLFilePath
$ParentNode = $UserFarmMapping.configuration.'citrix.deliveryservices'.resourcesCommon.resourcesWingConfigurations.resourcesWingConfiguration.userFarmMappings
$CheckFirmID=$ParentNode.userFarmMapping.name | Where-Object {$_ -eq $FirmMappingName}
Write-Host $ParentNode
#Check for Firm is already Exist or not
if($CheckFirmID -ne $null)
{

$ParentNode.userFarmMapping| Where-Object {$_.name -eq $FirmMappingName } | % {$ParentNode.RemoveChild($_)}
} 
else
{ 
Write-Host "The Firm $FirmMappingName is Does Not Exits" 
Exit
}
$UserFarmMapping.Save($XMLFilePath)
}
Export-ModuleMember -Function FirmBasedMapping
Export-ModuleMember -Function RemoveGroupFirmMapping