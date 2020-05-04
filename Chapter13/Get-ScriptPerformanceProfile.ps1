################################################################################
##
## Get-ScriptPerformanceProfile.ps1
##
## From Windows PowerShell Cookbook (O'Reilly)
## by Lee Holmes (http://www.leeholmes.com/guide)
##
## トレースレベル1で実行するトランスクリプトに基づいて、スクリプトの
## パフォーマンス特性を計算する。
##
## スクリプトをプロファイルするには次の手順を実行する。
##    1) スクリプトを実行するウィンドウでスクリプトトレースを有効にする。
##        Set-PsDebug -trace 1
##    2) スクリプトを実行するウィンドウのトランスクリプトを有効にする。
##        Start-Transcript
##        (ログの書き込み先としてPowerShellが使用するファイル名をメモする)
##    3) スクリプト名を入力するが、実際には開始しない。
##    4) PowerShellウィンドウをもう1つ開き、このスクリプトがあるディレクトリ
##       に移動する。「Get-ScriptPerformanceProfile <transcript>」と入力する。
##       <transcript>は手順2でメモしたパスに置き換える。Enterキーは押さない。
##    5) プロファイル対象スクリプトのウィンドウに切り替え、スクリプトを開始する。
##       このスクリプトを実行するウィンドウに切り替え、Enterキーを押す。
##    6) プロファイル対象スクリプトが終了するか、その作業が十分に長く実行
##       されるまで待機する。統計的な正確さを期すには、少なくとも10秒間は
##       スクリプトが実行される必要がある。
##    7) このスクリプトを実行するウィンドウに切り替え、いずれかのキーを押す。
##    8) プロファイル対象スクリプトのウィンドウに切り替え、以下を入力する。
##        Stop-Transcript
##    9) トランスクリプトを削除する。
##
## 注意:各行ではなく、コードの各領域(例えば関数)のプロファイルが可能である。
##      そのためには、まず領域の先頭に以下の呼び出しを置く。
##        write-debug "ENTER <region_name>"
##      そして領域の末尾に以下の呼び出しを置く。
##        write-debug "EXIT"
##      これにより、その領域で費やされる時間のみが計測され、その領域内に
##      含まれる領域で費やされる時間は計測されない。例えば、関数Aが関数Bを
##      呼び出し、かつそれが領域マーカーで囲まれている場合、関数Aの統計に
##      関数Bは含まれない。
##
################################################################################

param($logFilePath = $(throw "Please specify a path to the transcript log file."))

function Main
{
    ## スクリプトの実際のプロファイルを実行する。$uniqueLinesは、
    ## 行番号を実際のスクリプトの中身にマップしたものを取得する。
    ## $samplesは、行番号を、スクリプトが該当行を実行する回数に
    ## マップしたハッシュテーブルを返す
    $uniqueLines = @{ }
    $samples = GetSamples $uniqueLines

    "Breakdown by line:"
    "----------------------------"

    ## $samplesハッシュテーブルを逆にした新しいハッシュテーブルを作成
    ## する(サンプリングの回数をサンプリングの行にマップしたもの)。
    ## また、全体のサンプル数を計算する
    $counts = @{ }
    $totalSamples = 0;
    foreach ($item in $samples.Keys)
    {
        $counts[$samples[$item]] = $item
        $totalSamples += $samples[$item]
    }

    ## 逆にしたハッシュテーブルをサンプル数の降順でチェックする。
    ## その際、サンプル数を合計サンプルのパーセント値で出力する。
    ## これにより、スクリプトが該当行の実行に費やした時間の
    ## パーセント値が得られる
    foreach ($count in ($counts.Keys | Sort-Object -Descending))
    {
        $line = $counts[$count]
        $percentage = "{0:#0}" -f ($count * 100 / $totalSamples)
        "{0,3}%: Line {1,4} -{2}" -f $percentage, $line,
        $uniqueLines[$line]
    }

    ## トランスクリプトログをチェックし、マークされた領域に含まれる
    ## 行を得る。これにより、領域名をその領域に含まれる行にマップ
    ## したハッシュテーブルが返される
    ""
    "Breakdown by marked regions:"
    "----------------------------"
    $functionMembers = GenerateFunctionMembers

    ## 領域名ごとに、該当領域内の行をチェックする。行をチェックする
    ## 際に、各行に費やされた時間を加算し、その合計を出力する
    foreach ($key in $functionMembers.Keys)
    {
        $totalTime = 0
        foreach ($line in $functionMembers[$key])
        {
            $totalTime += ($samples[$line] * 100 / $totalSamples)
        }

        $percentage = "{0:#0}" -f $totalTime
        "{0,3}%: {1}" -f $percentage, $key
    }
}

