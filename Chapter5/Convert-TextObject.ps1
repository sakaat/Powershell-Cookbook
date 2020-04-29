##############################################################################
##
## Convert-TextObject.ps1 -- 1つの簡単な文字列をカスタムの
## オブジェクトに変換する
##
## From Windows PowerShell Cookbook (O'Reilly)
## by Lee Holmes (http://www.leeholmes.com/guide)
##
##        パラメータ:
##
##        [string] Delimiter
##            このパラメータには、文字列を分割するための.NET正規表現を
##            指定する。このスクリプトは、この分割によって生じる要素から、
##            結果のオブジェクトのプロパティを生成する。
##            このパラメータを指定しなかった場合、既定では、空白を最大限
##            使って分割が行われる。ParseExpressionが指定されていない限り
##            "\s+"。
##
##        [string] ParseExpression
##            このパラメータには、文字列を解析するための.NET正規表現を
##            指定する。このスクリプトは、この正規表現によってキャプチャ
##            されたグループから、結果のオブジェクトのプロパティを生成する。
##
##        ** 注意 ** DelimiterとParseExpressionは相互に排他的である。
##
##        [string[]] PropertyName
##            このパラメータを指定した場合、このスクリプトは、指定された
##            オブジェクト定義の各名前と、解析した文字列の各要素をペアに
##            する。
##            このパラメータを指定しなかった場合(または、生成された
##            オブジェクトに、指定した数よりも多くのプロパティが含まれて
##            いる場合)、このスクリプトはプロパティ名をProperty1、Property2
##            ...PropertyNというパターンで使用する。
##
##        [type[]] PropertyType
##            このパラメータを指定した場合、このスクリプトは、指定された
##            リストの各型と、解析した文字列の各要素をペアにする。
##            このパラメータを指定しなかった場合(または、生成された
##            オブジェクトに、指定した数よりも多くのプロパティが含まれて
##            いる場合)、このスクリプトはプロパティを[string]型に設定する。
##
##
##        使用例:
##            "Hello World" | Convert-TextObject
##            「Property1=Hello」と「Property2=World」を持つオブジェクトが生成される。
##
##            "Hello World" | Convert-TextObject -Delimiter "ll"
##            「Property1=He」と「Property2=o World」を持つオブジェクトが生成される。
##
##            "Hello World" | Convert-TextObject -ParseExpression "He(ll.*o)r(ld)"
##            「Property1=llo Wo」と「Property2=ld」を持つオブジェクトが生成される。
##
##            "Hello World" | Convert-TextObject -PropertyName FirstWord,SecondWord
##            「FirstWord=Hello」と「SecondWord=World」を持つオブジェクトが生成される。
##
##            "123 456" | Convert-TextObject -PropertyType $([string],[int])
##            「Property1=123」と「Property2=456」を持つオブジェクトが生成される。
##            2番目のプロパティは文字列ではなく整数になる。
##
##############################################################################
param(
    [string] $delimiter,
    [string] $parseExpression,
    [string[]] $propertyName,
    [type[]] $propertyType
)

function Main(
    $inputObjects, $parseExpression, $propertyType,
    $propertyName, $delimiter)
{
    $delimiterSpecified = [bool] $delimiter
    $parseExpressionSpecified = [bool] $parseExpression

    ## ParseExpressionとDelimiterの両方が指定された場合、Usageを表示する
    if ($delimiterSpecified -and $parseExpressionSpecified)
    {
        Usage
        return
    }

    ## パラメータの入力がない場合、空白を既定の区切り子として仮定する
    if (-not $($delimiterSpecified -or $parseExpressionSpecified))
    {
        $delimiter = "\s+"
        $delimiterSpecified = $true
    }

    ## $inputObjectsの中身をチェックし、各オブジェクトに分解する
    foreach ($inputObject in $inputObjects)
    {
        if (-not $inputObject) { $inputObject = "" }
        foreach ($inputLine in $inputObject.ToString())
        {
            ParseTextObject $inputLine $delimiter $parseExpression `
                $propertyType $propertyName
        }
    }
}

function Usage
{
    "Usage: "
    " Convert-TextObject"
    " Convert-TextObject -ParseExpression parseExpression " +
    "[-PropertyName propertyName] [-PropertyType propertyType]"
    " Convert-TextObject -Delimiter delimiter " +
    "[-PropertyName propertyName] [-PropertyType propertyType]"
    return
}

## 関数定義 -- ParseTextObject
## 重い負担のタスクを実行する -- 文字列をコンポーネントごとに解析する。
## コンポーネントごとに、返すオブジェクトへのメモとしてそれを追加する
function ParseTextObject
{
    param(
        $textInput, $delimiter, $parseExpression,
        $propertyTypes, $propertyNames)

    $parseExpressionSpecified = -not $delimiter

    $returnObject = New-Object PSObject

    $matches = $null
    $matchCount = 0
    if ($parseExpressionSpecified)
    {
        ## 既定ではmatches変数を使用する
        [void] ($textInput -match $parseExpression)
        $matchCount = $matches.Count
    }
    else
    {
        $matches = [Regex]::Split($textInput, $delimiter)
        $matchCount = $matches.Length
    }

    $counter = 0
    if ($parseExpressionSpecified) { $counter++ }
    for (; $counter -lt $matchCount; $counter++)
    {
        $propertyName = "None"
        $propertyType = [string]

        ## 正規表現による解析
        if ($parseExpressionSpecified)
        {
            $propertyName = "Property$counter"

            ## プロパティ名を取得する
            if ($counter -le $propertyNames.Length)
            {
                if ($propertyName[$counter - 1])
                {
                    $propertyName = $propertyNames[$counter - 1]
                }
            }

            ## プロパティ値を取得する
            if ($counter -le $propertyTypes.Length)
            {
                if ($types[$counter - 1])
                {
                    $propertyType = $propertyTypes[$counter - 1]
                }
            }
        }
        ## 区切り子による解析
        else
        {
            $propertyName = "Property$($counter + 1)"

            ## プロパティ名を取得する
            if ($counter -lt $propertyNames.Length)
            {
                if ($propertyNames[$counter])
                {
                    $propertyName = $propertyNames[$counter]
                }
            }

            ## プロパティ値を取得する
            if ($counter -lt $propertyTypes.Length)
            {
                if ($propertyTypes[$counter])
                {
                    $propertyType = $propertyTypes[$counter]
                }
            }
        }

        Add-Note $returnObject $propertyName `
        ($matches[$counter] -as $propertyType)
    }

    $returnObject
}

## オブジェクトへメモを追加する
function Add-Note ($object, $name, $value)
{
    $object | Add-Member NoteProperty $name $value
}


Main $input $parseExpression $propertyType $propertyName $delimiter
