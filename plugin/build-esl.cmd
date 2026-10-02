@echo off
rem Headless build of the ESL variant. Output: build\release\Frostfall.dll (+ .pdb)
setlocal
call "C:\Program Files\Microsoft Visual Studio\18\Community\VC\Auxiliary\Build\vcvars64.bat" >nul || exit /b 1
set VCPKG_ROOT=C:\vcpkg
cd /d "%~dp0"
cmake --preset release-esl || exit /b 1
cmake --build --preset release-esl || exit /b 1
