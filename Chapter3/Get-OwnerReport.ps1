##############################################################################
##
## Get-OwnerReport.ps1
##
## From Windows PowerShell Cookbook (O'Reilly)
## by Lee Holmes (http://www.leeholmes.com/guide)
##
## カレントディレクトリのファイルのリストを取得し、各ファイルの所有者を
## 結果のオブジェクトに追加する。
##
## 例:
##    Get-OwnerReport
##    Get-OwnerReport | Format-Table Name,LastWriteTime,Owner
##############################################################################

$files = Get-ChildItem
foreach ($file in $files)
{
    $owner = (Get-Acl $file).Owner
    $file | Add-Member NoteProperty Owner $owner
    $file
}
