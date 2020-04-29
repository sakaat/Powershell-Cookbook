##############################################################################
##
## Select-FilteredObject.ps1
##
## From Windows PowerShell Cookbook (O'Reilly)
## by Lee Holmes (http://www.leeholmes.com/guide)
##
## 複雑なオブジェクトセットを選択しやすくするためのインタラクティブウィンドウ
## を提供する。この処理を行うために、まずパイプラインからすべての入力を取得し、
## その入力をメモ帳のウィンドウに示す。パイプラインに渡したいオブジェクトを
## 示す行を保持し、残りの行を削除し、ファイルを保存してメモ帳を終了する。
##
## 次に、このスクリプトは保持したオリジナルのオブジェクトをパイプラインに渡す。
##
## 例:
##    Get-Process | Select-FilteredObject | Stop-Process -WhatIf
##
##############################################################################

## PowerShellは項目をパイプラインに渡す前に「begin」スクリプトブロックを
## 実行する
begin
{
    ## 一時ファイルを作成する
    $filename = [System.IO.Path]::GetTempFileName()

    ## ファイルとの対話方法を説明するヘッダを「ヒア文字列」内に定義する
    $header = @"
############################################################
## パイプラインに渡したいオブジェクトを表す行を保持し、
## 残りの行を削除する。
##
## オブジェクトの選択が終了したら、ファイルを保存して
## 終了する。
############################################################

"@

    ## この指示をファイル内に置く
    $header > $filename

    ## オブジェクトのリストを保持する変数と、パイプラインに流される
    ## オブジェクトを記録するためのカウンタを初期化する
    $objectList = @()
    $counter = 0
}

## PowerShellは、パイプラインに渡す項目ごとに「process」スクリプトブロックを
## 実行する。このブロック内の「$_」変数は現在のパイプラインオブジェクトを表す
process
{
    ## PowerShellの書式設定(-f)演算子を使用して行をファイルに追加する。
    ## 例えば、Get-Processの出力が提供される場合、これらの行は次のようになる
    ##
    ## 30: System.Diagnostics.Process (powershell)
    "{0}: {1}" -f $counter, $_.ToString() >> $filename

    ## オブジェクトをオブジェクトのリストに追加し、カウンタをインクリメントする
    $objectList += $_
    $counter++
}

## すべてのオブジェクトをパイプラインに渡し終わると、
## PowerShellは「end」スクリプトブロックを実行する
end
{
    ## メモ帳を起動し、WaitForExit()メソッドを呼び出し、
    ## ユーザーがメモ帳を終了するまでスクリプトを一時停止する
    $processStartInfo = New-Object System.Diagnostics.ProcessStartInfo "notepad"
    $processStartInfo.Arguments = $filename
    $process = [System.Diagnostics.Process]::Start($processStartInfo)
    $process.WaitForExit()

    ## ファイルの各行を調べる
    foreach ($line in (Get-Content $filename))
    {
        ## 行が特別な形式(数字、1つのコロン、テキスト)になっているかを
        ## チェックする
        if ($line -match "^(\d+?):.*")
        {
            ## その形式とマッチした場合、$matches[1]はその数を表す。
            ## この値は「process」セクションの間に保存されたオブジェクトの
            ## リストのカウンタとなる。保存されたオブジェクトのリストから
            ## 該当のオブジェクトを出力する
            $objectList[$matches[1]]
        }
    }

    ## 最後に一時ファイルをクリーンアップする
    Remove-Item $filename
}
