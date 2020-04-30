##############################################################################
##
## Get-Answer.ps1
##
## From Windows PowerShell Cookbook (O'Reilly)
## by Lee Holmes (http://www.leeholmes.com/guide)
##
## EncartaのInstant Answersを使って質問に答える。
##
## 例:
##    Get-Answer "What is the population of China?"
##############################################################################
param([string] $question = $( throw "Please ask a question."))

function Main
{
    ## URLEncodeのために、System.Web.HttpUtility DLLをロードする
    [void] [System.Reflection.Assembly]::LoadWithPartialName("System.Web")

    ## 行の間に改行を用いて、Webページを単一の文字列に収める
    $encoded = [System.Web.HttpUtility]::UrlEncode($question)
    $url = "http://search.live.com/results.aspx?q=$encoded"
    $text = (new-object System.Net.WebClient).DownloadString($url)

    ## 注釈付きの回答を得る
    $startIndex = $text.IndexOf('<span class="answer_header">')
    $endIndex = $text.IndexOf('<h2 class="hide">Results</h2>')

    ## 結果が見つかったら、その結果をフィルタリングする
    if (($startIndex -ge 0) -and ($endIndex -ge 0))
    {
        $partialText = $text.Substring($startIndex, $endIndex - $startIndex)

        ## 以下は非常にもろいスクリーンスクレーピング
        $pattern = '<script.+?<div (id="results"|class="answer_fact_body")>'
        $partialText = $partialText -replace $pattern, "`n"
        $partialText = $partialText -replace '<span class="attr.?.?.?">', "`n"
        $partialText = $partialText -replace '<BR ?/>', "`n"

        $partialText = clean-html $partialText
        $partialText = $partialText -replace "`n`n", "`n"

        "`n" + $partialText.Trim()
    }
    else
    {
        "`nNo answer found."
    }
}

## テキストのチャンクからHTMLを取り除く
function clean-html ($htmlInput)
{
    $tempString = [Regex]::Replace($htmlInput, "<[^>]*>", "")
    $tempString.Replace("&nbsp&nbsp", "")
}

. Main
