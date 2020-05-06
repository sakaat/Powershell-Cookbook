## From Windows PowerShell Cookbook (O'Reilly)
## by Lee Holmes (http://www.leeholmes.com/guide)

## 現在実行しているスクリプトのフルパスとファイル名を知るには、次の関数を使用します。
## $myInvocation.ScriptNameステートメントを関数内に置くことによって、
## 現在実行しているスクリプトの名前を調べる際に用いるロジックを大幅に簡素化できます。

function Get-ScriptName
{
    $myInvocation.ScriptName
}

function Get-ScriptPath
{
    Split-Path $myInvocation.ScriptName
}
