function Test-Elevated {
  # Get the ID and security principal of the current user account
  $myIdentity = [System.Security.Principal.WindowsIdentity]::GetCurrent()
  $myPrincipal = new-object System.Security.Principal.WindowsPrincipal($myIdentity)
  # Check to see if we are currently running "as Administrator"
  return $myPrincipal.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)
}
function Confirm-Registry($Path) {
  if (!(Test-Path $Path)) {New-Item -Path $Path -Type Folder | Out-Null}
}

# https://github.com/rkeithhill/PoshWinRT
# https://github.com/Sauler/PowershellUtils
function Set-LockscreenWallpaper($Path) {
  $WinRTPath = Get-Item "$PSScriptRoot\wrappers\PoshWinRT.dll"
  Add-Type -Path $WinRTPath
  [Windows.Storage.StorageFile, Windows.Storage, ContentType = WindowsRuntime] > $null
  $asyncOp = [Windows.Storage.StorageFile]::GetFileFromPathAsync($Path)
  $typeName = 'PoshWinRT.AsyncOperationWrapper[Windows.Storage.StorageFile]'
  $wrapper = new-object $typeName -Arg $asyncOp
  $file = $wrapper.AwaitResult()
  [Windows.System.UserProfile.LockScreen, Windows.System.UserProfile, ContentType = WindowsRuntime] > $null
  [Windows.System.UserProfile.LockScreen]::SetImageFileAsync($file) > $null
}

#https://github.com/Sauler/WallpaperSync
function Set-DesktopWallpaper () {
  Param
  (
    [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
    [ValidateScript( {Test-Path $_})] 
    [string]$NewWallpaperPath
  )

  Add-Type @"
  using System;
  using System.Runtime.InteropServices;
  using Microsoft.Win32;
  namespace WallpaperSync
  {
      public enum Style : int
      {
          Tiled,
          Centered,
          Stretched
      }
      public class DesktopWallpaper {
          const int SPI_SETDESKWALLPAPER = 20;
          const int SPIF_UPDATEINIFILE = 0x01;
          const int SPIF_SENDWININICHANGE = 0x02;
          [DllImport("user32.dll", SetLastError = true, CharSet = CharSet.Auto)]
          private static extern int SystemParametersInfo (int uAction, int uParam, string lpvParam, int fuWinIni);
          public static void Set (string path, WallpaperSync.Style style)
          {
              SystemParametersInfo(SPI_SETDESKWALLPAPER, 0, path, SPIF_UPDATEINIFILE | SPIF_SENDWININICHANGE);
              RegistryKey key = Registry.CurrentUser.OpenSubKey("Control Panel\\Desktop", true);
              switch(style)
              {
                  case Style.Stretched:
                      key.SetValue(@"WallpaperStyle", "2") ; 
                      key.SetValue(@"TileWallpaper", "0") ;
                      break;
                  case Style.Centered:
                      key.SetValue(@"WallpaperStyle", "1") ; 
                      key.SetValue(@"TileWallpaper", "0") ; 
                      break;
                  case Style.Tiled:
                      key.SetValue(@"WallpaperStyle", "1") ; 
                      key.SetValue(@"TileWallpaper", "1") ;
                      break;
              }
              key.Close();
          }
      }
  }
"@

  [WallpaperSync.DesktopWallpaper]::Set($NewWallpaperPath, 2);
}