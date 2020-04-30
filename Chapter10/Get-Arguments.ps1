##############################################################################
##
## Get-Arguments.ps1
##
## From Windows PowerShell Cookbook (O'Reilly)
## by Lee Holmes (http://www.leeholmes.com/guide)
##
## コマンドライン引数を使用する。
##############################################################################
param($firstNamedArgument, [int] $secondNamedArgument = 0)

## 引数を名前で表示する
"First named argument is: $firstNamedArgument"
"Second named argument is: $secondNamedArgument"

function GetArgumentsFunction
{
    ## ここでも同様にparamステートメントが使える
    ## param($firstNamedArgument, [int] $secondNamedArgument = 0)

    ## 引数を位置で表示する
    "First positional function argument is: " + $args[0]
    "Second positional function argument is: " + $args[1]
}

GetArgumentsFunction One Two

$scriptBlock =
{
    param($firstNamedArgument, [int] $secondNamedArgument = 0)

    ## ここでも同様に$argsが使える
    "First named scriptblock argument is: $firstNamedArgument"
    "Second named scriptblock argument is: $secondNamedArgument"
}

& $scriptBlock -First One -Second 4.5
