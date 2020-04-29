##############################################################################
##
## Get-AliasSuggestion.ps1
##
## From Windows PowerShell Cookbook (O'Reilly)
## by Lee Holmes (http://www.leeholmes.com/guide)
##
## 最後のコマンドのフルテキストからエイリアス候補を取得する。
##
## 例:
##
## PS > Get-AliasSuggestion Remove-ItemProperty
## Suggestion: An alias for Remove-ItemProperty is rp
##
##############################################################################

param($lastCommand)

$helpMatches = @()

## エイリアス候補を取得する
foreach ($alias in Get-Alias) {
    if ($lastCommand -match ("\b" +
            [System.Text.RegularExpressions.Regex]::Escape($alias.Definition) + "\b")) {
        $helpMatches += "Suggestion: An alias for $($alias.Definition) is $($alias.Name)"
    }
}

$helpMatches
