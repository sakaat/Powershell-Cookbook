##############################################################################
## Send-TcpRequest.ps1
##
## From Windows PowerShell Cookbook (O'Reilly)
## by Lee Holmes (http://www.leeholmes.com/guide)
##
## リモートコンピュータにTCP要求を送信し、応答を返す。
## このスクリプトに(パイプラインまたは-InputObjectパラメータにより)
## 入力が渡されない場合は対話モードになる。
##
## 例:
##
##     $http = @"
##     GET / HTTP/1.1
##     Host:search.msn.com
##     `n`n
##     "@
##
##     $http | Send-TcpRequest search.msn.com 80
##############################################################################
param(
    [string] $remoteHost = "localhost",
    [int] $port = 80,
    [string] $inputObject,
    [int] $commandDelay = 100
)

[string] $output = ""

## スキャン対象の入力を配列に格納する。入力がない場合は
## 対話モードになる
$currentInput = $inputObject
if (-not $currentInput)
{
    $SCRIPT:currentInput = @($input)
}
$scriptedMode = [bool] $currentInput

function Main
{
    ## ソケットを開き、指定されたポートでコンピュータに接続する
    if (-not $scriptedMode)
    {
        Write-Host "Connecting to $remoteHost on port $port"
    }

    trap { Write-Error "Could not connect to remote computer: $_"; exit }
    $socket = New-Object System.Net.Sockets.TcpClient($remoteHost, $port)

    if (-not $scriptedMode)
    {
        Write-Host "Connected.  Press ^D followed by [ENTER] to exit.`n"
    }

    $stream = $socket.GetStream()
    $writer = New-Object System.IO.StreamWriter($stream)

    ## 応答を受け取るためのバッファを作成する
    $buffer = New-Object System.Byte[] 1024
    $encoding = New-Object System.Text.AsciiEncoding


    while ($true)
    {
        ## バッファされた出力を受け取る
        $SCRIPT:output += GetOutput

        ## スクリプトモードの場合は、コマンドを送り、
        ## 出力を受け取り、終了する
        if ($scriptedMode)
        {
            foreach ($line in $currentInput)
            {
                $writer.WriteLine($line)
                $writer.Flush()
                Start-Sleep -m $commandDelay
                $SCRIPT:output += GetOutput
            }

            break
        }
        ## 対話モードの場合は、バッファされた出力を書き込み、
        ## 入力に応答する
        else
        {
            if ($output)
            {
                foreach ($line in $output.Split("`n"))
                {
                    Write-Host $line
                }
                $SCRIPT:output = ""
            }

            ## ユーザーのコマンドを読み込む。^Dが入力されたら終了する
            $command = Read-Host
            if ($command -eq ([char] 4)) { break; }

            ## ^Dの入力がなければ、コマンドをリモートホストに書き込む
            $writer.WriteLine($command)
            $writer.Flush()
        }
    }

    ## ストリームを閉じる
    $writer.Close()
    $stream.Close()

    ## スクリプトモードの場合は出力を返す
    if ($scriptedMode)
    {
        $output
    }
}

## リモートホストから出力を読み込む
function GetOutput
{
    $outputBuffer = ""
    $foundMore = $false

    ## ストリームから利用可能な全データを読み込み、
    ## 終了したら出力バッファにそれらを書き込む
    do
    {
        ## データのバッファ可能な時間を設定する
        Start-Sleep -m 1000

        ## 利用可能なデータを読み込む
        $foundmore = $false
        while ($stream.DataAvailable)
        {
            $read = $stream.Read($buffer, 0, 1024)
            $outputBuffer += ($encoding.GetString($buffer, 0, $read))
            $foundmore = $true
        }
    } while ($foundmore)

    $outputBuffer
}

. Main
