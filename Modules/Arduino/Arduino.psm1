$ArduinoCliPath="C:\bin\arduino-cli.exe"
$ArduinoHardwareAvrToolsPath="C:\Program Files (x86)\Arduino\hardware\tools\avr\bin"
$ArduinoHardwareAvrObjDump=Join-Path -Path $ArduinoHardwareAvrToolsPath -ChildPath "avr-objdump.exe"

$ArduinoBoardTable = @{
  uno = 'arduino:avr:uno'
  promicro33 = 'SparkFun:avr:promicro:cpu=8MHzatmega32U4'
  promicro50 = 'SparkFun:avr:promicro:cpu=16MHzatmega32U4'
}

function Show-ArduinoBoards {
  foreach($key in $ArduinoBoardTable.keys) {
    Write-Host "$($key), $($ArduinoBoardTable[$KEY])"
  }
}

function Get-ArduinoBoard {
  [CmdletBinding()]
  Param ([Parameter(ValueFromPipelineByPropertyName=$true, Position=0)] [string] $Board)
  if($Board -and ($ArduinoBoardTable.ContainsKey($Board))) {
    $ArduinoBoardTable[$Board]
  } else {
    Show-AllArduinoBoards
  }
}

function Build-Arduino {
  [CmdletBinding()]
  Param (
    [Parameter(ValueFromPipelineByPropertyName=$true, Position=0)] [string] $Board,
    [Parameter(ValueFromPipelineByPropertyName=$true, Position=1)] [string] $CompilerCppExtraFlags)
  if($Board) {
    if($ArduinoBoardTable.ContainsKey($Board)) {
      $CompileForBoard = $ArduinoBoardTable[$Board]
    } else {
      "Board '$Board' not found the valid boards are"
      Show-AllArduinoBoards
    }
  } else {
    $CompileForBoard = $ArduinoBoardTable['uno']
  }
  if($CompileForBoard) {
    if($CompilerCppExtraFlags) {
      Write-Host "`"$ArduinoCliPath`" compile -b $CompileForBoard --build-properties compiler.cpp.extra_flags=`"$CompilerCppExtraFlags`""
      & "${env:COMSPEC}" /s /c "`"$ArduinoCliPath`" compile -b $CompileForBoard --build-properties compiler.cpp.extra_flags=`"$CompilerCppExtraFlags`""
    } else {
      Write-Host "`"$ArduinoCliPath`" compile -b $CompileForBoard"
      & "${env:COMSPEC}" /s /c "`"$ArduinoCliPath`" compile -b $CompileForBoard"
    }
  }
}

function Upload-Arduino {
  [CmdletBinding()]
  Param (
    [Parameter(ValueFromPipelineByPropertyName=$true, Position=0)] [string] $Board,
    [Parameter(ValueFromPipelineByPropertyName=$true, Position=1)] [string] $Port)
  if($Board) {
    if($ArduinoBoardTable.ContainsKey($Board)) {
      $CompileForBoard = $ArduinoBoardTable[$Board]
    } else {
      "Board '$Board' not found the valid boards are"
      Show-AllArduinoBoards
    }
  } else {
    $CompileForBoard = $ArduinoBoardTable['uno']
  }
  if($Port) {
    if($CompileForBoard) {
      & "${env:COMSPEC}" /s /c "`"$ArduinoCliPath`" upload -v -t -p $Port -b $CompileForBoard" 
    }
  } else {
    "Serial Port not specified"
  }
}

function Disassemble-Arduino {
  [CmdletBinding()]
  Param (
    [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true, Position=0)] $Path)
  & "${env:COMSPEC}" /s /c "`"$ArduinoHardwareAvrObjDump`" -S $Path" 
}

function Clean-Arduino {
  Remove-Item -Path . -Filter *.hex
  Remove-Item -Path . -Filter *.elf
}

Export-ModuleMember -Function 'Show-ArduinoBoards'
Export-ModuleMember -Function 'Get-ArduinoBoard'
Export-ModuleMember -Function 'Build-Arduino'
Export-ModuleMember -Function 'Upload-Arduino'
Export-ModuleMember -Function 'Disassemble-Arduino'
Export-ModuleMember -Function 'Clean-Arduino'

# SIG # Begin signature block
# MIIFxAYJKoZIhvcNAQcCoIIFtTCCBbECAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUMYmFJgnbOw81BA9SMdTjWg41
# i02gggNJMIIDRTCCAjGgAwIBAgIQHkBq4ZZ1t79B2x69CojztDAJBgUrDgMCHQUA
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
# MQ4wDAYKKwYBBAGCNwIBFTAjBgkqhkiG9w0BCQQxFgQU6v8wc815zCqDzrakKNQY
# hrDwl1QwDQYJKoZIhvcNAQEBBQAEggEAkwYRK73hb7aX8Y2wVzWaKqi/Aci8lx9D
# eyRxNo6vNVVlUgrSYnngZ9ssuyd77DgL5GosRjgX7gBe1t3S4vEfC8B0kwYgFTq4
# Pu2LHqtchly3yz7BHaKdnol9qlUicJlFg0YtpGAn4O2H30ayNR76DiwlFzeffyj1
# zsH5SR44FxwwOiTZc+kTGWh2pw5HXXVXuRQLq9V28PcHljZaURjtnjulDEh5/f5U
# mQ2Tnc2om9Sje3hS3Sn8BKPJR0MoxoQ34Ujs5jTGEnDFpbGcOW4nbC9vrQYliE2e
# swaHBUf/Iaob/uSWuTFTjN7G26URSqWDejJgzHccRAHwVE5rynFOjQ==
# SIG # End signature block
