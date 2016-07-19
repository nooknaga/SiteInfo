param(
    [string]$FIRMID="930585",                
    [string]$ENVIRONMENT,
    [string]$COMPANYNAME="Geneva",
    [string]$SITE="US"
)
Import-Module C:\CitrixScripts\Modules\CitriSiteDetails_Module.psm1
Import-Module C:\CitrixScripts\Modules\CitixDeploymentOperations.psm1
$SiteDetails=GetSiteDetails $SITE
Write-Host $SiteDetails.Site1DCServer1
Write-Host $SiteDetails.Site2DCServer1
Write-Host $SiteDetails.Site1SFServer1
Write-Host $SiteDetails.Site2SFServer1
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

#Creddentails to Invoke-Command
$Username1="hosting\svc_cxjoiner"
$password1=convertto-securestring "1r5Qq3t5RTbh" -asplaintext -force
$credentials1=New-object -typename System.Management.Automation.PSCredential -argumentlist $Username1,$password1
##################################################################################################
#Creating Machine Catalog
##################################################################################################
#Creating Machine catalog for Prod Users in Site1
Write-Host Creating Machine Catlaog for $SiteDetails.Site1DCServer1 for Group $ProdCatalogGroup
Invoke-Command -Credential $credentials1 -ComputerName $SiteDetails.Site1DCServer1 -ScriptBlock ${function:CreateCatalog} -ArgumentList $ProdCatalogGroup,$ProdCatalogGroupDesc,$SiteDetails.Site1DCServer1
Write-Host Creating Machine Catlaog for $SiteDetails.Site1DCServer1 for Group $StgCatalogGroup
Invoke-Command -Credential $credentials1 -ComputerName $SiteDetails.Site1DCServer1 -ScriptBlock ${function:CreateCatalog} -ArgumentList $StgCatalogGroup,$StgCatalogGroupDesc,$SiteDetails.Site1DCServer1
#Creating Machine Cataog for Stage Users in Site2
#Write-Host Creating Machine Catlaog for $SiteDetails.Site2DCServer1 for Group $ProdCatalogGroup
#Invoke-Command -Credential $credentials1 -ComputerName $SiteDetails.Site2DCServer1 -ScriptBlock ${function:CreateCatalog} -ArgumentList $machineCatalogName,$machineCatalogDesc,$SiteDetails.Site2DCServer1
#Write-Host Creating Machine Catlaog for $SiteDetails.Site2DCServer1 for Group $StgCatalogGroup
#Invoke-Command -Credential $credentials1 -ComputerName $SiteDetails.Site2DCServer1 -ScriptBlock ${function:CreateCatalog} -ArgumentList $machineCatalogName,$machineCatalogDesc,$SiteDetails.Site2DCServer1
############################################################################################
#Creating DeliveryGroup 
############################################################################################
#Creating Delivery Group for Prod Users in Site1
Write-Host Creating Machine Catlaog for $SiteDetails.Site1DCServer1 for Group $ProdDelGroup
Invoke-Command -Credential $credentials1 -ComputerName $SiteDetails.Site1DCServer1 -ScriptBlock ${function:CreateDeliveryGroup} -ArgumentList $ProdDelGroup,$ProdDelGroupDesc,$arrUsersGroupProd,$ProdCatalogGroup,$SiteDetails.Site1DCServer1
Write-Host Creating Machine Catlaog for $SiteDetails.Site1DCServer1 for Group $StgDelGroup
Invoke-Command -Credential $credentials1 -ComputerName $SiteDetails.Site1DCServer1 -ScriptBlock ${function:CreateDeliveryGroup} -ArgumentList $StgDelGroup,$StgDelGroupDesc,$arrUsersGroupStg,$StgCatalogGroup,$SiteDetails.Site1DCServer1
#Creating Delivery Group for Prod Users in Site2
#Write-Host Creating Machine Catlaog for $SiteDetails.Site2DCServer1 for Group $ProdDelGroup
#Invoke-Command -Credential $credentials1 -ComputerName $SiteDetails.Site2DCServer1 -ScriptBlock ${function:CreateDeliveryGroup} -ArgumentList $ProdDelGroup,$ProdDelGroupDesc,$arrUsersGroupProd,$ProdCatalogGroup,$SiteDetails.Site2DCServer1
#Write-Host Creating Machine Catlaog for $SiteDetails.Site2DCServer1 for Group $StgDelGroup
#Invoke-Command -Credential $credentials1 -ComputerName $SiteDetails.Site2DCServer1 -ScriptBlock ${function:CreateDeliveryGroup} -ArgumentList $StgDelGroup,$StgDelGroupdesc,$arrUsersGroupStg,$StgCatalogGroup,$SiteDetails.Site2DCServer1
########################################################################################################################################################
############################################################################################
#Creating Publish Apps
############################################################################################
#Creating Delivery Group for Prod Users in Site1
Write-Host Adding Applications for $SiteDetails.Site1DCServer1 Production Delivery Group firm : $FIRMID
Invoke-Command -Credential $credentials1 -ComputerName $SiteDetails.Site1DCServer1 -ScriptBlock ${function:PublishApp} -ArgumentList $ProdDelGroup,$SiteDetails.Site1DCServer1
Write-Host Adding Applications for $SiteDetails.Site1DCServer1 Staging Delivery Group firm : $FIRMID
Invoke-Command -Credential $credentials1 -ComputerName $SiteDetails.Site1DCServer1 -ScriptBlock ${function:PublishApp} -ArgumentList $StgDelGroup,$SiteDetails.Site1DCServer1
#Creating Delivery Group for Prod Users in Site2
#Write-Host Adding Applications for $SiteDetails.Site2DCServer1 Production Delivery Group firm : $FIRMID
#Invoke-Command -Credential $credentials1 -ComputerName $SiteDetails.Site2DCServer1 -ScriptBlock ${function:PublishApp} -ArgumentList $ProdDelGroup,$SiteDetails.Site2DCServer1
#Write-Host Adding Applications for $SiteDetails.Site2DCServer1 Staging Delivery Group firm : $FIRMID
#Invoke-Command -Credential $credentials1 -ComputerName $SiteDetails.Site2DCServer1 -ScriptBlock ${function:PublishApp} -ArgumentList $StgDelGroup,$SiteDetails.Site2DCServer1
