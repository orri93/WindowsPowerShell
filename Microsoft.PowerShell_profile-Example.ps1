# Maximum Width is 274
# Maximum height is 85
$Private:shellwidth = 274 / 2
$Private:shellheight = 60
$Private:shellbuffer = 6 * 1024

$Shell = $Host.UI.RawUI

$Shell.WindowTitle="PowerShell with <Name>`'s profile"

$size = $Shell.BufferSize
$size.width=$Private:shellwidth
$size.height=$Private:shellbuffer
$Shell.BufferSize = $size

$size = $Shell.WindowSize
$size.width=$Private:shellwidth
$size.height=$Private:shellheight
$Shell.WindowSize = $size

#e$Shell.BackgroundColor = "0arkBlue"
$Shell.ForegroundColor = "Gray"

#
# Script root for V >= 3 and V < 3
#

#if($PSVersionTable.PSVersion.Major -ge 3) {
#  $Private:pscl = split-path -parent $MyInvocation.MyCommand.Definition
#} else {
#  $Private:pscl = $PSScriptRoot
#}
#"Profile script location is $Private:pscl"

function Invoke-Profile { . $profile }
function Show-GosProfile {
  ""
  "PowerShell Profile for <Full Name>"
  ""
  "To disable automatically loading this profile run PowerShell with the NoProfile option:"
  "  > powershell.exe -NoProfile"
  ""
  "Modules"
  Get-ChildItem -Path (Join-Path -Path $PSScriptRoot -ChildPath Modules) `
    -Recurse -Directory -Force -ErrorAction SilentlyContinue | ForEach-Object -Process {
    $modulemessage = '  {0}' -f $_.Name
    Write-Host $modulemessage
  }
  ""
  "For information about each module use Show-GosHelp -Module <string>"
  "For information about all modules use Show-GosHelp -Module All"
}

#Clear-Host

Show-GosProfile
