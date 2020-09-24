#Requires -Modules @{ ModuleName="Utilities"; ModuleVersion="1.0.0" }

$Vs2013 = "C:\Program Files (x86)\Microsoft Visual Studio 12.0"
$Vs2013Tools = Join-Path -Path $Vs2013 -ChildPath "Common7\Tools"
$Vs2013Vc = Join-Path -Path $Vs2013 -ChildPath "VC"
$Vs2013VsDevCmd = Join-Path -Path $Vs2013Tools -ChildPath "vsdevcmd.bat"
$Vs2013VcVarsAll = Join-Path -Path $Vs2013Vc -ChildPath "vcvarsall.bat"

$Vs2019 = "C:\Program Files (x86)\Microsoft Visual Studio\2019\Professional"
$Vs2019Vc = Join-Path -Path $Vs2019 -ChildPath "VC"
$Vs2019VcBuild = Join-Path -Path $Vs2019Vc -ChildPath "Auxiliary\Build"
$Vs2019VcVarsAll = Join-Path -Path $Vs2019VcBuild -ChildPath "vcvarsall.bat"

$Qt55Dir="C:\Qt\Qt5.5.0\5.5\msvc2013"
$Qt55BinDir=Join-Path -Path $Qt55Dir -ChildPath "bin"

$Qt5142x32Dir="C:\Qt\5.14.2\msvc2017"
$Qt5142x32BinDir=Join-Path -Path $Qt5142x32Dir -ChildPath "bin"
$Qt5142x32QmlDir=Join-Path -Path $Qt5142x32Dir -ChildPath "qml"

$Qt5142x64Dir="C:\Qt\5.14.2\msvc2017_64"
$Qt5142x64BinDir=Join-Path -Path $Qt5142x64Dir -ChildPath "bin"
$Qt5142x64QmlDir=Join-Path -Path $Qt5142x64Dir -ChildPath "qml"

function Enable-Debugger {
<#
.SYNOPSIS
Enable Microsoft Debugger Tools
.DESCRIPTION
Add the Microsoft Debugger Tools directory to PATH.
.PARAMETER Platform
The Visual Studio platform. Supported platforms are 32 and 64.
.PARAMETER Help
Generate a help message.
.EXAMPLE
Enabl-Debugger
.EXAMPLE
Enabl-Debugger -Platform 64
.INPUTS
None. You cannot pipe objects to Enabl-Debugger.
.OUTPUTS
None. Enabl-Debugger does not generate any output.
.NOTES
This module is an example of what a well documented function could look.
.LINK
https://www.msdn.com
#>
  param(
  [Parameter(Mandatory=$false, Position=0)]
  [ValidateSet(32,64)]
  [int] $Platform = 32,
  [switch]$Help)
  
  if($Help) {
    Get-Help -Path $PSCommandPath -Full
  } else {
  
  switch($Platform) {
    32 { $Private:platformPath = "x86" }
    64 { $Private:platformPath = "x64" }
    default {
      Write-Error "Unknown version $Platform. Platform is either 32 or 64." -ErrorAction Stop
    }
  }
  
  $Private:debuggerPath = Get-Configuration -Section 'development' -Category 'debuggers' -Name 'path'
  
  $Private:debuggerPlatformPath = Join-Path -Path $Private:debuggerPath -ChildPath $Private:platformPath
  
  Write-Host "Enabling Microsoft Debugger Tools $Platform bit by adding ' $Private:debuggerPlatformPath' to Path"
  Add-Path -Path  $Private:debuggerPlatformPath
  
  Write-Host "Microsoft Debugger Tools $Platform bit has been enabled"
  Write-Host "The debugger path is $Private:debuggerPlatformPath"
  }
}


