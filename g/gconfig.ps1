$configPath = "$env:USERPROFILE/.gconfig"

$bookmarks = @{
  "dev"  = "C:\Dev";
  "home" = $env:USERPROFILE
}

$existingConfig = Get-Content $configPath
if ($existingConfig) {
  foreach ($item in $existingConfig) {
    $keys = $item.Split("|")
    if ($bookmarks.ContainsKey($keys[0])) {
      $bookmarks.Item($keys[0]) = $keys[1]
    }
    else {
      $bookmarks.Add($keys[0], $keys[1])
    }
  }
}

$bookmarks.Keys | ForEach-Object { "$_|" + $bookmarks.Item($_) } | Out-File $configPath