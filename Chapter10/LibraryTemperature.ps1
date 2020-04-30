##############################################################################
##
## LibraryTemperature.ps1
## 温度の操作と変換を行う関数
##
## From Windows PowerShell Cookbook (O'Reilly)
## by Lee Holmes (http://www.leeholmes.com/guide)
##
##############################################################################

## 華氏を摂氏に変換する
function ConvertFahrenheitToCelcius([double] $fahrenheit)
{
    $celcius = $fahrenheit - 32
    $celcius = $celcius / 1.8
    $celcius
}
