##############################################################################
##
## Get-InvocationInfo.ps1
##
## From Windows PowerShell Cookbook (O'Reilly)
## by Lee Holmes (http://www.leeholmes.com/guide)
##
## $myInvocation変数から提供される情報を表示する。
##
##############################################################################
param([switch] $preventExpansion)

## ヘルパー関数を定義する。これにより、$myInvocationが呼び出されたときと、
## ドットソースされたときにどのように変化するかがわかる
function HelperFunction
{
    "    MyInvocation from function:"
    "-"*50
    $myInvocation

    "    Command from function:"
    "-"*50
    $myInvocation.MyCommand
}

## スクリプトブロックを定義する。これにより、$myInvocationが呼び出されたときと、
## ドットソースされたときにどのように変化するかわかる
$myScriptBlock = {
    "    MyInvocation from script block:"
    "-"*50
    $myInvocation

    "    Command from script block:"
    "-"*50
    $myInvocation.MyCommand
}

## ヘルパーエイリアスを定義する
Set-Alias gii ./Get-InvocationInfo

## ユーザーが入力した行全体を$myInvocation.Lineがどのように返すかを表示する
"You invoked this script by typing: " + $myInvocation.Line

## スクリプトから$myInvocationが返す情報を表示する
"MyInvocation from script:"
"-"*50
$myInvocation

"Command from script:"
"-"*50
$myInvocation.MyCommand

## -PreventExpansionスイッチによる呼び出しの場合、さらなる処理は行わない
if ($preventExpansion)
{
    return
}

## 関数から$myInvocationが返す情報を表示する
"Calling HelperFunction"
"-"*50
HelperFunction

## ドットソースされた関数から$myInvocationが返す情報を表示する
"Dot-Sourcing HelperFunction"
"-"*50
. HelperFunction

## エイリアススクリプトから$myInvocationが返す情報を表示する
"Calling aliased script"
"-"*50
gii -PreventExpansion

## スクリプトブロックから$myInvocationが返す情報を表示する
"Calling script block"
"-"*50
& $myScriptBlock

## ドットソースされたスクリプトブロックから$myInvocationが返す情報を表示する
"Dot-Sourcing script block"
"-"*50
. $myScriptBlock

## エイリアススクリプトから$myInvocationが返す情報を表示する
"Calling aliased script"
"-"*50
gii -PreventExpansion
