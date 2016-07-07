param(
[parameter(Mandatory=$True)]
[String]$Site1StoreFront1,
[parameter(Mandatory=$True)]
[String]$Site1StoreFront2,
[parameter(Mandatory=$True)]
[String]$Site1DeliveryController1,
[parameter(Mandatory=$True)]
[String]$Site1DeliveryController2,
[parameter(Mandatory=$True)]
[String]$Site2StoreFront1,
[parameter(Mandatory=$True)]
[String]$Site2StoreFront2,
[parameter(Mandatory=$True)]
[String]$Site2DeliveryController1,
[parameter(Mandatory=$True)]
[String]$Site2DeliveryController2
)

$cmd = {
$text = 'Hello World'
$text | Add-Content D:\1234.txt
$Site1StoreFront1 | Add-Content D:\1234.txt
$Site1StoreFront2 | Add-Content D:\1234.txt
$Site1DeliveryController1 | Add-Content D:\1234.txt
$Site1DeliveryController2 | Add-Content D:\1234.txt
$Site2StoreFront1 | Add-Content D:\1234.txt
$Site2StoreFront2 | Add-Content D:\1234.txt
$Site2DeliveryController1 | Add-Content D:\1234.txt
$Site2DeliveryController2 | Add-Content D:\1234.txt
}
Invoke-Command -ScriptBlock $cmd

