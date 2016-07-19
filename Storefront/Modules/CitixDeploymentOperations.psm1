
Function PublishApp($DesktopGroup,$adminadress)
{
  #Need to remove 1st and third param because they are not used
# Split DesktopGroup based on dash in name
# ex: Prod-96077, split Prod and 96077 into seperate variables
$firmid = $DesktopGroup.Split('-')[0]
$company = $DesktopGroup.Split('-')[1]
$environment = $DesktopGroup.Split('-')[2]

switch ($environment)
{
    "Prod" {$envlongname = "Production"
            $sysprefix = "p"}
    "Stg" {$envlongname = "Staging"
            $sysprefix = "s"}
    "Dev" {$envlongname = "Development"
            $sysprefix = "d"}
}

$gmhappserver = "ps1" + $sysprefix + $firmid.PadLeft(7,'0') + "ap01"
#Loading Citrix Powershell Module
Add-PSSnapin Citrix*
#Getting DesktopGroup ID
$DesktopID=Get-BrokerDesktopGroup | Where-Object {$_.Name -eq "$DesktopGroup"}
Write-Host $DesktopID.Uid
#Create Application and Publish ; Need to remove iconuid and replace with search of icon metadata 
New-BrokerApplication  -AdminAddress $adminadress -IconUid (Get-BrokerIcon | Where-Object {$_.MetadataMap.Values -eq "Excel"}).Uid -UserFilterEnabled $False -ApplicationType "HostedOnDesktop" -ClientFolder $envlongname -CommandLineArguments "" -CommandLineExecutable "%ProgramFiles(x86)%\Microsoft Office\Office15\EXCEL.EXE" -WorkingDirectory "%ProgramFiles(x86)%\Microsoft Office\Office15" -DesktopGroup $DesktopId.Uid -Enabled $True -Name "$environment-Excel-$firmid" -Priority 0 -PublishedName "Excel - $envlongname" 
New-BrokerApplication  -AdminAddress $adminadress -IconUid (Get-BrokerIcon | Where-Object {$_.MetadataMap.Values -eq "Word"}).Uid -UserFilterEnabled $False -ApplicationType "HostedOnDesktop" -ClientFolder $envlongname -CommandLineArguments "" -CommandLineExecutable "%ProgramFiles(x86)%\Microsoft Office\Office15\WINWORD.EXE" -WorkingDirectory "%ProgramFiles(x86)%\Microsoft Office\Office15" -DesktopGroup $DesktopId.Uid -Enabled $True -Name "$environment-Word-$firmid" -Priority 0 -PublishedName "Word - $envlongname" 
New-BrokerApplication  -AdminAddress $adminadress -IconUid (Get-BrokerIcon | Where-Object {$_.MetadataMap.Values -eq "File Explorer"}).Uid -UserFilterEnabled $False -ApplicationType "HostedOnDesktop" -ClientFolder $envlongname -CommandLineArguments "`"\\$gmhappserver.hosting.cloud.advent\group`"" -CommandLineExecutable "%ProgramFiles%\Internet Explorer\iexplore.exe" -WorkingDirectory "%ProgramFiles%\Internet Explorer" -DesktopGroup $DesktopId.Uid -Enabled $True -Name "$environment-File_Explorer-$firmid" -Priority 0 -PublishedName "File Explorer - $envlongname" 
New-BrokerApplication  -AdminAddress $adminadress -IconUid (Get-BrokerIcon | Where-Object {$_.MetadataMap.Values -eq "Geneva"}).Uid -UserFilterEnabled $False -ApplicationType "HostedOnDesktop" -ClientFolder $envlongname -CommandLineArguments "" -CommandLineExecutable "%ProgramFiles(x86)%\Advent\Geneva Desktop\Geneva.exe" -WorkingDirectory "%ProgramFiles(x86)%\Advent\Geneva Desktop" -DesktopGroup $DesktopId.Uid -Enabled $True -Name "$environment-Geneva-$firmid" -Priority 0 -PublishedName "Geneva - $envlongname" 
New-BrokerApplication  -AdminAddress $adminadress -IconUid (Get-BrokerIcon | Where-Object {$_.MetadataMap.Values -eq "Putty"}).Uid -UserFilterEnabled $True -ApplicationType "HostedOnDesktop" -ClientFolder $envlongname -CommandLineArguments "" -CommandLineExecutable "%ProgramFiles%\putty\putty.exe" -WorkingDirectory "%ProgramFiles%\putty" -DesktopGroup $DesktopId.Uid -Enabled $True -Name "$environment-Putty-$firmid" -Priority 0 -PublishedName "Putty - $envlongname" 
New-BrokerApplication  -AdminAddress $adminadress -IconUid (Get-BrokerIcon | Where-Object {$_.MetadataMap.Values -eq "RDP"}).Uid -UserFilterEnabled $True -ApplicationType "HostedOnDesktop" -ClientFolder $envlongname -CommandLineArguments "/v:$gmhappserver.hosting.cloud.advent" -CommandLineExecutable "C:\Windows\System32\mstsc.exe" -WorkingDirectory "" -DesktopGroup $DesktopId.Uid -Enabled $True -Name "$environment-RDP-$firmid" -Priority 0 -PublishedName "RDP - $envlongname" 
#New-BrokerApplication  -AdminAddress $adminadress -IconUid (Get-BrokerIcon | Where-Object {$_.MetadataMap.Values -eq "Notepad"}).Uid -UserFilterEnabled $True -ApplicationType "HostedOnDesktop" -ClientFolder $envlongname -CommandLineArguments "`"\\$gmhappserver.hosting.cloud.advent\Reports\reports.sln`"" -CommandLineExecutable "C:\Program Files (x86)\Microsoft Visual Studio 10.0\Common7\IDE\devenv.exe" -WorkingDirectory "" -DesktopGroup $DesktopId.Uid -Enabled $True -Name "$environment-Report_Designer-$firmid" -Priority 0 -PublishedName "Report Designer - $envlongname" 
#New-BrokerApplication  -AdminAddress $adminadress -IconUid (Get-BrokerIcon | Where-Object {$_.MetadataMap.Values -eq "Notepad"}).Uid -UserFilterEnabled $True -ApplicationType "HostedOnDesktop" -ClientFolder $envlongname -CommandLineArguments "" -CommandLineExecutable "%ProgramFiles(x86)%\Microsoft SQL Server\110\Tools\Binn\ManagementStudio\Ssms.exe" -WorkingDirectory "%ProgramFiles(x86)%\Microsoft SQL Server\110\Tools\Binn\ManagementStudio" -DesktopGroup $DesktopId.Uid -Enabled $True -Name "$environment-SQLSMS-$firmid" -Priority 0 -PublishedName "SQL SMS - $envlongname" 
New-BrokerApplication  -AdminAddress $adminadress -IconUid (Get-BrokerIcon | Where-Object {$_.MetadataMap.Values -eq "WinSCP"}).Uid -UserFilterEnabled $True -ApplicationType "HostedOnDesktop" -ClientFolder $envlongname -CommandLineArguments "" -CommandLineExecutable "%ProgramFiles(x86)%\WinSCP\WinSCP.exe" -WorkingDirectory "%ProgramFiles(x86)%\WinSCP" -DesktopGroup $DesktopId.Uid -Enabled $True -Name "$environment-WinSCP-$firmid" -Priority 0 -PublishedName "WinSCP - $envlongname" 
Add-BrokerUser -Name "HOSTING\$firmid-Geneva-$environment-PowerUsers" -Application "$environment-WinSCP-$firmid"
#Add-BrokerUser -Name "HOSTING\$firmid-Geneva-$environment-PowerUsers" -Application "$environment-SQLSMS-$firmid"
Add-BrokerUser -Name "HOSTING\$firmid-Geneva-$environment-PowerUsers" -Application "$environment-Putty-$firmid"
#Add-BrokerUser -Name "HOSTING\$firmid-Geneva-$environment-PowerUsers" -Application "$environment-Report_Designer-$firmid"
Add-BrokerUser -Name "HOSTING\$firmid-Geneva-$environment-PowerUsers" -Application "$environment-RDP-$firmid"
}

