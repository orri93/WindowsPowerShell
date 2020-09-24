
function Select-Path {
  param([System.IO.FileInfo]$Path)
  ""
  ""
  "Entering $Path"
  Set-Location $Path
}

function Select-HomeOrri {
  Select-Path "C:\home\orri"
}

function Select-HomeOrriSrc {
  Select-Path "C:\home\orri\src"
}

function Select-HomeOrriSrcExample {
  Select-Path "C:\home\orri\src\example"
}

function Select-FdsSrc {
  Select-Path "C:\home\orri\src\fds"
}

function Select-MyPowerShell {
  Select-Path "C:\Users\SigurdssonGO\Documents\WindowsPowerShell"
}

function Select-MyDocuments {
  Select-Path "C:\Users\SigurdssonGO\Documents"
}

function Select-Arduino {
  Select-Path "C:\Users\SigurdssonGO\Documents\Arduino"
}

function Select-Build {
  Select-Path "C:\build"
}

function Select-WbcBuild {
  Select-Path "C:\build\wellbore_connect"
}

Export-ModuleMember -Function 'Select-HomeOrri'
Export-ModuleMember -Function 'Select-HomeOrriSrc'
Export-ModuleMember -Function 'Select-HomeOrriSrcExample'
Export-ModuleMember -Function 'Select-FdsSrc'
Export-ModuleMember -Function 'Select-MyPowerShell'
Export-ModuleMember -Function 'Select-MyDocuments'
Export-ModuleMember -Function 'Select-Arduino'
Export-ModuleMember -Function 'Select-Build'
Export-ModuleMember -Function 'Select-WbcBuild'

# SIG # Begin signature block
# MIIFxAYJKoZIhvcNAQcCoIIFtTCCBbECAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUP+EQkT6jMxpL0/yEblP+/8Vz
# hNagggNJMIIDRTCCAjGgAwIBAgIQHkBq4ZZ1t79B2x69CojztDAJBgUrDgMCHQUA
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
# MQ4wDAYKKwYBBAGCNwIBFTAjBgkqhkiG9w0BCQQxFgQUxiywPMYss21aqrOjwZXq
# PlwxdPAwDQYJKoZIhvcNAQEBBQAEggEARWHZCT7OG7g9mYFfeIpb9Cia1G6rr2zK
# gkEluVnzmu2+6MZ4cYalPxg4/rYp9brGpwDncDY+tPHT5AmoDnS17Ei5m2KKRGlY
# 8EGzokrSn1MYNSXrneA7/hhkeXa47hbmKEQLbI/J4+YulMBKL6e9asBPxcLueNiv
# mid6gxv+Rbs+A6YAKfmS17uf81JbpFNAA5cQuwqMXMXLc2AeqYTd/axfhH9D/LVV
# fdgwy79dU0OV2QqMK1Y0FwMH9y4UgYe2INb44ZTJDFyAQbozJnvCyEtV74+kyKes
# GiuyIFagUvcM3EXU3ZkM/htE6ZGJoX6F013eBZGDzoOmSVjcEu6GMQ==
# SIG # End signature block
