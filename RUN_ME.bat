@echo off
setlocal EnableDelayedExpansion

title Golden Returns -- Lab Setup

echo.
echo  ============================================================
echo   GOLDEN RETURNS -- Cyber Crime Training Lab Setup
echo   Double-click this file on ANY Windows machine to start.
echo  ============================================================
echo.

REM ---- Locate Deploy.ps1 (handles double-ZIP extraction) ----
set "DEPLOY="

if exist "%~dp0Deploy.ps1"                                      set "DEPLOY=%~dp0Deploy.ps1"
if not defined DEPLOY (
  if exist "%~dp0call-center-scam-main\Deploy.ps1"              set "DEPLOY=%~dp0call-center-scam-main\Deploy.ps1"
)
if not defined DEPLOY (
  for /r "%~dp0" %%F in (Deploy.ps1) do (
    if not defined DEPLOY set "DEPLOY=%%F"
  )
)

if not defined DEPLOY (
  echo  ERROR: Cannot find Deploy.ps1
  echo  Make sure you are running this from INSIDE the extracted folder.
  echo  Expected structure:
  echo    call-center-scam-main\
  echo      Deploy.ps1         ^<-- this file must exist
  echo      scripts\
  echo      RUN_ME.bat         ^<-- you are here
  echo.
  pause
  exit /b 1
)

echo  Found Deploy.ps1 at:
echo    %DEPLOY%
echo.

REM ---- Check for admin rights ----
net session >nul 2>&1
if %errorlevel% neq 0 (
  echo  Requesting Administrator privileges...
  powershell -Command "Start-Process cmd -ArgumentList '/c \"%~f0\"' -Verb RunAs"
  exit /b
)

echo  [OK] Running as Administrator
echo.

REM ---- Set execution policy and run ----
powershell -ExecutionPolicy Bypass -NoProfile -Command ^
  "& { $ErrorActionPreference='Continue'; & '%DEPLOY%' }"

echo.
echo  Setup complete. Check C:\GR_LabSetup\setup.log for details.
pause
