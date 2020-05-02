##############################################################################
##
## Select-GraphicalFilteredObject.ps1
##
## From Windows PowerShell Cookbook (O'Reilly)
## by Lee Holmes (http://www.leeholmes.com/guide)
##
## パイプライン経由で渡される項目リストをユーザーが選択するときに
## 使用できる便利なWindowsフォームを表示する。
##
## 例:
##
## PS >dir | Select-GraphicalFilteredObject
##
##    ディレクトリ: Microsoft.PowerShell.Core¥FileSystem::C:¥
##
##
## Mode                LastWriteTime     Length Name
## ----                -------------     ------ ----
## d----         10/7/2006   4:30 PM            Documents and Settings
## d----         3/18/2007   7:56 PM            Windows
##
##############################################################################

$objectArray = @($input)

## パイプライン経由で情報がスクリプトに渡されたことを確かめる
if ($objectArray.Count -eq 0)
{
    Write-Error "This script requires pipeline input."
    return
}

## Windowsフォームアセンブリをロードする
[void] [Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")

## メインのフォームを作成する
$form = New-Object Windows.Forms.Form
$form.Size = New-Object Drawing.Size @(600, 600)

## パイプラインからの項目を保持するリストボックスを作成する
$listbox = New-Object Windows.Forms.CheckedListBox
$listbox.CheckOnClick = $true
$listbox.Dock = "Fill"
$form.Text = "Select the list of objects you wish to pass down the pipeline"
$listBox.Items.AddRange($objectArray)

## [Ok]ボタンと[Cancel]ボタンを保持するボタンパネルを作成する
$buttonPanel = New-Object Windows.Forms.Panel
$buttonPanel.Size = New-Object Drawing.Size @(600, 30)
$buttonPanel.Dock = "Bottom"

## 右下に配置される[Cancel]ボタンを作成する
$cancelButton = New-Object Windows.Forms.Button
$cancelButton.Text = "Cancel"
$cancelButton.DialogResult = "Cancel"
$cancelButton.Top = $buttonPanel.Height - $cancelButton.Height - 5
$cancelButton.Left = $buttonPanel.Width - $cancelButton.Width - 10
$cancelButton.Anchor = "Right"

## [Cancel]の左側に配置される[Ok]ボタンを作成する
$okButton = New-Object Windows.Forms.Button
$okButton.Text = "Ok"
$okButton.DialogResult = "Ok"
$okButton.Top = $cancelButton.Top
$okButton.Left = $cancelButton.Left - $okButton.Width - 5
$okButton.Anchor = "Right"

## 各ボタンをボタンパネルに追加する
$buttonPanel.Controls.Add($okButton)
$buttonPanel.Controls.Add($cancelButton)

## ボタンパネルとリストボックスをフォームに追加し、
## さらにボタンに対するアクションを設定する
$form.Controls.Add($listBox)
$form.Controls.Add($buttonPanel)
$form.AcceptButton = $okButton
$form.CancelButton = $cancelButton
$form.Add_Shown( { $form.Activate() } )

## フォームを表示し、応答を待つ
$result = $form.ShowDialog()

## [Ok](またはEnterキー)が押された場合、チェック対象の項目を処理し、
## 該当のオブジェクトをパイプラインに渡す
if ($result -eq "OK")
{
    foreach ($index in $listBox.CheckedIndices)
    {
        $objectArray[$index]
    }
}
