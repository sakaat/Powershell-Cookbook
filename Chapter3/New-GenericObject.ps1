##############################################################################
##
## New-GenericObject.ps1
##
## From Windows PowerShell Cookbook (O'Reilly)
## by Lee Holmes (http://www.leeholmes.com/guide)
##
## ジェネリック型のオブジェクトを作成する。
##
## 使い方:
##
##   # 単純なジェネリックコレクション
##   New-GenericObject System.Collections.ObjectModel.Collection System.Int32
##
##   # 2つの型を持つジェネリックディクショナリ
##   New-GenericObject System.Collections.Generic.Dictionary `
##       System.String,System.Int32
##
##   # ジェネリックディクショナリの2番目の型としてのジェネリックリスト
##   $secondType = New-GenericObject System.Collections.Generic.List Int32
##   New-GenericObject System.Collections.Generic.Dictionary `
##       System.String,$secondType.GetType()
##
##   # 既定ではないコンストラクタを持つジェネリック型
##   New-GenericObject System.Collections.Generic.LinkedListNode `
##       System.String "Hi"
##
##############################################################################

param(
    [string] $typeName = $(throw "Please specify a generic type name"),
    [string[]] $typeParameters = $(throw "Please specify the type parameters"),
    [object[]] $constructorParameters
)

## ジェネリック型の名前を作成する
$genericTypeName = $typeName + '`' + $typeParameters.Count
$genericType = [Type] $genericTypeName

if (-not $genericType)
{
    throw "Could not find generic type $genericTypeName"
}

## 型引数をそれ自身にバインドする
[type[]] $typedParameters = $typeParameters
$closedType = $genericType.MakeGenericType($typedParameters)
if (-not $closedType)
{
    throw "Could not make closed type $genericType"
}

## ジェネリック型の閉じたバージョンを作成する
, [Activator]::CreateInstance($closedType, $constructorParameters)
