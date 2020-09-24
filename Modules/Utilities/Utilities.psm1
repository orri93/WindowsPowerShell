function New-GosModuleManifest {
  [CmdletBinding()]
  Param (
    [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true, Position=0)] [string] $Name,
    [Parameter(Mandatory=$false, ValueFromPipelineByPropertyName=$true, Position=1)] [string] $Version,
    [Parameter(Mandatory=$false, ValueFromPipelineByPropertyName=$true, Position=2)] $RequiredModules )

  if($Name) {
    $Private:psd1fn = "$Name.psd1"
    $Private:psm1fn = "$Name.psm1"

    if(-not $Version) {
      $Version = "1.0.0"
    }

    if(Test-Path $Private:psm1fn) {
      if (Test-Path $Private:psd1fn)  {
        "Deleting old $Private:psd1fn"
        Remove-Item $Private:psd1fn
      }
      $manifest = @{
        Path                = "$Private:psd1fn"
        RootModule          = "$Private:psm1fn"
        ModuleVersion       = "$Version"
        Author              = 'Geirmundur Orri Sigurdsson'
        CompanyName         = 'Private'
        Copyright           = '(C) Geirmundur Orri Sigurdsson'
      }
      if($RequiredModules) {
        $manifest.Add('RequiredModules', $RequiredModules)
      }
      "Creating new module manifest for $Name"
      $manifest.GetEnumerator() | ForEach-Object {
        $message = '  {0}: {1}' -f $_.key, $_.value
        Write-Output $message
      }
      New-ModuleManifest @manifest
      "Module manifest $Private:psm1fn created"
    } else {
      "The module file $Private:psm1fn for the $Name module was not found"
    }
  } else {
    "The Name is undefined"
  }
}

function New-GosCodeSign {
  [CmdletBinding()]
  Param (
    [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true, Position=0)] [string] $File,
    [Parameter(Mandatory=$false, ValueFromPipelineByPropertyName=$true, Position=1)] $CertificateIndex 
  )
  if(-not $CertificateIndex) {
    $CertificateIndex = 0
  }
  if(Test-Path -Path $File -PathType Leaf) {
    $Private:signcerts = Get-ChildItem cert:\CurrentUser\My -codesign
    if($Private:signcerts -and $Private:signcerts.count -gt 0) {
      $Private:signcert = $Private:signcerts[$CertificateIndex]
      Set-AuthenticodeSignature -FilePath $File -Certificate $Private:signcert
    } else {
      "A signing certification was not found"
    }
  } else {
    "The file '$File' was not found"
  }
}

function New-GosSignedModuleManifest {
  [CmdletBinding()]
  Param (
    [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true, Position=0)] [string] $Name,
    [Parameter(Mandatory=$false, ValueFromPipelineByPropertyName=$true, Position=1)] [string] $Version,
    [Parameter(Mandatory=$false, ValueFromPipelineByPropertyName=$true, Position=2)] $RequiredModules )
  if($Name) {
    $Private:psm1fn = "$Name.psm1"
    $Private:signature = New-GosCodeSign -File $Private:psm1fn
    if($Private:signature) {
      if($Version) {
        if($RequiredModules) {
          New-GosModuleManifest -Name $Name -Version $Version -RequiredModules $RequiredModules 
        } else {
          New-GosModuleManifest -Name $Name -Version $Version
        }
      } elseif($RequiredModules) {
        New-GosModuleManifest -Name $Name -RequiredModules $RequiredModules
      } else {
        New-GosModuleManifest -Name $Name 
      }
    } else {
      "Failed to sign '$Private:psm1fn'"
    }
  } else {
    "The Name is undefined"
  }
}

function Set-Env {
  [CmdletBinding()]
  Param (
    [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true, Position=0)] [string] $Name,
    [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true, Position=1)] [string] $Value
  )
  Set-Content env:\"$Name" $Value
}

