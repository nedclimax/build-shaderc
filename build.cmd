@echo off
setlocal enabledelayedexpansion
setlocal enableextensions

cd %~dp0

set SHADERC_VERSION=v2024.4

:: -- Check dependencies

where /Q git.exe || (
  echo [ERROR] "git.exe" not found
  exit /b 1
)

where /Q cmake.exe || (
  echo [ERROR] "cmake.exe" not found
  exit /b 1
)

where /Q python.exe || (
  echo [ERROR] "python.exe" not found
  exit /b 1
)

:: -- Check 7-Zip

if exist "%ProgramFiles%\7-Zip\7z.exe" (
  set SZIP="%ProgramFiles%\7-Zip\7z.exe"
) else (
  where /Q 7za.exe || (
    echo [ERROR] 7-Zip installation or "7za.exe" not found
    exit /b 1
  )
  set SZIP=7za.exe
)


:: -- Clone & Build shaderc

git clone --depth=1 --single-branch --no-tags https://github.com/google/shaderc --branch %SHADERC_VERSION%

pushd shaderc

python utils\git-sync-deps
cmake -Bbuild -DCMAKE_BUILD_TYPE=Release
cmake --build build --parallel

:: -- Package shaderc

%SZIP% a -mx=9 shaderc-%SHADERC_VERSION%.zip build

popd

