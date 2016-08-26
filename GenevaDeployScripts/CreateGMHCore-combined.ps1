#  
# Geneva Core Server Deployment Script
# Written by: Michael Calabrese
# Email: mcalabre@advent.com
#
# Below are the command line variables that will feed information into the script from the orchestration tool (TBD)
# Command Line Syntax is
# ./CreateGMHCore-1.ps1 -f <firm id> -pr <profile id>      -u <VC username> -p <VC password> -gu <Guest User> -gp <Guest Password>
#
# Test
# ./CreateGMHCore-1.ps1 -FIRMID 096077 -PROFILETYPE P1 -DATASTORE SacLun03B_NA_SAS -NETWORK sac_ctx_dmz_599
# ./CreateGMHCore-1.ps1 096077 P1 SacLun03B_NA_SAS sac_ctx_dmz_599

# Parameters are passed from Jenkins Orchestration tool
# FIRMID 		: 7 digit number associated with a customer Firm id
# PROFILETYPE	: P1,P1,P3 ..... Based on Customer Sizing
# DATASTORE		: The actual data store where the customer VM will need to be deployed to
# NETWORK		: The network to drop the customer app/db system
# ENVIRONMENT   : Used to determine if you are deploying to the lab or production
param(
	[string]$FIRMID,
  [string]$FUNCTIONALENV,
	[string]$PROFILETYPE,
	[string]$DATASTORE,
	[string]$NETWORK,
  [string]$ENVIRONMENT,
  [string]$SUBNETID,
  [string]$IPADDRESS,
  [string]$COREDBIP,
  [string]$GENEVAVERSION,
  [string]$GENEVACOREVER,
  [string]$GENEVAPATCHVER,
  [string]$SSUSERNAME,
  [string]$SSPASSWORD,
  [string]$SUFFIX
  )

# Sourcing ip calc
. "C:\Program Files (x86)\Jenkins\jobs\GenevaCoreStack_Lab\workspace\bin\IPFunc.ps1"
# Sourcing secret server functions
. "C:\Program Files (x86)\Jenkins\jobs\GenevaCoreStack_Lab\workspace\bin\sspslib.ps1"

Write-Host "Parameters Passed to the script"
Write-Host $FIRMID
Write-Host $FUNCTIONALENV
Write-Host $NETWORK
Write-Host $PROFILETYPE
Write-Host $DATASTORE
Write-Host $ENVIRONMENT
Write-Host $IPADDRESS
Write-Host $SUBNETID
Write-Host $GENEVAVERSION
Write-Host $GENEVACOREVER
Write-Host $GENEVAPATCHVER
#Write-Host $SSPASSWORD
# SS paramter information
$domain = 'advent.com'
$url = 'https://vmsfclandestine.advent.com/webservices/sswebservice.asmx'
$connection = connectss $url $domain $SSUSERNAME $SSPASSWORD
$loaderpass = getsspassword $connection.tokenid $connection.proxyid "loader"
$genevarootpass = getsspassword $connection.tokenid $connection.proxyid "GenevaRHLrootaccount"
$svcdeployvm = getsspassword $connection.tokenid $connection.proxyid "svcdeployvm@prod.dx"

# Used for troubleshooting password
#Write-Host $loaderpass
#Write-Host $genevarootpass

# Dump Parameters from Jenkins into JSON file locally and then place on 

# Create array of parameters that will be passed to the end system to be consumed by Chef
# The JSON file will be written out to a file locally, then copied over to the end system
$parameterarray = @{firmid=$FIRMID;profile=$PROFILETYPE;version=$GENEVAVERSION;loaderpass=$loaderpass;corever=$GENEVACOREVER;patchver=$GENEVAPATCHVER} | ConvertTo-JSON | Out-File -Encoding ASCII c:\WorkingDir\parameters-gmh.json


# Switch statement used to add the appropriate prefix to the end systems that are deployed 
switch($FUNCTIONALENV)
{
    "PRODUCTION" {$sysprefix="p"}
    "STAGING" {$sysprefix="s"}
    "DEVELOPMENT" { $sysprefix="d"}
}