function Remove-Env {
  [CmdletBinding()]
  Param (
    [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true, Position=0)] [string] $Name
  )
  Remove-Item Env:\"$Name"
}

function Get-GosDocumentCertificate {
  Get-ChildItem -Path Cert:\CurrentUser\My -DocumentEncryptionCert
}

function Test-GosDocumentCertificate {
  $Private:GosDocumentCertificate = Get-GosDocumentCertificate
  if($Private:GosDocumentCertificate) {
    $True
  } else {
    "No Document Encryption Certificate found"
    $False
  }
}

function Get-GosProtect {
  [CmdletBinding()] Param (
  [parameter(ValueFromPipeline)] [string] $PipelineContent,
  [Parameter(Mandatory=$false, ValueFromPipelineByPropertyName=$true, Position=0)] [string] $Content)
  if(-not $Content) {
    $Content = $PipelineContent
  }
  if($Content) {
    $GosDocumentCertificate = Get-GosDocumentCertificate
    if($GosDocumentCertificate) {
      Protect-CmsMessage -To $GosDocumentCertificate -Content $Content
    }
  }
}

function Get-GosUnprotect {
  [CmdletBinding()] Param (
  [parameter(ValueFromPipeline)] [string] $PipelineContent,
  [Parameter(Mandatory=$false, ValueFromPipelineByPropertyName=$true, Position=0)] [string] $Content)
  if(-not $Content) {
    $Content = $PipelineContent
  }
  if($Content) {
    $GosDocumentCertificate = Get-GosDocumentCertificate
    if($GosDocumentCertificate) {
      $Content | Unprotect-CmsMessage -To $GosDocumentCertificate
    }
  }
}

function Get-Configuration {
  [CmdletBinding()] Param (
    [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true, Position=0)] [string] $Section,
    [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true, Position=1)] [string] $Category,
    [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true, Position=2)] [string] $Name)
  $Private:UserProfile = ${env:USERPROFILE}
  if($Private:UserProfile) {
    $Private:configurationPath = Join-Path -Path $Private:UserProfile -ChildPath "Documents/WindowsPowerShell/Configuration.json" -Resolve
    if(Test-Path $Private:configurationPath) {
      $Private:configurationJson = Get-Content -Raw -Path $Private:configurationPath | ConvertFrom-Json
      if($Private:configurationJson) {
        $Private:configuration = $Private:configurationJson.configuration
        if($Private:configuration) {
          $Private:jsonsection = $Private:configuration.$Section
          if($Private:jsonsection) {
            $Private:jsoncategory = $Private:jsonsection.$Category
            if($Private:jsoncategory) {
              $Private:element = $Private:jsoncategory.$Name
              if($Private:element) { 
                  $Private:element
              } else {
                "The '$Category' object in the $Private:configurationPath file did not contain a '$Name' element"
              }
            } else {
              "The '$Section' object in the $Private:configurationPath file did not contain a '$Category' object"
            }
          } else {
            "The 'configuration' object in the $Private:configurationPath file did not contain a '$Section' object"
          }
        } else {
          "The $Private:configurationPath file did not contain a 'configuration' object"
        }
      } else {
        "The $Private:configurationPath file was not parsed as json"
      }
    } else {
      "No configuration file found at $Private:configurationPath"
    }
  } else {
    "User Profile defined"
  }
}

