$cmd = {
$text = 'Hello World'
$text | Add-Content D:\1234.txt
$env:StoreFront1 | Add-Content D:\1234.txt
$env:StoreFront2 | Add-Content D:\1234.txt
$env:DeliveryController1 | Add-Content D:\1234.txt
$env:DeliveryController2 | Add-Content D:\1234.txt
}
Invoke-Command -ScriptBlock $cmd

