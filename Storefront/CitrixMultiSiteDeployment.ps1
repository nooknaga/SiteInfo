param(
    [string]$FIRMID="930585",                
    [string]$ENVIRONMENT,
    [string]$COMPANYNAME="Geneva",
    [string]$SITE="US",
    [string]$SSUSERNAME,
    [string]$SSPASSWORD,
    [string]$Site1DCServer1,
    [string]$Site2DCServer1
)
Import-Module "$currentPath\Modules\sspslib.psm1"
Import-Module "$currentPath\Modules\CitixDeploymentOperations.psm1"
Write-Host $Site1DCServer1
Write-Host $Site2DCServer1
Write-Host $Site1SFServer1
Write-Host $Site2SFServer1
###########################################################################################
# Setup General variables
###########################################################################################
$assignedGroupProd = "HOSTING\$FIRMID-Geneva-Prod-Users"
$assignedGroupStg = "HOSTING\$FIRMID-Geneva-Stg-Users"
$ProdCatalogGroup = $FIRMID + "-" + $COMPANYNAME + "-Prod"
$ProdCatalogGroupDesc=$FIRMID + "-" + $COMPANYNAME + "-Prod Catalog Group"
$StgCatalogGroup = $FIRMID + "-" + $COMPANYNAME + "-Stg"
$StgCatalogGroupDesc = $FIRMID + "-" + $COMPANYNAME + "-Stg Catalog Group"
$ProdDelGroup = $FIRMID + "-" + $COMPANYNAME + "-Prod"
$ProdDelGroupDesc = $FIRMID + "-" + $COMPANYNAME + "-Prod Delivery Group"
$StgDelGroup = $FIRMID + "-" + $COMPANYNAME + "-Stg"
$stgDelGroupDesc = $FIRMID + "-" + $COMPANYNAME + "-Stage Delivery Group"
# Setup arrays of strings
$arrUsersGroupProd = "$FIRMID-Geneva-Prod-PowerUsers",`
                     "$FIRMID-Geneva-Prod-Users"

$arrUsersGroupStg = "$FIRMID-Geneva-Stg-PowerUsers",`
                    "$FIRMID-Geneva-Stg-Users"
#########################################################################################
#Get Secret Server for Invoke-Command
#SS paramter information
$domain = 'advent.com'
$url = 'https://vmsfclandestine.advent.com/webservices/sswebservice.asmx'
$connection = connectss $url $domain $SSUSERNAME $SSPASSWORD
$svcpass = getsspassword $connection.tokenid $connection.proxyid "svc_cxjoiner"
##################################################################################################

#Creddentails to Invoke-Command
$Username1="hosting\svc_cxjoiner"
$password1=convertto-securestring $svcpass -asplaintext -force
$credentials1=New-object -typename System.Management.Automation.PSCredential -argumentlist $Username1,$password1
##################################################################################################
#Creating Machine Catalog
##################################################################################################
#Creating Machine catalog for Prod Users in Site1
Write-Host Creating Machine Catlaog for $Site1DCServer1 for Group $ProdCatalogGroup
Invoke-Command -Credential $credentials1 -ComputerName $Site1DCServer1 -ScriptBlock ${function:CreateCatalog} -ArgumentList $ProdCatalogGroup,$ProdCatalogGroupDesc,$Site1DCServer1
Write-Host Creating Machine Catlaog for $Site1DCServer1 for Group $StgCatalogGroup
Invoke-Command -Credential $credentials1 -ComputerName $Site1DCServer1 -ScriptBlock ${function:CreateCatalog} -ArgumentList $StgCatalogGroup,$StgCatalogGroupDesc,$Site1DCServer1
#Creating Machine Cataog for Stage Users in Site2
#Write-Host Creating Machine Catlaog for $Site2DCServer1 for Group $ProdCatalogGroup
#Invoke-Command -Credential $credentials1 -ComputerName $Site2DCServer1 -ScriptBlock ${function:CreateCatalog} -ArgumentList $machineCatalogName,$machineCatalogDesc,$Site2DCServer1
#Write-Host Creating Machine Catlaog for $Site2DCServer1 for Group $StgCatalogGroup
#Invoke-Command -Credential $credentials1 -ComputerName $Site2DCServer1 -ScriptBlock ${function:CreateCatalog} -ArgumentList $machineCatalogName,$machineCatalogDesc,$Site2DCServer1
############################################################################################
#Creating DeliveryGroup 
############################################################################################
#Creating Delivery Group for Prod Users in Site1
Write-Host Creating Machine Catlaog for $Site1DCServer1 for Group $ProdDelGroup
Invoke-Command -Credential $credentials1 -ComputerName $Site1DCServer1 -ScriptBlock ${function:CreateDeliveryGroup} -ArgumentList $ProdDelGroup,$ProdDelGroupDesc,$arrUsersGroupProd,$ProdCatalogGroup,$Site1DCServer1
Write-Host Creating Machine Catlaog for $Site1DCServer1 for Group $StgDelGroup
Invoke-Command -Credential $credentials1 -ComputerName $Site1DCServer1 -ScriptBlock ${function:CreateDeliveryGroup} -ArgumentList $StgDelGroup,$StgDelGroupDesc,$arrUsersGroupStg,$StgCatalogGroup,$Site1DCServer1
#Creating Delivery Group for Prod Users in Site2
#Write-Host Creating Machine Catlaog for $Site2DCServer1 for Group $ProdDelGroup
#Invoke-Command -Credential $credentials1 -ComputerName $Site2DCServer1 -ScriptBlock ${function:CreateDeliveryGroup} -ArgumentList $ProdDelGroup,$ProdDelGroupDesc,$arrUsersGroupProd,$ProdCatalogGroup,$Site2DCServer1
#Write-Host Creating Machine Catlaog for $Site2DCServer1 for Group $StgDelGroup
#Invoke-Command -Credential $credentials1 -ComputerName $Site2DCServer1 -ScriptBlock ${function:CreateDeliveryGroup} -ArgumentList $StgDelGroup,$StgDelGroupdesc,$arrUsersGroupStg,$StgCatalogGroup,$Site2DCServer1
########################################################################################################################################################
############################################################################################
#Creating Publish Apps
############################################################################################
#Creating Delivery Group for Prod Users in Site1
Write-Host Adding Applications for $Site1DCServer1 Production Delivery Group firm : $FIRMID
Invoke-Command -Credential $credentials1 -ComputerName $Site1DCServer1 -ScriptBlock ${function:PublishApp} -ArgumentList $ProdDelGroup,$Site1DCServer1
Write-Host Adding Applications for $SiteDetails.Site1DCServer1 Staging Delivery Group firm : $FIRMID
Invoke-Command -Credential $credentials1 -ComputerName $Site1DCServer1 -ScriptBlock ${function:PublishApp} -ArgumentList $StgDelGroup,$Site1DCServer1
#Creating Delivery Group for Prod Users in Site2
#Write-Host Adding Applications for $Site2DCServer1 Production Delivery Group firm : $FIRMID
#Invoke-Command -Credential $credentials1 -ComputerName $Site2DCServer1 -ScriptBlock ${function:PublishApp} -ArgumentList $ProdDelGroup,$Site2DCServer1
#Write-Host Adding Applications for $SiteDetails.Site2DCServer1 Staging Delivery Group firm : $FIRMID
#Invoke-Command -Credential $credentials1 -ComputerName $Site2DCServer1 -ScriptBlock ${function:PublishApp} -ArgumentList $StgDelGroup,$Site2DCServer1