function Get-Secret {
  [CmdletBinding()] Param (
    [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true, Position=0)] [string] $Section,
    [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true, Position=1)] [string] $Category,
    [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true, Position=2)] [string] $Name,
    [Parameter(Mandatory=$false, ValueFromPipelineByPropertyName=$true, Position=3)] [string] $Type)
  $Private:UserProfile = ${env:USERPROFILE}
  if($Private:UserProfile) {
    $Private:secretPath = Join-Path -Path $Private:UserProfile -ChildPath "Documents/WindowsPowerShell/Secret.json" -Resolve
    if(Test-Path $Private:secretPath) {
      $Private:secretJson = Get-Content -Raw -Path $Private:secretPath | ConvertFrom-Json
      if($Private:secretJson) {
        $Private:secret = $Private:secretJson.secret
        if($Private:secret) {
          $Private:jsonsection = $Private:secret.$Section
          if($Private:jsonsection) {
            $Private:jsoncategory = $Private:jsonsection.$Category
            if($Private:jsoncategory) {
              $Private:element = $Private:jsoncategory.$Name
              if($Private:element) { 
                if($Type -eq "password") {
                  $Private:element | Get-GosUnprotect
                } else {
                  $Private:element
                }
              } else {
                "The '$Category' object in the $Private:secretPath file did not contain a '$Name' element"
              }
            } else {
              "The '$Section' object in the $Private:secretPath file did not contain a '$Category' object"
            }
          } else {
            "The 'secret' object in the $Private:secretPath file did not contain a '$Section' object"
          }
        } else {
          "The $Private:secretPath file did not contain a 'secret' object"
        }
      } else {
        "The $Private:secretPath file was not parsed as json"
      }
    } else {
      "No secret file found at $Private:secretPath"
    }
  } else {
    "User Profile defined"
  }
}

function Find-Path {
  [CmdletBinding()] Param (
    [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true, Position=0)] $Path
  )
  if($Path -is [array]) { $Paths = $Path } else { $Paths = ($Path) }
  ${env:PATH} -split ";" | ForEach-Object -Process {
    if($Paths -eq $_) {
      $_
    }
  }
}

function Add-Path {
  [CmdletBinding()] Param (
    [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true, Position=0)] $Path
  )
  if($Path -is [array]) { $Paths = $Path } else { $Paths = ($Path) }
  $Postfix = ("",";")[${env:PATH} -match ';$']
  $Checked = @()
  ForEach($Pa in $Paths) {
    if(-not (Find-Path $Pa)) {
      if(Test-Path -Path $Pa -PathType Container) { 
        $Checked += $Pa
        "Adding '$Pa' to PATH"
      } else {
        "Not adding '$Pa' to PATH as it is not valid" 
      }
    }
  }
  if(-not $Postfix) {
    ${env:PATH} += ";"
  }
  ${env:PATH} += $Checked -join ";"
  ${env:PATH} += $Postfix
}

function Remove-Path {
  [CmdletBinding()] Param (
    [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true, Position=0)] $Path
  )
  if($Path -is [array]) { $Paths = $Path } else { $Paths = ($Path) }
  $Replaced = @()
  ForEach($Pa in $Paths) {
    if($Pa -match '\\$') {
      $Replaced += $Pa.Substring(0, $Pa.length - 1)
    }
  }
  $Postfix = ("",";")[${env:PATH} -match ';$']
  $NewPath = @()
  ${env:PATH} -split ";" | ForEach-Object -Process {
    $Pam = $_
    if($Pam.length -gt 0) {
      $Pam = ($_, $_.Substring(0, $_.length - 1))[$_ -match '\\$']
    }
    if($Replaced -eq $Pam) {
      "Removing '$Pam' from PATH"
    } else {
      $NewPath += $_ 
    }
  }
  ${env:PATH} = $NewPath -join ";"
  ${env:PATH} += $Postfix
}

function Find-Folders {
  [CmdletBinding()] Param (
    [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true, Position=0)]  $Name,
    [Parameter(Mandatory=$false, ValueFromPipelineByPropertyName=$true, Position=1)] $Path
  )
  if(-not $Path) { $Path = ".\" }
  Get-ChildItem -Path $Path -Filter $Name -ErrorAction SilentlyContinue -Recurse -Directory -Force | ForEach-Object {
    $_.FullName
  }
}

