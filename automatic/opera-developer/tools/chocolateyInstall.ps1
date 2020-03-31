﻿$ErrorActionPreference = 'Stop'
$toolsPath = (Split-Path -Parent $MyInvocation.MyCommand.Definition)
. "$toolsPath\helpers.ps1"

$pp = Get-PackageParameters

$parameters += if ($pp.NoDesktopShortcut)     { " /desktopshortcut 0"; Write-Host "Desktop shortcut won't be created" }
$parameters += if ($pp.NoTaskbarShortcut)     { " /pintotaskbar 0"; Write-Host "Opera won't be pinned to taskbar" }

$packageArgs = @{
  packageName    = $env:ChocolateyPackageName
  fileType       = 'exe'
  url            = 'https://get.geo.opera.com/pub/opera-developer/69.0.3645.0/win/Opera_Developer_69.0.3645.0_Setup.exe'
  url64          = 'https://get.geo.opera.com/pub/opera-developer/69.0.3645.0/win/Opera_Developer_69.0.3645.0_Setup_x64.exe'
  checksum       = '06d5213db03c32aa05a10cee71fd1a0f77ab0493745c19a286f85a07f5fffbcf'
  checksum64     = 'a4fce3ace689e073ce12abde350fe7dad37749ded497ff7a7b6dd1b210945a9b'
  checksumType   = 'sha256'
  checksumType64 = 'sha256'
  silentArgs     = '/install /silent /launchopera 0 /setdefaultbrowser 0' + $parameters
  validExitCodes = @(0)
}

$version = '69.0.3645.0'
if (!$Env:ChocolateyForce -and (IsVersionAlreadyInstalled $version)) {
  Write-Output "Opera $version is already installed. Skipping download and installation."
} else {
  Install-ChocolateyPackage @packageArgs
}
