
# Import utility functions
. "$PSScriptRoot\util.ps1"

# Check to see if we are currently running "as Administrator"
if (!(Test-Elevated)) {
  $newProcess = new-object System.Diagnostics.ProcessStartInfo "PowerShell"
  $newProcess.Arguments = $myInvocation.MyCommand.Definition;
  $newProcess.Verb = "runas";
  [System.Diagnostics.Process]::Start($newProcess)
  exit
}


Set-LockscreenWallpaper("$PSScriptRoot\login.jpg")



