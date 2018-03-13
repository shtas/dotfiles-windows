
# Import utility functions
. "$PSScriptRoot\util.ps1"

# Check to see if we are currently running "as Administrator"
if (!(Test-Elevated)) {
  $newProcess = new-object System.Diagnostics.ProcessStartInfo "PowerShell";
  $newProcess.Arguments = $myInvocation.MyCommand.Definition;
  $newProcess.Verb = "runas";
  [System.Diagnostics.Process]::Start($newProcess) > $null
  exit
} else {
  Write-Host "Updating settings..." -ForegroundColor "DarkCyan"
}


# RemoteSigned 
Set-ExecutionPolicy RemoteSigned -scope CurrentUser

# Enable Developer Mode
Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" "AllowDevelopmentWithoutDevLicense" 1

# Bash on Windows
if ((Get-WindowsOptionalFeature -Online -FeatureName "Microsoft-Windows-Subsystem-Linux").State -ne "Enabled") {
  Enable-WindowsOptionalFeature -Online -All -FeatureName "Microsoft-Windows-Subsystem-Linux" -NoRestart -WarningAction SilentlyContinue | Out-Null
}

# Sound: Disable Startup Sound
Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" "DisableStartupSound" 1
Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\LogonUI\BootAnimation" "DisableStartupSound" 1

# Test registry paths for explorer and taskbar settings
Confirm-Registry -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer"
Confirm-Registry -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\CabinetState"
Confirm-Registry -Path "HKLM:\Software\Policies\Microsoft\Windows\Windows Search"

# Explorer: Show file extensions by default
Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "HideFileExt" 0

# Explorer: Show path in title bar
Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\CabinetState" "FullPath" 1

# Explorer: Avoid creating Thumbs.db files on network volumes
Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" "DisableThumbnailsOnNetworkFolders" 1

# Taskbar: Don't show Windows Store Apps on Taskbar
Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "StoreAppsOnTaskbar" 0

# Taskbar: Disable Bing Search
Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" "BingSearchEnabled" 0

# Taskbar: Show colors on Taskbar, Start, and SysTray: Disabled: 0, Taskbar, Start, & SysTray: 1, Taskbar Only: 2
Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" "ColorPrevalence" 1

# Recycle Bin: Disable Delete Confirmation Dialog
Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" "ConfirmFileDelete" 0

# Lock screen backgrund
Set-LockscreenWallpaper -Path "$PSScriptRoot\img\login.jpg"

# Wallpaper
Set-DesktopWallpaper -NewWallpaperPath "$PSScriptRoot\img\wallpaper.jpg"

#Internet explorer
# Set home page to `about:blank` for faster loading
Set-ItemProperty "HKCU:\Software\Microsoft\Internet Explorer\Main" "Start Page" "about:blank"

# Disable 'Default Browser' check: "yes" or "no"
Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Internet Explorer\Main" "Check_Associations" "no"

# Disable Password Caching [Disable Remember Password]
Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings" "DisablePasswordCaching" 1

# Install scoop
if (-not (Get-Command scoop -errorAction SilentlyContinue))
{
  Invoke-Expression (new-object net.webclient).downloadstring('https://get.scoop.sh')
}

# Install concfg
if (-not (Get-Command concfg -errorAction SilentlyContinue))
{
  scoop install concfg
}

# Import concfg preset
concfg clean
concfg import "$PSScriptRoot\concfg\shtas.json" --non-interactive

# Install pshazz
if (-not (Get-Command pshazz -errorAction SilentlyContinue))
{
  scoop install pshazz
}

# Symlink pshazz theme
New-Item -ItemType SymbolicLink -Path "$env:USERPROFILE\pshazz" -Name "shtas.json" -Target "$PSScriptRoot\pshazz\shtas.json" -Force > $null
New-Item -ItemType SymbolicLink -Path "$env:USERPROFILE" -Name ".pshazz" -Target "$PSScriptRoot\pshazz\.pshazz" -Force > $null


# Update g config
. "$PSScriptRoot\g\gconfig.ps1"

# Install chocolatey
if (-not (Get-Command choco -errorAction SilentlyContinue))
{
  Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
}

# Install Git
if (-not (Get-Command git -errorAction SilentlyContinue))
{
  choco install git -y
}


Write-Host "Done. Press any key to close." -ForegroundColor "DarkCyan"
[void][System.Console]::ReadKey($true)

