##############################################################################
##
## Invoke-CmdScript.ps1
##
## From Windows PowerShell Cookbook (O'Reilly)
## by Lee Holmes (http://www.leeholmes.com/guide)
##
## 指定されたバッチファイル(およびパラメータ)を呼び出す。
## 加えて、それを呼び出したPowerShell環境に環境変数の変更を伝える。
##
## 例:既存の'foo-that-sets-the-FOO-env-variable.cmd'の場合
##
## PS > type foo-that-sets-the-FOO-env-variable.cmd
## @set FOO=%*
## echo FOO set to %FOO%.
##
## PS > $env:FOO
##
## PS > Invoke-CmdScript "foo-that-sets-the-FOO-env-variable.cmd" Test
##
## C:\Temp>echo FOO set to Test.
## FOO set to Test.
##
## PS > $env:FOO
## Test
##
##############################################################################

param([string] $script, [string] $parameters)

$tempFile = [IO.Path]::GetTempFileName()

## cmd.exeの出力を格納する。また、バッチファイルの終了後に
## 環境テーブルを出力するようにcmd.exeに依頼する
cmd /c " `"$script`" $parameters && set > `"$tempFile`" "

## tempファイル内の環境変数を調べる
## 環境変数ごとにローカルな環境に設定する
Get-Content $tempFile | Foreach-Object {
    if ($_ -match "^(.*?)=(.*)$") {
        Set-Content "env:\$($matches[1])" $matches[2]
    }
}

Remove-Item $tempFile
