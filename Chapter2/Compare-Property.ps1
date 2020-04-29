##############################################################################
##
## Compare-Property.ps1
##
## From Windows PowerShell Cookbook (O'Reilly)
## by Lee Holmes (http://www.leeholmes.com/guide)
##
## スクリプトに提供される入力とユーザーが提供したプロパティを比較する。
## これにより、Where-Objectコマンドレットに必要な構文を使わずに、
## 簡単なWhere-Objectの比較の機能を提供できる。
##
## 例:
##    Get-Process | Compare-Property Handles gt 1000
##    dir | Compare-Property PsIsContainer
##############################################################################
param($property, $operator = "eq", $matchText = "$true")

Begin { $expression = "`$_.$property -$operator `"$matchText`"" }
Process { if (Invoke-Expression $expression) { $_ } }
