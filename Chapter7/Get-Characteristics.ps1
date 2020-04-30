##############################################################################
##
## Get-Characteristics.ps1
##
## From Windows PowerShell Cookbook (O'Reilly)
## by Lee Holmes (http://www.leeholmes.com/guide)
##
## PE実行可能ファイル形式のファイルの特性を取得する。
##
## 例:
##
## PS > Get-Characteristics $env:WINDIR\notepad.exe
## IMAGE_FILE_LOCAL_SYMS_STRIPPED
## IMAGE_FILE_RELOCS_STRIPPED
## IMAGE_FILE_EXECUTABLE_IMAGE
## IMAGE_FILE_32BIT_MACHINE
## IMAGE_FILE_LINE_NUMS_STRIPPED
##
##############################################################################

param([string] $filename = $(throw "Please specify a filename."))

## PEファイルヘッダで使用される特性を定義する
## http://www.microsoft.com/japan/whdc/system/platform/firmware/PECOFF.mspx から取得
$characteristics = @{ }
$characteristics["IMAGE_FILE_RELOCS_STRIPPED"] = 0x0001
$characteristics["IMAGE_FILE_EXECUTABLE_IMAGE"] = 0x0002
$characteristics["IMAGE_FILE_LINE_NUMS_STRIPPED"] = 0x0004
$characteristics["IMAGE_FILE_LOCAL_SYMS_STRIPPED"] = 0x0008
$characteristics["IMAGE_FILE_AGGRESSIVE_WS_TRIM"] = 0x0010
$characteristics["IMAGE_FILE_LARGE_ADDRESS_AWARE"] = 0x0020
$characteristics["RESERVED"] = 0x0040
$characteristics["IMAGE_FILE_BYTES_REVERSED_LO"] = 0x0080
$characteristics["IMAGE_FILE_32BIT_MACHINE"] = 0x0100
$characteristics["IMAGE_FILE_DEBUG_STRIPPED"] = 0x0200
$characteristics["IMAGE_FILE_REMOVABLE_RUN_FROM_SWAP"] = 0x0400
$characteristics["IMAGE_FILE_NET_RUN_FROM_SWAP"] = 0x0800
$characteristics["IMAGE_FILE_SYSTEM"] = 0x1000
$characteristics["IMAGE_FILE_DLL"] = 0x2000
$characteristics["IMAGE_FILE_UP_SYSTEM_ONLY"] = 0x4000
$characteristics["IMAGE_FILE_BYTES_REVERSED_HI"] = 0x8000

## ファイルの中身をバイトの配列として取得する
$fileBytes = Get-Content $filename -ReadCount 0 -Encoding byte

## ファイル内のシグネチャのオフセットは0x3cの位置に格納される
$signatureOffset = $fileBytes[0x3c]

## PEファイルかどうかを確かめる
$signature = [char[]] $fileBytes[$signatureOffset..($signatureOffset + 3)]
if ([String]::Join('', $signature) -ne "PE`0`0")
{
    throw "This file does not conform to the PE specification."
}

## COFFヘッダーの位置はシグネチャから4バイト
$coffHeader = $signatureOffset + 4

## 特性データはCOFFヘッダからの18バイト。BitConverterクラスは
## 4バイトの整数への変換を管理する
$characteristicsData = [BitConverter]::ToInt32($fileBytes, $coffHeader + 18)

## 各特性をチェックする。ファイルのデータにフラグが
## 設定されている場合、その特性を出力する
foreach ($key in $characteristics.Keys)
{
    $flag = $characteristics[$key]
    if (($characteristicsData -band $flag) -eq $flag)
    {
        $key
    }
}
