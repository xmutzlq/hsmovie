param(
  [string]$FlutterRoot = 'D:\Flutter\sdk\flutter',
  [string]$PubCache = 'D:\Flutter\flutter_cache',
  [string]$ToolchainRoot = 'D:\Flutter\windows_toolchain\w64devkit',
  [string]$AndroidSdk = 'D:\Android\Sdk',
  [switch]$Run
)

$ErrorActionPreference = 'Stop'
$project = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$ephemeral = Join-Path $project 'windows\flutter\ephemeral'
$pluginRoot = Join-Path $ephemeral '.plugin_symlinks'
$buildDir = Join-Path $project 'build\windows\mingw'
$releaseDir = Join-Path $project 'build\windows\x64\runner\Release'
$appName = -join @(
  [char]0x6D6E, [char]0x5149, [char]0x63A0, [char]0x5F71
)
$appExecutable = "$appName.exe"
$cmake = Join-Path $AndroidSdk 'cmake\3.31.5\bin\cmake.exe'
$ninja = Join-Path $AndroidSdk 'cmake\3.31.5\bin\ninja.exe'
$gccBin = Join-Path $ToolchainRoot 'bin'
$flutter = Join-Path $FlutterRoot 'bin\flutter.bat'
$backend = Join-Path $FlutterRoot 'packages\flutter_tools\bin\tool_backend.bat'
$engine = Join-Path $FlutterRoot 'bin\cache\artifacts\engine\windows-x64-release'
$engineCommon = Join-Path $FlutterRoot 'bin\cache\artifacts\engine\windows-x64'

function Set-GeneratedText([string]$Path, [string]$Value, [System.Text.Encoding]$Encoding) {
  $resolvedPath = if ([System.IO.Path]::IsPathRooted($Path)) { $Path } else { Join-Path $project $Path }
  for ($attempt = 1; $attempt -le 10; $attempt++) {
    try {
      [System.IO.File]::WriteAllText($resolvedPath, $Value, $Encoding)
      return
    } catch [System.IO.IOException] {
      if ($attempt -eq 10) { throw }
      Start-Sleep -Milliseconds 500
    }
  }
}

@($flutter, $backend, $cmake, $ninja, (Join-Path $gccBin 'g++.exe')) |
  ForEach-Object { if (-not (Test-Path -LiteralPath $_)) { throw "Missing prerequisite: $_" } }

