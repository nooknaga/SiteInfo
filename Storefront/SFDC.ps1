param(
[parameter(Mandatory=$True)]
[String]$FirmID,
[parameter(Mandatory=$True)]
[String]$Site1StoreFront1,
#[parameter(Mandatory=$True)]
#[String]$Site1StoreFront2,
#[parameter(Mandatory=$True)]
#[String]$Site1DeliveryController1,
#[parameter(Mandatory=$True)]
#[String]$Site1DeliveryController2,
[parameter(Mandatory=$True)]
[String]$Site2StoreFront1,
#[parameter(Mandatory=$True)]
#[String]$Site2StoreFront2,
#[parameter(Mandatory=$True)]
#[String]$Site2DeliveryController1,
#[parameter(Mandatory=$True)]
#[String]$Site2DeliveryController2,
[parameter(Mandatory=$True)]
[String]$Site1CitrixSiteName,
[parameter (Mandatory=$True)]
[String]$Site2CitrixSiteName
)

$cmd = {
$FirmID | Add-Content D:\1234.txt
$Site1StoreFront1 | Add-Content D:\1234.txt
#$Site1StoreFront2 | Add-Content C:\1234.txt
#$Site1DeliveryController1 | Add-Content C:\1234.txt
#$Site1DeliveryController2 | Add-Content C:\1234.txt
$Site2StoreFront1 | Add-Content D:\1234.txt
#$Site2StoreFront2 | Add-Content C:\1234.txt
#$Site2DeliveryController1 | Add-Content C:\1234.txt
#$Site2DeliveryController2 | Add-Content C:\1234.txt
$Site1CitrixSiteName | Add-Content D:\1234.txt
$Site2CitrixSiteName | Add-Content D:\1234.txt
}
Invoke-Command -ScriptBlock $cmd

