##############################################################################
##
## Read-HostWithPrompt.ps1
##
## From Windows PowerShell Cookbook (O'Reilly)
## by Lee Holmes (http://www.leeholmes.com/guide)
##
## 表示した選択肢のリストに従ってユーザーが入力した値を読み取る。
##
## 例:
##
##  PS >$caption = "Please specify a task"
##  PS >$message = "Specify a task to run"
##  PS >$option = "&Clean Temporary Files","&Defragment Hard Drive"
##  PS >$helptext = "Clean the temporary files from the computer",
##  >>              "Run the defragment task"
##  >>
##  PS >$default = 1
##  PS >Read-HostWithPrompt $caption $message $option $helptext $default
##
##  Please specify a task
##  Specify a task to run
##  [C] Clean Temporary Files  [D] Defragment Hard Drive  [?] Help
##  (default is "D"):?
##  C - Clean the temporary files from the computer
##  D - Run the defragment task
##  [C] Clean Temporary Files  [D] Defragment Hard Drive  [?] Help
##  (default is "D"):C
##  0
##
##############################################################################

param(
    $caption = $null,
    $message = $null,
    $option = $(throw "Please specify some options."),
    $helpText = $null,
    $default = 0
)

## 選択肢のリストを作成する
$choices = . ..\Chapter3\New-GenericObject.ps1 System.Collections.ObjectModel.Collection Management.Automation.Host.ChoiceDescription

## 各オプションをチェックし、それらを選択肢コレクションに追加する
for ($counter = 0; $counter -lt $option.Length; $counter++)
{
    $choice = New-Object Management.Automation.Host.ChoiceDescription $option[$counter]
    if ($helpText -and $helpText[$counter])
    {
        $choice.HelpMessage = $helpText[$counter]
    }

    $choices.Add($choice)
}

## 選択肢のプロンプト。ユーザーが選択した項目を返す
$host.UI.PromptForChoice($caption, $message, $choices, $default)