$env:PUB_CACHE = $PubCache
$env:TEMP = Join-Path $PubCache 'tmp'
$env:TMP = $env:TEMP
$env:APPDATA = Join-Path $PubCache 'appdata\roaming'
$env:LOCALAPPDATA = Join-Path $PubCache 'appdata\local'
$env:FLUTTER_ROOT = $FlutterRoot
$env:PROJECT_DIR = $project
$env:FLUTTER_EPHEMERAL_DIR = $ephemeral
$env:FLUTTER_TARGET = 'lib\main.dart'
$env:DART_OBFUSCATION = 'false'
$env:DART_SUPPRESS_ANALYTICS = 'true'
$env:FLUTTER_SUPPRESS_ANALYTICS = 'true'
$env:TRACK_WIDGET_CREATION = 'true'
$env:TREE_SHAKE_ICONS = 'true'
$env:PACKAGE_CONFIG = Join-Path $project '.dart_tool\package_config.json'
$env:Path = "$gccBin;$(Split-Path $cmake);$env:Path"
New-Item -ItemType Directory -Force -Path `
  $env:TEMP, $env:APPDATA, $env:LOCALAPPDATA, $ephemeral, $pluginRoot | Out-Null

Push-Location $project
try {
  & $flutter pub get
  if ($LASTEXITCODE -ne 0) { throw 'flutter pub get failed' }

  $pubspec = Get-Content -LiteralPath 'pubspec.yaml' -Raw
  $version = [regex]::Match($pubspec, '(?m)^version:\s*([^\s]+)').Groups[1].Value
  if (-not $version) { throw 'pubspec.yaml version is missing' }
  $versionHeader = @"
#ifndef HSMOVIE_USER_BUILD_VERSION_H_
#define HSMOVIE_USER_BUILD_VERSION_H_

#define HSMOVIE_VERSION_AS_STRING "$version\0"

#endif  // HSMOVIE_USER_BUILD_VERSION_H_
"@
  Set-GeneratedText 'windows\runner\user_build_version.h' $versionHeader `
    ([System.Text.Encoding]::ASCII)

  $dependencies = Get-Content -LiteralPath '.flutter-plugins-dependencies' -Raw |
    ConvertFrom-Json
  $wanted = @('connectivity_plus', 'media_kit_libs_windows_video', 'media_kit_video')
  foreach ($name in $wanted) {
    $plugin = $dependencies.plugins.windows | Where-Object name -eq $name |
      Select-Object -First 1
    if (-not $plugin) { throw "Windows plugin not found: $name" }
    $destination = Join-Path $pluginRoot $name
    if (Test-Path -LiteralPath $destination) {
      Remove-Item -LiteralPath $destination -Recurse -Force
    }
    Copy-Item -LiteralPath $plugin.path -Destination $destination -Recurse
  }

  Copy-Item -LiteralPath (Join-Path $engine 'flutter_windows.dll') -Destination $ephemeral -Force
  Copy-Item -LiteralPath (Join-Path $engine 'flutter_windows.dll.lib') -Destination $ephemeral -Force
  Copy-Item -Path (Join-Path $engine 'flutter_*.h') -Destination $ephemeral -Force
  $wrapperDestination = Join-Path $ephemeral 'cpp_client_wrapper'
  if (Test-Path -LiteralPath $wrapperDestination) {
    Remove-Item -LiteralPath $wrapperDestination -Recurse -Force
  }
  Copy-Item -LiteralPath (Join-Path $engineCommon 'cpp_client_wrapper') -Destination $ephemeral -Recurse -Force
  Copy-Item -LiteralPath (Join-Path $engineCommon 'icudtl.dat') -Destination $ephemeral -Force

  $eventChannel = Join-Path $ephemeral 'cpp_client_wrapper\include\flutter\event_channel.h'
  $eventText = Get-Content -LiteralPath $eventChannel -Raw
  $eventText = $eventText -replace 
    '<< \(error->error_message\) << ", "\s*<< \(error->error_details\);',
    '<< (error->error_message);'
  Set-GeneratedText $eventChannel $eventText ([System.Text.UTF8Encoding]::new($false))

  $connectivity = Join-Path $pluginRoot 'connectivity_plus\windows\network_manager.cpp'
  $connectivityText = Get-Content -LiteralPath $connectivity -Raw
  if ($connectivityText -notmatch '#include <algorithm>') {
    $connectivityText = $connectivityText.Replace('#include <cassert>', "#include <algorithm>`r`n#include <cassert>")
    Set-GeneratedText $connectivity $connectivityText ([System.Text.UTF8Encoding]::new($false))
  }

  $mediaWindows = Join-Path $pluginRoot 'media_kit_video\windows'
  $angleHeader = Join-Path $mediaWindows 'angle_surface_manager.h'
  $angleText = (Get-Content -LiteralPath $angleHeader -Raw) -replace '#include <d3d\.h>\r?\n', ''
  Set-GeneratedText $angleHeader $angleText ([System.Text.UTF8Encoding]::new($false))
  $threadPool = Join-Path $mediaWindows 'thread_pool.h'
  $threadText = (Get-Content -LiteralPath $threadPool -Raw).Replace(
    '::SetThreadPriority(workers_.back().native_handle(),',
    '::SetThreadPriority(reinterpret_cast<HANDLE>(workers_.back().native_handle()),')
  Set-GeneratedText $threadPool $threadText ([System.Text.UTF8Encoding]::new($false))
  $videoOutput = Join-Path $mediaWindows 'video_output.cc'
  $videoText = Get-Content -LiteralPath $videoOutput -Raw
  $videoText = $videoText.Replace(
    '{MPV_RENDER_PARAM_API_TYPE, MPV_RENDER_API_TYPE_OPENGL}',
    '{MPV_RENDER_PARAM_API_TYPE, const_cast<char*>(MPV_RENDER_API_TYPE_OPENGL)}')
  $videoText = $videoText.Replace(
    '{MPV_RENDER_PARAM_API_TYPE, MPV_RENDER_API_TYPE_SW}',
    '{MPV_RENDER_PARAM_API_TYPE, const_cast<char*>(MPV_RENDER_API_TYPE_SW)}')
  $videoText = $videoText.Replace(
    '{MPV_RENDER_PARAM_SW_FORMAT, "rgb0"}',
    '{MPV_RENDER_PARAM_SW_FORMAT, const_cast<char*>("rgb0")}')
  Set-GeneratedText $videoOutput $videoText ([System.Text.UTF8Encoding]::new($false))
  $mediaCmake = Join-Path $mediaWindows 'CMakeLists.txt'
  $mediaCmakeText = Get-Content -LiteralPath $mediaCmake -Raw
  if ($mediaCmakeText -notmatch 'PRIVATE d3d11 dxgi') {
    $mediaCmakeText = $mediaCmakeText -replace
      '("\$\{ANGLE_SRC\}/lib/libGLESv2\.dll\.lib"\s*\))',
      "`$1`r`n  if(NOT MSVC)`r`n    target_link_libraries(`${PLUGIN_NAME} PRIVATE d3d11 dxgi)`r`n  endif()"
    Set-GeneratedText $mediaCmake $mediaCmakeText ([System.Text.UTF8Encoding]::new($false))
  }

  $versionParts = $version.Split('+')[0].Split('.')
  while ($versionParts.Count -lt 3) { $versionParts += '0' }
  $buildNumber = if ($version.Contains('+')) { $version.Split('+')[1] } else { '0' }
  $cmakeFlutterRoot = $FlutterRoot.Replace('\', '/')
  $cmakeProject = $project.Replace('\', '/')
  $generatedConfig = @"
# Generated by tool/build_windows_user.ps1.
file(TO_CMAKE_PATH "$cmakeFlutterRoot" FLUTTER_ROOT)
file(TO_CMAKE_PATH "$cmakeProject" PROJECT_DIR)
set(FLUTTER_VERSION "$version" PARENT_SCOPE)
set(FLUTTER_VERSION_MAJOR $($versionParts[0]) PARENT_SCOPE)
set(FLUTTER_VERSION_MINOR $($versionParts[1]) PARENT_SCOPE)
set(FLUTTER_VERSION_PATCH $($versionParts[2]) PARENT_SCOPE)
set(FLUTTER_VERSION_BUILD $buildNumber PARENT_SCOPE)
set(FLUTTER_TARGET_PLATFORM "windows-x64")
"@
  Set-GeneratedText (Join-Path $ephemeral 'generated_config.cmake') `
    $generatedConfig ([System.Text.Encoding]::ASCII)
  & $backend windows-x64 Release
  if ($LASTEXITCODE -ne 0) { throw 'Flutter Release AOT assembly failed' }

  $cmakeArgs = @(
    '-S', 'windows', '-B', $buildDir, '-G', 'Ninja',
    '-DCMAKE_BUILD_TYPE=Release',
    '-DHSMOVIE_USE_PREASSEMBLED_FLUTTER=ON',
    '-DCMAKE_CXX_COMPILER=g++.exe',
    '-DCMAKE_RC_COMPILER=windres.exe',
    "-DCMAKE_MAKE_PROGRAM=$ninja"
  )
  & $cmake @cmakeArgs
  if ($LASTEXITCODE -ne 0) { throw 'CMake configuration failed' }

  $extractTargets = @()
  if (-not (Test-Path -LiteralPath (Join-Path $buildDir 'libmpv\libmpv.dll.a'))) {
    $extractTargets += 'media_kit_libs_windows_video_LIBMPV_EXTRACT'
  }
  if (-not (Test-Path -LiteralPath (Join-Path $buildDir 'ANGLE\lib\libEGL.dll.lib'))) {
    $extractTargets += 'media_kit_libs_windows_video_ANGLE_EXTRACT'
  }
  if ($extractTargets.Count -gt 0) {
    & $ninja -C $buildDir $extractTargets
    if ($LASTEXITCODE -ne 0) { throw 'media_kit extraction failed' }
  }
  & $ninja -C $buildDir
  if ($LASTEXITCODE -ne 0) { throw 'Ninja compilation failed' }

  New-Item -ItemType Directory -Force -Path $releaseDir, (Join-Path $releaseDir 'data') | Out-Null
  Get-ChildItem -LiteralPath $releaseDir -Filter '*.exe' -File |
    Where-Object Name -CNE $appExecutable |
    Remove-Item -Force
  Copy-Item -LiteralPath (Join-Path $buildDir 'runner\ble_project.exe') `
    -Destination (Join-Path $releaseDir $appExecutable) -Force
  Copy-Item -LiteralPath (Join-Path $ephemeral 'flutter_windows.dll') -Destination $releaseDir -Force
  @(
    'plugins\connectivity_plus\libconnectivity_plus_plugin.dll',
    'plugins\media_kit_libs_windows_video\libmedia_kit_libs_windows_video_plugin.dll',
    'plugins\media_kit_video\libmedia_kit_video_plugin.dll',
    'libmpv\libmpv-2.dll',
    'ANGLE\d3dcompiler_47.dll', 'ANGLE\libc++.dll', 'ANGLE\libEGL.dll',
    'ANGLE\libGLESv2.dll', 'ANGLE\vk_swiftshader.dll', 'ANGLE\vulkan-1.dll',
    'ANGLE\zlib.dll'
  ) | ForEach-Object {
    Copy-Item -LiteralPath (Join-Path $buildDir $_) -Destination $releaseDir -Force
  }
  Copy-Item -LiteralPath (Join-Path $ephemeral 'icudtl.dat') `
    -Destination (Join-Path $releaseDir 'data') -Force
  Copy-Item -LiteralPath 'build\windows\app.so' `
    -Destination (Join-Path $releaseDir 'data') -Force
  Copy-Item -LiteralPath 'build\flutter_assets' `
    -Destination (Join-Path $releaseDir 'data') -Recurse -Force
  if (Test-Path -LiteralPath 'build\native_assets\windows') {
    Copy-Item -Path 'build\native_assets\windows\*' `
      -Destination $releaseDir -Recurse -Force
  }
  $aiRelease = Join-Path $releaseDir 'ai'
  if (Test-Path -LiteralPath $aiRelease) {
    Remove-Item -LiteralPath $aiRelease -Recurse -Force
  }

  Write-Host "Windows release: $releaseDir"
  if ($Run) {
    Start-Process -FilePath (Join-Path $releaseDir $appExecutable) `
      -WorkingDirectory $releaseDir
  }
} finally {
  Pop-Location
}
