##############################################################################
##
## Search-Help.ps1
##
## From Windows PowerShell Cookbook (O'Reilly)
## by Lee Holmes (http://www.leeholmes.com/guide)
##
## 指定されたキーワードまたは正規表現をPowerShellヘルプドキュメントから
## 検索する。
##
## 例:
##    Search-Help hashtable
##    Search-Help "(datetime|ticks)"
##############################################################################

param($pattern = $(throw "Please specify content to search for"))

$helpNames = $(Get-Help * | Where-Object { $_.Category -ne "Alias" })

foreach ($helpTopic in $helpNames) {
   $content = Get-Help -Full $helpTopic.Name | Out-String
   if ($content -match $pattern) {
      $helpTopic | Select-Object Name, Synopsis
   }
}