# Connect to the appropriate Virtual Center based on ENVIRONMENT parameter passed in via Jenkins job
switch ($ENVIRONMENT)   
{
    "VMLab" {$viserver="10.128.2.219"
             $vcresourcepool="sacesxprod150.prod.dx"}  # lab
    "Prod"  {$viserver="10.128.2.215"
             $vcresourcepool="55ProdCl01"}  # vsac55sso01.prod.dx
}

Write-Host "You have Connected to the following VM resources"
Write-Host $viserver
Write-Host $vcresourcepool

# Import the PowerCLI module to be able to utilize the VMWare cmdlets
Add-PSSnapin VMware.VimAutomation.Core
Set-PowerCLIConfiguration -invalidCertificateAction "ignore" -confirm:$false

# Initial credentials are on the Jenkins server for VC, need to deprecate this with the new Method for pulling passwords out of Secret Server
$ScriptHomeDirectory = "C:\WorkingDir\credentials"

$usrname = "svcdeployvm@prod.dx"

# Pull password in from text file out of WorkingDir on either Jenkins Master or BuildSlave
#$passwrd = cat "c:\WorkingDir\credentials\cred.txt"

# Connect to the Virtual Center that will service this customer enviornment
Connect-VIServer -Server $viserver -Protocol https -User $usrname -Password $svcdeployvm | Out-Null

# The following looks for the folder name 
$foldername = $FIRMID.PadLeft(7,'0')
$folder = Get-Folder -Name $foldername

# Template to be used.  This should be changed into a Case statement that uses the appropriate template based on the PROFILETYPE Parameter passed in.
#

#$vmTemplate = Get-Template -Name "v55Rhel-Core-64-v1-Templ"
#$vmTemplate = Get-Template -Name "v55genevadb-p1"
$vmTemplate = Get-Template -Name "v55Rhel-64-genevadb-P1-Templ"



#$vname = "ps1h" + $FIRMID.PadLeft(7,'0') + "db01"
#$vname = "ps1h" + $FIRMID.Padleft(7,'0') + "db" + $SUFFIX.PadLeft(2,'0')
$vname = "ps1" + $sysprefix + $FIRMID.Padleft(7,'0') + "db" + $SUFFIX.PadLeft(2,'0')

# Create the new VM based on the Parameters passed in from the Jenkins Orchestration system

$NetworkID = Get-NetworkAddressCIDR($SUBNETID)          # Convert SubnetID to Decimal value
$CoreIP = ConvertTo-DottedDecimalIP($NetworkID + 21)     # Add 4 to the NetworkID for Core Server IP location, convert back to dotted decimal
Write-Host "Default IP if not specified will be : " $CoreIP
$DefaultGW = ConvertTo-DottedDecimalIP($NetworkID + 1)  # Add 1 to the NetworkID for the Default Gateway
Write-Host "Default Gateway of subnet will be:    " $DefaultGW

# Check to see if the Geneva Core DB IP was specified.  If specified, use that IP instead of the default offset.
if($COREDBIP)
  { 
    $CoreIP = $COREDBIP
    Write-Host "IP of Geneva Core DB :            " $CoreIP
  }


$linuxspec = New-OSCustomizationSpec -Name GenevaCoreBasetemp -OSType Linux -Domain "hosting.cloud.advent" -DnsServer "10.128.96.131","10.128.96.132" -NamingScheme VM -Type NonPersistent
Get-OSCustomizationSpec $linuxspec | Get-OSCustomizationNicMapping | where {$_.Position -eq 1} | Set-OSCustomizationNicMapping -IpMode UseStaticIp -IpAddress $CoreIP -SubnetMask "255.255.255.224" -DefaultGateway $DefaultGW
Write-Host "Creating New Virtual Machine"
$newvmtask = New-VM -Template $vmTemplate -Name $vname -Location $folder -ResourcePool $vcresourcepool -Datastore $DATASTORE -OSCustomizationSpec GenevaCoreBasetemp -RunAsync

