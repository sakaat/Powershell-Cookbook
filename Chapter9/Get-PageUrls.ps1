##############################################################################
##
## Get-PageUrls.ps1
##
## From Windows PowerShell Cookbook (O'Reilly)
## by Lee Holmes (http://www.leeholmes.com/guide)
##
## 指定のファイルから全URLを解析する
##
## 例:
##    Get-PageUrls microsoft.html http://www.microsoft.com/ja/jp/default.aspx
##
##############################################################################
param(
   ## 解析対象のファイル名
   [string] $filename = $(throw "Please specify a filename."),

   ## ページのダウンロード先のURL
   ## 例えば、http://www.microsoft.com/ja/jp/default.aspx
   [string] $base = $(throw "Please specify a base URL."),

   ## 返されるURLをフィルタリングする際に使用する正規表現
   [string] $pattern = ".*"
)

## URLをデコードするために、System.Web DLLをロードする
[void] [Reflection.Assembly]::LoadWithPartialName("System.Web")

## アンカータグからURLを解析する正規表現を定義する
$regex = "<\s*a\s*[^>]*?href\s*=\s*[`"']*([^`"'>]+)[^>]*?>"

## ファイルのリンクを解析する
function Main
{
   ## 円記号をスラッシュに切り替えることにより、
   ## ソースURLの最低限の修正を行う
   $base = $base.Replace("\", "/")

   if ($base.IndexOf("://") -lt 0)
   {
      throw "Please specify a base URL in the form of " +
      "http://server/path_to_file/file.html"
   }

   ## ファイルの元となるサーバーを決定する。この処理は、
   ## 「/somefile.zip」といったリンクを解析する際に役立つ
   $base = $base.Substring(0, $base.LastIndexOf("/") + 1)
   $baseSlash = $base.IndexOf("/", $base.IndexOf("://") + 3)
   $domain = $base.Substring(0, $baseSlash)


   ## ファイルの中身全体を1つの大きな文字列に入れ、
   ## 正規表現のマッチを得る
   $content = [String]::Join(' ', (get-content $filename))
   $contentMatches = @(GetMatches $content $regex)

   foreach ($contentMatch in $contentMatches)
   {
      if (-not ($contentMatch -match $pattern)) { continue }

      $contentMatch = $contentMatch.Replace("\", "/")

      ## 次のようなhrefの形式が考えられる
      ## ./file
      ## file
      ## ../../../file
      ## /file
      ## url
      ## 解決のため、相対パスはすべて保持する。
      ## ルートを指し示すパスのみ解決が必要
      if ($contentMatch.IndexOf("://") -gt 0)
      {
         $url = $contentMatch
      }
      elseif ($contentMatch[0] -eq "/")
      {
         $url = "$domain$contentMatch"
      }
      else
      {
         $url = "$base$contentMatch"
         $url = $url.Replace("/./", "/")
      }

      ## HTMLエンティティを取り除いたらURLを返す
      [System.Web.HttpUtility]::HtmlDecode($url)
   }
}

function GetMatches([string] $content, [string] $regex)
{
   $returnMatches = new-object System.Collections.ArrayList

   ## ファイルの中身に対して正規表現をマッチさせ、トリミングした
   ## すべてのマッチを返却リストに追加する
   $resultingMatches = [Regex]::Matches($content, $regex, "IgnoreCase")
   foreach ($match in $resultingMatches)
   {
      $cleanedMatch = $match.Groups[1].Value.Trim()
      [void] $returnMatches.Add($cleanedMatch)
   }

   $returnMatches
}

. Main
