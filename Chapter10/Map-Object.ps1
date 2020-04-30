##############################################################################
##
## Map-Object.ps1
##
## From Windows PowerShell Cookbook (O'Reilly)
## by Lee Holmes (http://www.leeholmes.com/guide)
##
## 指定のマッピングコマンドを入力の各要素に適用する。
##
## 例:
##    1,2,3 | Map-Object { $_ * 2 }
##############################################################################
param([ScriptBlock] $mapCommand)

process
{
    & $mapCommand
}