Function CreateCatalog($machineCatalogName,$machineCatalogDesc,$adminAddress)
{
#Machine catalog properties
[string]$domain = "hosting.cloud.advent"
[string]$orgUnit = "OU=CPU,OU=Advent,OU=AOD,DC=hosting,DC=cloud,DC=advent"
[string]$namingScheme = "WIN2K12-MCS" #AD machine account naming conventions
[string]$namingSchemeType = "Numeric" #Also: Alphabetic
[string]$allocType = "Random" #Also: Static
[string]$persistChanges = "OnLocal" #Also: OnLocal, OnPvD
[string]$provType = "Manual" #Also: Manual, PVS
[string]$sessionSupport = "MultiSession" #Also: MultiSession
#Setting up the Path 
$ADRoot="dc=hosting,dc=cloud,dc=advent"
$DomainController="10.128.96.132"
# Change to SilentlyContinue to avoid verbose output
$VerbosePreference = "Continue"
#Importing Active Directory to Current Powershell Session
#checking wheather Computer is exits in AD or not    
#Load the Citrix PowerShell modules
Write-Verbose "Loading Citrix modules."
Add-PSSnapin Citrix*
 
# Create a Machine Catalog. In this case a catalog with randomly assigned Server
Write-Verbose "Creating machine catalog. Name: $machineCatalogName; Description: $machineCatalogDesc; Allocation: $allocType"
New-BrokerCatalog  -AdminAddress $adminAddress -AllocationType $allocType -IsRemotePC $False -MachinesArePhysical $True -MinimumFunctionalLevel "L7" -Name $machineCatalogName -Description $machineCatalogDesc -PersistUserChanges $persistChanges -ProvisioningType $provType -Scope @() -SessionSupport $sessionSupport
#Creates/Updates metadata key-value pairs for the catalog
}