function Enable-VsC {
<#
.SYNOPSIS
Enable Visual Studio C/C++
.DESCRIPTION
Creates the Visual Studio environmental variable and adds the associated directories to PATH.
.PARAMETER Version
The Visual Studio version. Supported version are 2013 and 2019.
.PARAMETER Platform
The Visual Studio platform. Supported platforms are 32 and 64.
.PARAMETER Help
Generate a help message.
.EXAMPLE
Enabl-VsC
.EXAMPLE
Enabl-VsC -Version 2019 -Platform 64
.INPUTS
None. You cannot pipe objects to Enabl-VsC.
.OUTPUTS
None. Enabl-VsCQ does not generate any output.
.NOTES
This module is an example of what a well documented function could look.
.LINK
https://www.msdn.com
#>
  param(
  [Parameter(Mandatory=$false, Position=0)]
  [ValidateSet(2013, 2019)]
  [int] $Version = 2019,
  [Parameter(Mandatory=$false, Position=1)]
  [ValidateSet(32,64)]
  [int] $Platform = 32,
  [switch]$Help)
  
  if($Help) {
    Get-Help -Path $PSCommandPath -Full
  } else {

  switch($Version) {
    2013 {
      $VsVc = $Vs2013Vc;
      $VsVcVarsAll = $Vs2013VcVarsAll;
      switch($Platform) {
        32 { $PlatformKey = "x86" }
        64 { $PlatformKey = "amd64" }
        default {
          Write-Error "Unknown version $Platform. Platform is either 32 or 64." -ErrorAction Stop
        }
      }
    }
    2019 {
      $VsVc = $Vs2019Vc;
      $VsVcVarsAll = $Vs2013VcVarsAll;
      switch($Platform) {
        32 { $PlatformKey = "x86" }
        64 { $PlatformKey = "x64" }
        default {
          Write-Error "Unknown version $Platform. Platform is either 32 or 64." -ErrorAction Stop
        }
      }
    }
    default {
      Write-Error "Unknown version $Version. Version is either 2013 or 2019." -ErrorAction Stop
    }
  }
  Write-Host "Enabling Visual Studio $Version C/C++ $Platform bit with environmental variables"
  if (test-path $VsVc) {
    & "${env:COMSPEC}" /s /c "`"$VsVcVarsAll`" $PlatformKey && set" | foreach-object {
      if($_ -contains '=') {
        $name, $value = $_ -split '=', 2
        set-content env:\"$name" $value
        "Setting $name to $value"
      }
    }
  }
  Write-Host "Visual Studio $Version C/C++ $Platform bit has been enabled"
  Write-Host "Called $VsVcVarsAll with $PlatformKey"
  Write-Host "The VSVC path is $VsVc"
  }
}

#  .ExternalHelp Enable.psm1-Help.xml
function Enable-Qt5 {
<#
.SYNOPSIS
Enable Qt V5
.DESCRIPTION
Creates the QTDIR environmental variable and adds the bin directory to PATH.
.PARAMETER Version
The Qt5 version. Supported version are 5.5 and 5.14.
.PARAMETER Platform
The Qt5 platform. Supported platforms for 5.14 are x32 and x64
but for version 5.5 only x32 is supported.
.PARAMETER Help
Generate a help message.
.EXAMPLE
Enable-Qt5
.EXAMPLE
Enable-Qt5 -Version '5.14' -Platform 'x64'
.INPUTS
None. You cannot pipe objects to Enable-Qt5.
.OUTPUTS
None. Enable-Qt5 does not generate any output.
.NOTES
This module is an example of what a well documented function could look.
.LINK
https://www.qt.io
#>
  param(
  [Parameter(Mandatory=$false, Position=0)]
  [ValidateSet('5.5','5.14')]
  [string] $Version = '5.5',
  [Parameter(Mandatory=$false, Position=1)]
  [ValidateSet('x32','x64')]
  [string] $Platform = 'x32',
  [switch]$Help)

  if($Help) {
    Get-Help Enable-Qt5
    return
  }

  if(-not $Version -and $Platform -eq 'x64') {
    $Version = "5.14";
  } elseif(-not $Version) {
    $Version = "5.5";
  }

  if($Version -eq "5.5") {
    $qtdir = $Qt55Dir
    $qtdirbin = $Qt55BinDir
  } elseif($Version -eq "5.14") {
    "Setting QMAKEPATH to empty"
    Remove-Item env:\"QMAKEPATH"
    "Setting QML2_IMPORT_PATH empty"
    Remove-Item env:\"QML2_IMPORT_PATH"
    if(-not $platform) {
      $platform = "x64"
    }
    if($Platform -eq "x32") {
      $qtdir = $Qt5142x32Dir
      $qtdirbin = $Qt5142x32BinDir
      $qtdirqml = $Qt5142x32QmlDir
    } elseif($Platform -eq "x64") {
      $qtdir = $Qt5142x64Dir
      $qtdirbin = $Qt5142x64BinDir
      $qtdirqml = $Qt5142x64QmlDir      
    } else {
      Write-Error `
        "Unknown platform '$Platform'. Platform is either x32 or x64. " + `
        "x64 is default if not specified" -ErrorAction Stop
    }
  } else {
    Write-Error "Unknown version '$Version'. " + `
      "Version is either 5.5 or 5.14. 5.5 is default for x32 " + `      "and unspecified platforma and 5.14 is default for x64." `      -ErrorAction Stop
  }

  if($env:QTDIR -ne $qtdir) {
    "Setting QTDIR to $qtdir"
    Set-Content env:\"QTDIR" $qtdir
  } else {
    "QTDIR is alrady set to $qtdir"
  }
  $find = Find-Path -Path $qtdirbin
  if(-not $find) { 
    Add-Path $qtdirbin
  } else {
    "'$qtdirbin' is alrady in path"
  }
}

function Enable-Swig {
  Add-Path "C:\tools\swigwin-4.0.1"
  Add-Path "C:\tools\swigwin-4.0.1\Tools"
}

Export-ModuleMember -Function 'Enable-Debugger'
Export-ModuleMember -Function 'Enable-VsC'
Export-ModuleMember -Function 'Enable-Qt5'
Export-ModuleMember -Function 'Enable-Swig'

# SIG # Begin signature block
# MIIFxAYJKoZIhvcNAQcCoIIFtTCCBbECAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUCrKbesYpBZ9Bd07v6CC4xiGq
# O2ugggNJMIIDRTCCAjGgAwIBAgIQHkBq4ZZ1t79B2x69CojztDAJBgUrDgMCHQUA
# MDAxLjAsBgNVBAMTJUdPUyBQb3dlclNoZWxsIExvY2FsIENlcnRpZmljYXRlIFJv
# b3QwHhcNMjAwNTA1MTQyMzQyWhcNMzkxMjMxMjM1OTU5WjAZMRcwFQYDVQQDEw5H
# T1MgUG93ZXJTaGVsbDCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAOWB
# 8bs/IUQjhkC2BMs+UjPaSe4ACPayYcqEgFPvcAG7j9/sS9eafKqdaJa1fCz+nl5W
# N3UwWf6hqEdX23YQ6zB8ED5kvtu2Zyg+rZ+M6JYKk80Ln0Y0XF/NWy0cYlRBEg1y
# kAggHyrrgtEUM8tvpSbhSp/1of9uyXjYeyI9YDFnzBIayNwZaHwgf/LZxUg9UKUY
# JAOLoaI7ElfFQFFERe/BAoSlnXCqpkCWl3I9FGyur42Lf2g5xT2Eyzui6x2zEfmz
# L9cav1wMX6SqnN/w1+kETGQGowfHdyil9XxGdqhdsfYQKMYC50Mx2VFAtkQiISc0
# /cdcFKgcWshx4N7FNmkCAwEAAaN6MHgwEwYDVR0lBAwwCgYIKwYBBQUHAwMwYQYD
# VR0BBFowWIAQ05A6uS6gPIM7Ch7X/pUK/6EyMDAxLjAsBgNVBAMTJUdPUyBQb3dl
# clNoZWxsIExvY2FsIENlcnRpZmljYXRlIFJvb3SCEN2YFtdGM9+DR1GjsniKNjQw
# CQYFKw4DAh0FAAOCAQEAcVbaMg1fdQSu574uzQNmEFr/1LHvKMR1bxt20oVI4qut
# F1TLKblAbmlmsiRlfkUKHDIB7y3cc2wtU/06Ka9YTJXaz6q8CU9bXsRNoYN2c/e1
# QiP7qT36DrclY6195AYRHRHPQ67nZ9KERpVlhMUOAPDvkymt9BJyvcCXQ9IJ4UZz
# Nb0cCMRrx9DTTAHSv82rLzA8mFuZTdMMTq0nf9S4XWBCNw+jtJMWM0O74vJ9aoXX
# lKppOEMbuJIEKHRTUbhJq2HOpGLydT42mqWF7aN42YrFKo+7zo0yh9sHHq98Dl1M
# 4Smv4Y1kGEmhDlnWDTknaCMnSrwUwSvM9MlfkZ/nKDGCAeUwggHhAgEBMEQwMDEu
# MCwGA1UEAxMlR09TIFBvd2VyU2hlbGwgTG9jYWwgQ2VydGlmaWNhdGUgUm9vdAIQ
# HkBq4ZZ1t79B2x69CojztDAJBgUrDgMCGgUAoHgwGAYKKwYBBAGCNwIBDDEKMAig
# AoAAoQKAADAZBgkqhkiG9w0BCQMxDAYKKwYBBAGCNwIBBDAcBgorBgEEAYI3AgEL
# MQ4wDAYKKwYBBAGCNwIBFTAjBgkqhkiG9w0BCQQxFgQURd6mmWPL3X1eoJmJVL0A
# BGw1YAIwDQYJKoZIhvcNAQEBBQAEggEA2bIxMNHg9nZWMgMeNX0JDd78I3EWRavc
# xJNvUnEatTm9/UTLZ6PIfLNYoO+TkuNoqbFcMsEKdorvLOjtnAEfGfJ5whSJrMUW
# 67kIBDqvH6cK76TcY2zevXAtwEF7QrGqHJ3PRaOt3bjMlgGC18aZ+VuFrfPjdejp
# 9WYtXrp7SZR4YT9Ls6Yfg+AtVy8xzS37kIKDf0OZXnaYWR8KzrCJPh+md4ZwyUI7
# bQNv5/P2P5JMi6FDatjce2v8waB244eDFK9tz6nuWBCesBCnDLs0uII8fII/l2HZ
# MUqlj/ww/6T6oCeL8Xod95bxSFmu6uajhwMvQyPl46gQIb/SbuJmUg==
# SIG # End signature block
