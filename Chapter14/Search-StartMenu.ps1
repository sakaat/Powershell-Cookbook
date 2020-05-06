##############################################################################
##
## Search-StartMenu.ps1
##
## From Windows PowerShell Cookbook (O'Reilly)
## by Lee Holmes (http://www.leeholmes.com/blog)
##
## 指定されたテキストとマッチする項目を[スタート]メニューから検索する。
## このスクリプトは、リンクの([スタート]メニューに表示される)名前と、
## リンク先の両方を検索する。
##
## 例:
##
##  PS >Search-StartMenu "Character Map" | Invoke-Item
##  PS >Search-StartMenu "network" | Select-FilteredObject | Invoke-Item
##
##############################################################################

param(
    $pattern = $(throw "Please specify a string to search for.")
)

## [スタート]メニューのパスの場所を取得する
$myStartMenu = [Environment]::GetFolderPath("StartMenu")
$shell = New-Object -Com WScript.Shell
$allStartMenu = $shell.SpecialFolders.Item("AllUsersStartMenu")

## 検索する語をエスケープする。これにより、正規表現の文字は
## 検索に影響を及ぼさなくなる
$escapedMatch = [Regex]::Escape($pattern)

## リンク名のテキストを検索する
Get-ChildItem $myStartMenu *.lnk -rec | Where-Object { $_.Name -match "$escapedMatch" }
Get-ChildItem $allStartMenu *.lnk -rec | Where-Object { $_.Name -match "$escapedMatch" }

## リンク先のテキストを検索する
Get-ChildItem $myStartMenu *.lnk -rec |
Where-Object { $_ | Select-String "\\[^\\]*$escapedMatch\." -Quiet }
Get-ChildItem $allStartMenu *.lnk -rec |
Where-Object { $_ | Select-String "\\[^\\]*$escapedMatch\." -Quiet }
