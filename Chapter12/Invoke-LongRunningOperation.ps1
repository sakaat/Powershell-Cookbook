##############################################################################
##
## Invoke-LongRunningOperation.ps1
##
## From Windows PowerShell Cookbook (O'Reilly)
## by Lee Holmes (http://www.leeholmes.com/guide)
##
## Write-Progressコマンドレットを使用してステータス情報を表示する
##
##############################################################################

$activity = "A long running operation"

$status = "Initializing"
## 実行時間の長い処理を初期化する
for ($counter = 0; $counter -lt 100; $counter++)
{
    $currentOperation = "Initializing item $counter"
    Write-Progress $activity $status -PercentComplete $counter `
        -CurrentOperation $currentOperation
    Start-Sleep -m 20
}

$status = "Running"
## 実行時間の長い処理を実行する
for ($counter = 0; $counter -lt 100; $counter++)
{
    $currentOperation = "Running task $counter"
    Write-Progress $activity $status -PercentComplete $counter `
        -CurrentOperation $currentOperation
    Start-Sleep -m 20
}
