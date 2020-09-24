function Test-IpAddress {
  [CmdletBinding()]
  Param (
    [Parameter(Mandatory=$true,
               ValueFromPipelineByPropertyName=$true,
               Position=0)]
    [ValidateScript({$_ -match [IPAddress]$_ })]  
    [string]
    $IpAddress
  )

  Begin {
  }
  Process {
    [ipaddress]$IPAddress
  }
  End {
  }
}

function Find-Nic {
  [CmdletBinding()]
  Param (
    [Parameter(Mandatory=$false,
               ValueFromPipelineByPropertyName=$true,
               Position=0)] 
    [string]
    $NicName
  )
  if($NicName) {
    $Private:nic = Get-NetAdapter | Where { $_.Name -eq $NicName }
    if($Private:nic) {
      $Private:nic
    } else {
      Get-NetAdapter | Where { $_.Name -like "*$NicName*" }
    }
  } else {
    Get-NetAdapter
  }
}

function Remove-NicIp {
  [CmdletBinding()]
  Param (
    [Parameter(Mandatory=$false,
               ValueFromPipelineByPropertyName=$true,
               Position=0)] 
    [string]
    $NicName,
    [Parameter(Mandatory=$false,
               ValueFromPipelineByPropertyName=$true,
               Position=1)]
    [ValidateScript({$_ -match [IPAddress]$_ })]  
    [string]
    $IpAddress
  )

  if($NicName) {
    $Private:nic = Find-Nic $NicName

    if($Private:nic) {
      if($Private:nic -is [array]) {
        "More than one Nic with the name $NicName was found!"
        $Private:nic
      } else {
        $Private:nicindex = $Private:nic.ifIndex
        $Private:nic
        $Private:nicat = 0
        Get-NetIPAddress -InterfaceIndex $Private:nicindex | ForEach-Object -Process {
          "Address no $Private:nicat is " + $_.IPAddress + " with Prefix Length " + $_.PrefixLength
          $Private:nicat++
        }
        if($IpAddress) {
          "Attempt to remove IP Address $IpAddress from $NicName (Requires Administartion Privlidges)"
          Remove-NetIPAddress -IPAddress $IpAddress -InterfaceIndex $Private:nicindex
        }
      }
    } else {
      "No Nic with the name $NicName was found!"
      Get-NetAdapter
    }
  } else {
    Get-NetAdapter
  }
}

function New-NicIp {
  [CmdletBinding()]
  Param (
    [Parameter(Mandatory=$false,
               ValueFromPipelineByPropertyName=$true,
               Position=0)] 
    [string]
    $NicName,
    [Parameter(Mandatory=$false,
               ValueFromPipelineByPropertyName=$true,
               Position=1)]
    [ValidateScript({$_ -match [IPAddress]$_ })]  
    [string]
    $IpAddress
  )

  if($NicName) {
    $Private:nic = Find-Nic $NicName

    if($Private:nic) {
      if($Private:nic -is [array]) {
        "More than one Nic with the name $NicName was found!"
        $Private:nic
      } else {
        $Private:nicindex = $Private:nic.ifIndex
        $Private:nic
        $Private:nicat = 0
        Get-NetIPAddress -InterfaceIndex $Private:nicindex | ForEach-Object -Process {
          "Address no $Private:nicat is " + $_.IPAddress + " with Prefix Length " + $_.PrefixLength
          $Private:nicat++
        }
        if($IpAddress) {
          "Attempt to modify IP Address to $IpAddress for $NicName (Requires Administartion Privlidges)"
          New-NetIPAddress -IPAddress $IpAddress -PrefixLength 24 -InterfaceIndex $Private:nicindex
        }
      }
    } else {
      "No Nic with the name $NicName was found!"
      Get-NetAdapter
    }
  } else {
    Get-NetAdapter
  }
}

function Show-NetBinding {
[CmdletBinding()]
  Param ([Parameter(Mandatory=$false, ValueFromPipelineByPropertyName=$true, Position=0)] [string] $Protocol)
  if($Protocol) {
    & netstat -p $Protocol -a
  } else {
    & netstat -a
  }
}

function Show-NetEstablished {
[CmdletBinding()]
  Param ([Parameter(Mandatory=$false, ValueFromPipelineByPropertyName=$true, Position=0)] [string] $Protocol)
  if($Protocol) {
    & netstat -p $Protocol -o
  } else {
    & netstat -o
  }
}

function Show-NetRouteTable {
  & netstat -r
}

New-Item alias:netbinding -value 'Show-NetBinding'
New-Item alias:established -value 'Show-NetEstablished'
New-Item alias:routetable -value 'Show-NetRouteTable'

Export-ModuleMember -Function 'Test-IpAddress'
Export-ModuleMember -Function 'Find-Nic'
Export-ModuleMember -Function 'Remove-NicIp'
Export-ModuleMember -Function 'New-NicIp'
Export-ModuleMember -Function 'Show-NetBinding'
Export-ModuleMember -Function 'Show-NetEstablished'
Export-ModuleMember -Function 'Show-NetRouteTable'

Export-ModuleMember -Alias 'netbinding'
Export-ModuleMember -Alias 'established'
Export-ModuleMember -Alias 'routetable'
# SIG # Begin signature block
# MIIFxAYJKoZIhvcNAQcCoIIFtTCCBbECAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUScFhEKU632ZLuShiXxq8i4/S
# VWKgggNJMIIDRTCCAjGgAwIBAgIQHkBq4ZZ1t79B2x69CojztDAJBgUrDgMCHQUA
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
# MQ4wDAYKKwYBBAGCNwIBFTAjBgkqhkiG9w0BCQQxFgQUHkRgsMhhV/Qy3C1a7aNS
# UZ5eULcwDQYJKoZIhvcNAQEBBQAEggEAOPjbZ/BRWACRIskNpWXr3M4d92EcXYAf
# XWzmBW0I8+B7gJNTRc1ClqzygCK2XyM1vhIOzJFvABxbJukFwrdc8CJKcJbvX0A2
# XPbmOLxVSX+oS8ri/MqcRgQmwa/sMpD0JiKZPSzfGI+6wrYAp0hcs/XgWF1tUF1Z
# 5CHmzNfKXl6ULi1sF8ofjsFN/70tz+YtH7oYv36HFaajrtwP/+VfOux3eQzalfx9
# RucZNQN7d0O+JRwuHdPRPZLnUvYlwz/dqNKr50GemIOvtl7FNQPyfceJuenbDWJS
# j1fd+86VDk1AqZmYyH6wUpkhuP++8DlHuw3fuGj1+J12yTEBPCwQyg==
# SIG # End signature block
