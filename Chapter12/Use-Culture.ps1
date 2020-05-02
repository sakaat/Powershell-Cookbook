##############################################################################
##
## Use-Culture.ps1
##
## From Windows PowerShell Cookbook (O'Reilly)
## by Lee Holmes (http://www.leeholmes.com/guide)
##
## スクリプトブロックを指定の文化圏下に呼び出す。
##
## 例:
##
## PS >Use-Culture fr-FR { [DateTime]::Parse("25/12/2007") }
##
## mardi 25 décembre 2007 00:00:00
##
##############################################################################

param(
    [System.Globalization.CultureInfo] $culture =
    $(throw "Please specify a culture"),
    [ScriptBlock] $script = $(throw "Please specify a scriptblock")
)

## 現在の文化圏を設定するヘルパー関数
function Set-Culture([System.Globalization.CultureInfo] $culture)
{
    [System.Threading.Thread]::CurrentThread.CurrentUICulture = $culture
    [System.Threading.Thread]::CurrentThread.CurrentCulture = $culture
}

## オリジナルの文化圏情報を記憶する
$oldCulture = [System.Threading.Thread]::CurrentThread.CurrentUICulture

## ユーザーのスクリプトでエラーが発生した場合に、
## オリジナルの文化圏情報をリストアする
trap { Set-Culture $oldCulture }

## 現在の文化圏をユーザーが提供した文化圏に
## 設定する
Set-Culture $culture

## ユーザーのスクリプトブロックを呼び出す
& $script

## オリジナルの文化圏情報をリストアする
Set-Culture $oldCulture
