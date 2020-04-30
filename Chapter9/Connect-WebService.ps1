##############################################################################
##
## Connect-WebService.ps1
##
## From Windows PowerShell Cookbook (O'Reilly)
## by Lee Holmes (http://www.leeholmes.com/guide)
##
## 指定のWebサービスに接続し、Webサービスとの連携を可能にする型を
## 作成する。
##
## 例:
##
##     $wsdl = "http://terraserver.microsoft.com/TerraService2.asmx?WSDL"
##     $terraServer = Connect-WebService $wsdl
##     $place = New-Object Place
##     $place.City = "Redmond"
##     $place.State = "WA"
##     $place.Country = "USA"
##     $facts = $terraserver.GetPlaceFacts($place)
##     $facts.Center
##############################################################################
param(
    [string] $wsdlLocation = $(throw "Please specify a WSDL location"),
    [string] $namespace,
    [Switch] $requiresAuthentication)

## まだ存在していない場合は、Webサービスキャッシュを作成する
if (-not (Test-Path Variable:\Lee.Holmes.WebServiceCache))
{
    ${GLOBAL:Lee.Holmes.WebServiceCache} = @{ }
}

## このWebサービスに対する以前の接続のインスタンスが存在していないかを
## チェックする。存在する場合は、そのインスタンスを代わりに使用する
$oldInstance = ${GLOBAL:Lee.Holmes.WebServiceCache}[$wsdlLocation]
if ($oldInstance)
{
    $oldInstance
    return
}

## 必要なWebサービスDLLをロードする
[void] [Reflection.Assembly]::LoadWithPartialName("System.Web.Services")

## サービスに対するWSDLをダウンロードし、そこからサービス記述を作成する
$wc = New-Object System.Net.WebClient

if ($requiresAuthentication)
{
    $wc.UseDefaultCredentials = $true
}

$wsdlStream = $wc.OpenRead($wsdlLocation)

## WSDLのフェッチが可能であったかを確認する
if (-not (Test-Path Variable:\wsdlStream))
{
    return
}

$serviceDescription =
[Web.Services.Description.ServiceDescription]::Read($wsdlStream)
$wsdlStream.Close()

## サービス記述へのWSDLの読み込みが可能であったかを確認する
if (-not (Test-Path Variable:\serviceDescription))
{
    return
}

## WebサービスをCodeDomにインポートする
$serviceNamespace = New-Object System.CodeDom.CodeNamespace
if ($namespace)
{
    $serviceNamespace.Name = $namespace
}

$codeCompileUnit = New-Object System.CodeDom.CodeCompileUnit
$serviceDescriptionImporter =
New-Object Web.Services.Description.ServiceDescriptionImporter
$serviceDescriptionImporter.AddServiceDescription(
    $serviceDescription, $null, $null)
[void] $codeCompileUnit.Namespaces.Add($serviceNamespace)
[void] $serviceDescriptionImporter.Import(
    $serviceNamespace, $codeCompileUnit)

## CodeDomからのコードを1つの文字列として生成する
$generatedCode = New-Object Text.StringBuilder
$stringWriter = New-Object IO.StringWriter $generatedCode
$provider = New-Object Microsoft.CSharp.CSharpCodeProvider
$provider.GenerateCodeFromCompileUnit($codeCompileUnit, $stringWriter, $null)

## ソースコードをコンパイルする
$references = @("System.dll", "System.Web.Services.dll", "System.Xml.dll")
$compilerParameters = New-Object System.CodeDom.Compiler.CompilerParameters
$compilerParameters.ReferencedAssemblies.AddRange($references)
$compilerParameters.GenerateInMemory = $true

$compilerResults =
$provider.CompileAssemblyFromSource($compilerParameters, $generatedCode)

## 何らかのエラーが発生した場合は、それを書き込む
if ($compilerResults.Errors.Count -gt 0)
{
    $errorLines = ""
    foreach ($error in $compilerResults.Errors)
    {
        $errorLines += "`n`t" + $error.Line + ":`t" + $error.ErrorText
    }

    Write-Error $errorLines
    return
}
## エラーがなかった場合は、Webサービスオブジェクトを作成し、それを返す
else
{
    ## コンパイルしたアセンブリを取得する
    $assembly = $compilerResults.CompiledAssembly

    ## WebServiceBindingAttributeを持つ型を見つける。
    ## このファイルには他の「ヘルパー型」が存在する可能性
    ## があるが、それらはこの属性を持っていない
    $type = $assembly.GetTypes() |
    Where-Object { $_.GetCustomAttributes(
            [System.Web.Services.WebServiceBindingAttribute], $false) }

    if (-not $type)
    {
        Write-Error "Could not generate web service proxy."
        return
    }

    ## 型のインスタンスを作成し、それをキャッシュに格納し、
    ## ユーザーに返す
    $instance = $assembly.CreateInstance($type)

    ## 認証をサポートする多くのサービスでは、
    ## 結果のオブジェクトでそれが必要になる
    if ($requiresAuthentication)
    {
        if (@($instance.PsObject.Properties |
                Where-Object { $_.Name -eq "UseDefaultCredentials" }).Count -eq 1)
        {
            $instance.UseDefaultCredentials = $true
        }
    }

    ${GLOBAL:Lee.Holmes.WebServiceCache}[$wsdlLocation] = $instance

    $instance
}