# Wait task is to stop script progression until the VM has been cloned
Write-Host "Waiting until Template has been cloned"
Wait-Task -Task $newvmtask
$vm = Get-VM -Name $vname
# Evaluate PROFILETYPE and set cpu and memory characteristics of the VM
switch ($PROFILETYPE)
{
    "P1" {
          Set-VM -VM $vm -NumCpu 4 -MemoryMB 16384 -Confirm:$false
          $cpu="4"
          $mem="16"
         }
    "P2" {
          Set-VM -VM $vm -NumCpu 8 -MemoryMB 32768 -Confirm:$false
          $cpu="8"
          $mem="32"
         }
}  # was comment blocked to here
Write-Host "VM CPU count    : "$cpu
Write-Host "VM Memory size  : "$mem
# Set the network adapter
Write-Host "Getting NIC Adapter"
$nic = Get-VM -Name $vname | Get-NetworkAdapter -Name "Network adapter 1"
Write-Host "Setting Network on NIC Adapter"
Set-NetworkAdapter -NetworkAdapter $nic -NetworkName $NETWORK -Confirm:$false
Write-Host "Starting VM"
$startvmtask = Start-VM -VM $vm -RunAsync
Start-Sleep 120
#Wait-Task -Task $startvmtask					Need to determine why this does not work
Write-Host "Waiting for VMware Tools to start"
#Wait-Tools -VM $vm -TimeoutSeconds 200         Need to determine why this does not work
Start-Sleep -s 120





Write-Host "Starting the Chef Client Bootstrap"
#The following code downloads/installs the Chef client, credentials, and sets the appropriate Role via the chef-client command

$command1 = "/usr/bin/wget --ftp-user loader --ftp-password $loaderpass ftp://sachstsftp01.hosting.cloud.advent/Chef/chef-11.8.2-1.el6.x86_64.rpm"
#$command1 = "/usr/bin/wget https://opscode-omnibus-packages.s3.amazonaws.com/el/6/x86_64/chef-11.8.2-1.el6.x86_64.rpm"
$command2 = "rpm -ivh chef-11.8.2-1.el6.x86_64.rpm"
$vm | Invoke-VMScript -ScriptType Bash -ScriptText $command1 -GuestUser root -GuestPassword $genevarootpass
$vm | Invoke-VMScript -ScriptType Bash -ScriptText $command2 -GuestUser root -GuestPassword $genevarootpass
$vm | Invoke-VMScript -ScriptType Bash -ScriptText "mkdir /etc/chef" -GuestUser root -GuestPassword $genevarootpass
$vm | Copy-VMGuestFile -LocalToGuest -Source "c:\WorkingDir\credentials\client.rb" -Destination "/etc/chef" -GuestUser root -GuestPassword $genevarootpass
$vm | Copy-VMGuestFile -LocalToGuest -Source "c:\WorkingDir\credentials\chef-validator.pem" -Destination "/etc/chef" -GuestUser root -GuestPassword $genevarootpass
#$vm | Copy-VMGuestFile -LocalToGuest -Source "c:\WorkingDir\GenevaCore14.json" -Destination "/etc/chef" -GuestUser root -GuestPassword $genevarootpass
$vm | Copy-VMGuestFile -LocalToGuest -Source "c:\WorkingDir\genevacore.json" -Destination "/etc/chef" -GuestUser root -GuestPassword $genevarootpass
$vm | Copy-VMGuestFile -LocalToGuest -Source "c:\WorkingDir\parameters-gmh.json" -Destination "/etc/chef/parameters-gmh.json" -GuestUser root -GuestPassword $genevarootpass
Remove-Item "c:\WorkingDir\parameters-gmh.json"
#$vm | Invoke-VMScript -ScriptType Bash -ScriptText "chef-client -j /etc/chef/GenevaCore14.json" -GuestUser root -GuestPassword $genevarootpass
$vm | Invoke-VMScript -ScriptType Bash -ScriptText "chef-client -j /etc/chef/genevacore.json" -GuestUser root -GuestPassword $genevarootpass
##Set-VM -VM $newvm -OSCustomizationSpec $specClone -Confirm:$false -WhatIf
#>
Disconnect-VIServer -confirm:$false