## スクリプトの実際のプロファイルを実行する。$uniqueLinesは、
## 行番号を実際のスクリプトの中身にマップしたものを取得する。
## $samplesは、行番号を、スクリプトが該当行を実行する回数に
## マップしたハッシュテーブルを返す
function GetSamples($uniqueLines)
{
    ## ログファイルを開く。ファイルの末尾を監視できるように、ここでは
    ## .NetファイルI/Oを使用する。そうしないと、ファイルの長さ全体を
    ## スキャンするたびに、不正確な時間が測定されることになる
    $logStream = [System.IO.File]::Open($logFilePath, "Open", "Read", "ReadWrite")
    $logReader = New-Object System.IO.StreamReader $logStream

    $random = New-Object Random
    $samples = @{ }

    $lastCounted = $null

    ## ユーザーがいずれかのキーを押すまで統計を収集する
    while (-not $host.UI.RawUI.KeyAvailable)
    {
        ## 若干ランダムな時間でスリープするようにする。スリープの時間が
        ## 一定である場合、定期的な振る舞いを行うスクリプトを不適切に
        ## サンプリングしてしまうというリスクが生じる
        $sleepTime = [int] ($random.NextDouble() * 100.0)
        Start-Sleep -Milliseconds $sleepTime

        ## 最後のポーリング以降にトランスクリプトで生成された内容を
        ## 取得する。そのポーリングから、最後のDEBUGステートメント
        ## (実行された最後の行)を抽出する
        $rest = $logReader.ReadToEnd()
        $lastEntryIndex = $rest.LastIndexOf("DEBUG: ")

        ## 新しい行が得られなかった場合、キャプチャした最後の行で
        ## スクリプトはまだ実行中である
        if ($lastEntryIndex -lt 0)
        {
            if ($lastCounted) { $samples[$lastCounted] ++ }
            continue;
        }

        ## デバッグ行を抽出する
        $lastEntryFinish = $rest.IndexOf("\n", $lastEntryIndex)
        if ($lastEntryFinish -eq -1) { $lastEntryFinish = $rest.length }

        $scriptLine = $rest.Substring(
            $lastEntryIndex, ($lastEntryFinish - $lastEntryIndex)).Trim()
        if ($scriptLine -match 'DEBUG:[ \t]*([0-9]*)\+(.*)')
        {
            ## 行から行番号を取り出す
            $last = $matches[1]

            $lastCounted = $last
            $samples[$last] ++

            ## 行番号とマッチする実際のスクリプト行を取り出す
            $uniqueLines[$last] = $matches[2]
        }

        ## このポーリング中にバッファされたものをすべて破棄し、
        ## 再び待機を始める
        $logReader.DiscardBufferedData()
    }

    ## クリーンアップ
    $logStream.Close()
    $logReader.Close()

    $samples
}

## トランスクリプトログをチェックし、マークされた領域に含まれる
## 行を得る。これにより、領域名をその領域に含まれる行にマップ
## したハッシュテーブルが返される
function GenerateFunctionMembers
{
    ## 呼び出しスタックを表すスタックを作成する。その際、マーク
    ## された領域内に別のマークされた領域が含まれている場合は、
    ## その統計を適切に処理する
    $callstack = New-Object System.Collections.Stack
    $currentFunction = "Unmarked"
    $callstack.Push($currentFunction)

    $functionMembers = @{ }

    ## トランスクリプトファイル内の各行を順にチェックする
    foreach ($line in (Get-Content $logFilePath))
    {
        ## モニタブロックに入っているかどうかを確かめる。
        ## 入っていれば、その関数にそれを格納し、呼び出しスタック
        ## にプッシュする
        if ($line -match 'write-debug "ENTER (.*)"')
        {
            $currentFunction = $matches[1]
            $callstack.Push($currentFunction)
        }
        ## モニタブロックに入っているかどうかを確かめる。
        ## 入っていれば、呼び出しスタックから「現在の関数」を
        ## クリアし、新しい「現在の関数」を呼び出しスタックに
        ## 格納する
        elseif ($line -match 'write-debug "EXIT"')
        {
            [void] $callstack.Pop()
            $currentFunction = $callstack.Peek()
        }
        ## そうしないと、これは何らかのコードを持つ単なる行になる。
        ## 行番号を「現在の関数」のメンバとして追加する
        else
        {
            if ($line -match 'DEBUG:[ \t]*([0-9]*)\+')
            {
                ## 初期化されていない場合は配列リストを作成する
                if (-not $functionMembers[$currentFunction])
                {
                    $functionMembers[$currentFunction] =
                    New-Object System.Collections.ArrayList
                }

                ## 現在の行を配列リスト(ArrayList)に追加する
                if (-not $functionMembers[$currentFunction].Contains($matches[1]))
                {
                    [void] $functionMembers[$currentFunction].Add($matches[1])
                }
            }
        }
    }

    $functionMembers
}

. Main