function Remove-Folders {
  [CmdletBinding()] Param (
    [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true, Position=0)]  $Name,
    [Parameter(Mandatory=$false, ValueFromPipelineByPropertyName=$true, Position=1)] $Path
  )
  if(-not $Path) { $Path = ".\" }
  Get-ChildItem -Path $Path -Filter $Name -ErrorAction SilentlyContinue -Recurse -Directory -Force | ForEach-Object {
    Remove-Item -Path $_.FullName -Recurse -Force
  }
}

function Find-Files {
  [CmdletBinding()] Param (
    [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true, Position=0)]  $Name,
    [Parameter(Mandatory=$false, ValueFromPipelineByPropertyName=$true, Position=1)] $Path
  )
  if(-not $Path) { $Path = ".\" }
  Get-ChildItem -Path $Path -Filter $Name -ErrorAction SilentlyContinue -Recurse -File -Force | ForEach-Object {
    $_.FullName
  }
}

function Remove-Files {
  [CmdletBinding()] Param (
    [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true, Position=0)]  $Name,
    [Parameter(Mandatory=$false, ValueFromPipelineByPropertyName=$true, Position=1)] $Path
  )
  if(-not $Path) { $Path = ".\" }
  Get-ChildItem -Path $Path -Filter $Name -ErrorAction SilentlyContinue -Recurse -File -Force | ForEach-Object {
    Remove-Item -Path $_.FullName -Recurse -Force
  }
}

Export-ModuleMember -Function 'New-GosModuleManifest'
Export-ModuleMember -Function 'New-GosCodeSign'
Export-ModuleMember -Function 'New-GosSignedModuleManifest'
Export-ModuleMember -Function 'Set-Env'
Export-ModuleMember -Function 'Remove-Env'
Export-ModuleMember -Function 'Test-GosDocumentCertificate'
Export-ModuleMember -Function 'Get-GosDocumentCertificate'
Export-ModuleMember -Function 'Get-GosProtect'
Export-ModuleMember -Function 'Get-GosUnprotect'
Export-ModuleMember -Function 'Get-Configuration'
Export-ModuleMember -Function 'Get-Secret'
Export-ModuleMember -Function 'Find-Path'
Export-ModuleMember -Function 'Add-Path'
Export-ModuleMember -Function 'Remove-Path'
Export-ModuleMember -Function 'Find-Folders'
Export-ModuleMember -Function 'Remove-Folders'
Export-ModuleMember -Function 'Find-Files'
Export-ModuleMember -Function 'Remove-Files'

# SIG # Begin signature block
# MIIFxAYJKoZIhvcNAQcCoIIFtTCCBbECAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUZSXsR74ry3RIfNQxjAej6Pc4
# AAugggNJMIIDRTCCAjGgAwIBAgIQHkBq4ZZ1t79B2x69CojztDAJBgUrDgMCHQUA
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
# MQ4wDAYKKwYBBAGCNwIBFTAjBgkqhkiG9w0BCQQxFgQUseyshN2VMSOeMg/uGyGn
# h9gnJTswDQYJKoZIhvcNAQEBBQAEggEAAxoXWIFJoy52pLFBcBF12WpZ7JYRUMc8
# P6MLA+g+DjAewPkmyZJjuFCSALw2bfNefzhjYapHYDdKyJdoOzmevTMBC7aM9NE6
# FStT7Uo9f3D/gtJthLER6zc3Ej8EaK016dKxVjePWJpFe/mf+QgWVJhONCr8KtDA
# FW2O2eqDB2UIgtFRXnUOusGo8damoHGSTaAPYPjjgL9xnJrdZrHppZwWvzsPEsgp
# Cvl7XgcZPGxpHj0AC0IRQqCEHyaljUYiW2oL8v3Q9UrFCx78zadbjDR3MrQN/u0S
# WrWYt9Rh1hdLIRkELQZ6s1ggpA20e7SfSuzYFnxQ1D1o0Be7YRZAPw==
# SIG # End signature block
