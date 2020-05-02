## From Windows PowerShell Cookbook (O'Reilly)
## by Lee Holmes (http://www.leeholmes.com/guide)

# ディレクトリのサイズを取得する
function Get-DirectorySize
{
    Write-Debug "Current Directory: $(Get-Location)"

    Write-Verbose "Getting size"
    $size = (Get-ChildItem | Measure-Object -Sum Length).Sum
    Write-Verbose "Got size: $size"

    Write-Host ("Directory size: {0:N0} bytes" -f $size)
}

## Lengthでソートされた、ディレクトリ内の項目のリストを取得する
function Get-ChildItemSortedByLength($path = (Get-Location))
{
    ## 問題のあるバージョン
    ## Get-ChildItem $path | Format-Table | Sort Length

    ## 修正バージョン
    Get-ChildItem $path | Sort-Object -Property Length | Format-Table
}
