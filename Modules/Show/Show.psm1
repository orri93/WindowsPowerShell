$ModuleOrder = @("Show", "Alias", "Utilities", "Select", "Network", "Arduino", "Enable", "Virtual", "Development")
$ModuleHelp = @{
"Show" = "Show Module
  Functions
    Show-GosHelp
    Show-Nics
    Show-NicIps
    Show-Env
    Show-Path
  Alias
    shnics for Get-NetAdapter"
"Alias" = "Alias Module
  Alias
    vs2013 for Visual Studio 2013 devenv.exe
    vs2019 for Visual Studio 2019 devenv.exe
    depends86 for 32 bit Dependency Walker
    depends64 for 64 bit Dependency Walker
    npp for Notepad++
    edit for Notepad++
    ch for Clear-Host"
"Utilities" = "Utilities Module
  Functions
    New-GosModuleManifest
    Set-Env [-Name] <string> [-Value] <string>
    Test-GosDocumentCertificate
    Get-GosDocumentCertificate
    Get-GosProtect [[-Content] <string>]
    Get-GosUnprotect [[-Content] <string>]
    Get-Secret [-Section] <string> [-Category] <string> [-Name] <string> [[-Type] 'Password']
    Find-Path [-Path] <string or array of string>
    Add-Path [-Path] <string or array of string>
    Remove-Path [-Path] <string or array of string>
    Find-Folders [-Name] <string> [-Path] <string>
    Remove-Folders [-Name] <string> [-Path] <string>
    Find-Files [-Name] <string> [-Path] <string>
    Remove-Files [-Name] <string> [-Path] <string>"

"Select" = "Select Module
  Functions
    Select-HomeOrri
    Select-HomeOrri
    Select-HomeOrriSrc
    Select-HomeOrriSrcExample
    Select-FdsSrc
    Select-MyPowerShell
    Select-MyDocuments
    Select-Arduino
    Select-Build
    Select-WbcBuild"
"Network" = "Network Module
  Functions
    Test-IpAddress [-IpAddress] <string>
    Find-Nic [-NicName] <string>
    Remove-NicIp [-NicName] <string> [-IpAddress] <string>
    New-NicIp [-NicName] <string> [-IpAddress] <string>
    Show-NetBinding [-Protocol] <string>
    Show-NetEstablished [-Protocol] <string>
    Show-NetRouteTable
  Alias
    netbinding for Show-NetBinding or netstat -a [-p] <string>
    established for Show-NetEstablished or netstat -o [-p] <string>
    netstat for Show-NetRouteTable or netstat -r"
"Arduino" = "Arduino Module
  Functions
    Get-ArduinoBoard [-Board] <string>
    Build-Arduino [-Board] <string>
    Upload-Arduino [-Board] <string> [-Port] <string>"
"Enable" = "Enable Module
  Functions
    Enable-VsC
    Enable-Qt5   Sets QTDIR addsQt bin to PATH
    Enable-Swig  Adds the Swig directory to PATH)"
"Development" = "Development Module
  Functions
    Add-Qt55Path"
}

function Show-GosHelp {
  [CmdletBinding()]
  Param (
    [parameter(Position=0,Mandatory=$false)] [String] $Subject,
    [parameter(Position=1,Mandatory=$false)] $Module
  )
  if($Module) {
    if($Module -like "Show") {
      Write-Host $ModuleHelp["Show"]
    } elseif($Module -like "Alias") {
      Write-Host $ModuleHelp["Alias"]
    } elseif($Module -like "Utilities") {
      Write-Host $ModuleHelp["Utilities"]
    } elseif($Module -like "Select") {
      Write-Host $ModuleHelp["Select"]
    } elseif($Module -like "Network") {
      Write-Host $ModuleHelp["Network"]
    } elseif($Module -like "Arduino") {
      Write-Host $ModuleHelp["Arduino"]
    } elseif($Module -like "Enable") {
      Write-Host $ModuleHelp["Enable"]
    } elseif($Module -like "Development") {
      Write-Host $ModuleHelp["Development"]
    } else {
      $ModuleOrder.GetEnumerator() | ForEach-Object {
        Write-Host ""
        Write-Host $ModuleHelp["$_"]
      }
    }
  } else {
    "GOS Help"
    "  Show-GosModules"
    "  Show-GosHelp [Subject]"
    ""
    "  Subjects"
  }
}

function Show-NicIp {
  Param ( [Parameter(Mandatory=$true, Position=0)] $NetIpAddress )
  $NetIpAddress.IPAddress + " on " + $NetIpAddress.InterfaceAlias
}

function Show-Nics {
  [CmdletBinding()]
  Param (
    [Parameter(Mandatory=$false,
               ValueFromPipelineByPropertyName=$true,
               Position=0)] 
    [string]
    $NicName
  )
  if($NicName) {
    Get-NetAdapter | Where { $_.Name -like "*$NicName*" }
  } else {
    Get-NetAdapter 
  }
}

function Show-NicIps {
  [CmdletBinding()]
  Param (
    [Parameter(Mandatory=$false,
               ValueFromPipelineByPropertyName=$true,
               Position=0)] 
    [string]
    $NicName
  )
  if($NicName) {
    Get-NetAdapter | Where { $_.Name -like "*$NicName*" } | ForEach-Object -Process {
      Get-NetIPAddress -InterfaceIndex $_.ifIndex | ForEach-Object -Process { Show-NicIp $_ }
    }
  } else {
    Get-NetIPAddress | ForEach-Object -Process { Show-NicIp $_ }
  }
}

function Show-Env { Get-ChildItem Env: }
function Show-Path { ${env:PATH} -split ";" }

New-Item alias:shnics -Value 'Get-NetAdapter'

Export-ModuleMember -Function 'Show-GosHelp'
Export-ModuleMember -Function 'Show-Nics'
Export-ModuleMember -Function 'Show-NicIps'
Export-ModuleMember -Function 'Show-Env'
Export-ModuleMember -Function 'Show-Path'
Export-ModuleMember -Alias 'shnics'

# SIG # Begin signature block
# MIIFxAYJKoZIhvcNAQcCoIIFtTCCBbECAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUDsILOWyqUthHPQRVPrJ9KOxh
# e1egggNJMIIDRTCCAjGgAwIBAgIQHkBq4ZZ1t79B2x69CojztDAJBgUrDgMCHQUA
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
# MQ4wDAYKKwYBBAGCNwIBFTAjBgkqhkiG9w0BCQQxFgQUZqHpLsGNzzmUgH+1eW1c
# B397SBowDQYJKoZIhvcNAQEBBQAEggEAQHoRNf9YUeSQc3aLPu9cXus8yeSrIS3o
# 44X+hwDhjbNXwQa0b0bHig5OMyJ4cKhj+aG0EOmu0hXuRo9m0IqkoH1IsOfu/di6
# /dnfTsOpCrUXx7kv11nlaL82vEnOFrWRfenOzN9q6iqj+kAdW0QUvSxQy3j+qia0
# T9oq2p9dIhYzkc4FcQ6hfsoOYGCjGkEa2n6Gl44TwgJhO0y7P3156Z2pvNJWXTbo
# ccwRqIWsDueXx6TZoC1+iFu3cBZvLC2uhlgX7IGypB3JO/go+bXTXJYlerplfN2X
# 0853Uh+4VKVxHZuLSvlCtHtSSZgGb5iYyqk5cEHja1JFGGCHmyChiw==
# SIG # End signature block
