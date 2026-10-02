@echo off
rem Headless build. Output: build\release\Frostfall.dll (+ .pdb)
setlocal
call "C:\Program Files\Microsoft Visual Studio\18\Community\VC\Auxiliary\Build\vcvars64.bat" >nul || exit /b 1
set VCPKG_ROOT=C:\vcpkg
cd /d "%~dp0"
cmake --preset release || exit /b 1
cmake --build --preset release || exit /b 1
