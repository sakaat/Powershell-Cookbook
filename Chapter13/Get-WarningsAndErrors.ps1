##############################################################################
##
## Get-WarningsAndErrors.ps1
##
## From Windows PowerShell Cookbook (O'Reilly)
## by Lee Holmes (http://www.leeholmes.com/guide)
##
## Write-Warning、Write-Error、throwステートメントの各機能を例示する。
##
##############################################################################

Write-Warning "Warning: About to generate an error"
Write-Error "Error: You are running this script"
throw "Could not complete operation."