Function CreateDeliveryGroup($desktopGroupName,$desktopGroupDesc,[string[]]$assignedGroup,$machineCatalogName,$adminAddress)
{
#Set variables for the target infrastructure
Add-PSSnapin Citrix*
#Desktop Group properties
$desktopGroupPublishedName = "Test Delivery Group MWC"
$colorDepth = 'TwentyFourBit'
#$deliveryType = "DesktopsAndApps"
$deliveryType = "AppsOnly"
$desktopKind = "Shared" 
$sessionSupport = "MultiSession" #Also: SingleSession
#Machine Catalog
Write-Host $desktopGroupName
Write-Host $desktopGroupDesc
Write-Host $assignedGroup
Write-Host $machineCatalogName

#Creating Delivery Group
Get-LogSite  -AdminAddress $adminAddress
# Create the Desktop Group
If (!(Get-BrokerDesktopGroup -Name $desktopGroupName -ErrorAction SilentlyContinue)) {
 Write-Verbose "Creating new Desktop Group: $desktopGroupName"
 $DesktopGroup=New-BrokerDesktopGroup  -AdminAddress $adminAddress -ColorDepth $colorDepth -DeliveryType $deliveryType -DesktopKind $desktopKind -InMaintenanceMode $False -IsRemotePC $False -MinimumFunctionalLevel "L7" -Name $desktopGroupName -OffPeakBufferSizePercent 10 -PeakBufferSizePercent 10 -PublishedName $desktopGroupName -Scope @() -SecureIcaRequired $False -SessionSupport "MultiSession" -ShutdownDesktopsAfterUse $False -TimeZone "Pacific Standard Time"
}
# Add machines to the new desktop group. Uses the number of machines available in the target machine catalog
Write-Verbose "Getting details for the Machine Catalog: $machineCatalogName"
$machineCatalog = Get-BrokerCatalog -AdminAddress $adminAddress -Name $machineCatalogName

$arrUsersGroup = $assignedGroup
$arrUsersGroup | %{ 
    
  if (!(Get-BrokerUser -AdminAddress $adminAddress -Name $_ -ErrorAction SilentlyContinue)) {
          Write-Host "$_ not found. Creating now: " 
#Adding Broker User         
            $brokerUsers = New-BrokerUser -AdminAddress $adminAddress -Name $_
    } else { Write-Host "$_ found to exist already. Leaving unmolested." }          
}

$Num = 1
    Do {
        $Test = Test-BrokerEntitlementPolicyRuleNameAvailable -AdminAddress $adminAddress -Name @($desktopGroupName + "_" + $Num.ToString()) -ErrorAction SilentlyContinue
        If ($Test.Available -eq $False) { $Num = $Num + 1 }
   } While ($Test.Available -eq $False)
Write-Verbose "Assigning $brokerUsers.Name to Desktop Catalog: $machineCatalogName"
$DesktopID=Get-BrokerDesktopGroup | Where-Object {$_.Name -eq $desktopGroupName}
Write-Host "Adding machine configuration to delivery group"
#Add-BrokerMachineConfiguration -AdminAddress $adminAddress -Name $machineCatalog.Name -DesktopGroup $DesktopID.Uid
#$EntPolicyRule = New-BrokerEntitlementPolicyRule -AdminAddress $adminAddress -Name ($desktopGroupName + "_" + $Num.ToString()) -IncludedUsers $arrUsersGroup -DesktopGroupUid $DesktopID.Uid -Enabled $True -IncludedUserFilterEnabled $False

#Check whether access rules exist and then create rules for direct access and via Access Gateway
$accessPolicyRule = $desktopGroupName
Test-BrokerAppEntitlementPolicyRuleNameAvailable  -AdminAddress $adminAddress -Name @($accessPolicyRule)
New-BrokerAppEntitlementPolicyRule  -AdminAddress $adminAddress -DesktopGroupUid $DesktopID.Uid -Enabled $True -IncludedUserFilterEnabled $False -Name $accessPolicyRule
# Check whether access rules exist and then create rules for direct access and via Access Gateway
$accessPolicyRule = $desktopGroupName + "_Direct"
Test-BrokerAccessPolicyRuleNameAvailable  -AdminAddres $adminAddress -Name @($accessPolicyRule)
New-BrokerAccessPolicyRule  -AdminAddress $adminAddress -AllowedConnections "NotViaAG" -AllowedProtocols @("HDX","RDP") -AllowedUsers "Filtered" -AllowRestart $True -DesktopGroupUid $DesktopID.Uid -Enabled $True -IncludedSmartAccessFilterEnabled $True -IncludedUserFilterEnabled $True -IncludedUsers @($arrUsersGroup) -Name $accessPolicyRule
$accessPolicyRule = $desktopGroupName + "_AG"
Test-BrokerAccessPolicyRuleNameAvailable  -AdminAddress $adminAddress -Name @($accessPolicyRule)
New-BrokerAccessPolicyRule  -AdminAddress $adminAddress -AllowedConnections "ViaAG" -AllowedProtocols @("HDX","RDP") -AllowedUsers "Filtered" -AllowRestart $True -DesktopGroupUid $DesktopID.Uid -Enabled $True -IncludedSmartAccessFilterEnabled $True -IncludedSmartAccessTags @() -IncludedUserFilterEnabled $True -IncludedUsers @($arrUsersGroup) -Name $accessPolicyRule
# Script completed successfully
}

Export-ModuleMember -Function PublishApp
Export-ModuleMember -Function CreateDeliveryGroup
Export-ModuleMember -Function CreateCatalog

