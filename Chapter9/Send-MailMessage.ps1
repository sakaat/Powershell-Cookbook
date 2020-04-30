##############################################################################
##
## Send-MailMessage.ps1
##
## From Windows PowerShell Cookbook (O'Reilly)
## by Lee Holmes (http://www.leeholmes.com/guide)
##
## PowerShellで電子メールを送信する際に使用するテクニックを示す。
##
## 例:
##
##  PS >$body = @"
##  >> Hi from another satisfied customer of The PowerShell Cookbook!
##  >> "@
##  >>
##  PS >$to = "guide_feedback@leeholmes.com"
##  PS >$subject = "Thanks for all of the scripts."
##  PS >$mailHost = "mail.leeholmes.com"
##  PS >Send-MailMessage $to $subject $body $mailHost
##
##############################################################################

param(
  [string[]] $to = $(throw "Please specify the destination mail address"),
  [string] $subject = "<No Subject>",
  [string] $body = $(throw "Please specify the message content"),
  [string] $smtpHost = $(throw "Please specify a mail server."),
  [string] $from = "$($env:UserName)@example.com"
)

## メールメッセージを作成する
$email = New-Object System.Net.Mail.MailMessage

## 各フィールドを埋める
foreach ($mailTo in $to)
{
  $email.To.Add($mailTo)
}

$email.From = $from
$email.Subject = $subject
$email.Body = $body

## メールを送信する
$client = New-Object System.Net.Mail.SmtpClient $smtpHost
$client.UseDefaultCredentials = $true
$client.Send($email)
