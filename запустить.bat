@echo off
chcp 65001 >nul
title ZholTap - zapusk
cd /d "%~dp0"

rem --- ishchem Flutter: snachala v PATH, potom v papke polzovatelya ---
set "FLUTTER=flutter"
where flutter >nul 2>nul
if errorlevel 1 set "FLUTTER=%USERPROFILE%\flutter\bin\flutter.bat"
if not "%FLUTTER%"=="flutter" if not exist "%FLUTTER%" (
  echo Flutter ne najden. Ustanovite ego po instrukcii prepodavatelya.
  pause
  exit /b 1
)

rem --- pervyj zapusk: sozdat proekt ---
if not exist "zholtap\pubspec.yaml" (
  echo Sozdayu proekt zholtap, pervyj raz eto zanimaet 1-3 minuty...
  call "%FLUTTER%" create zholtap
  if errorlevel 1 goto oshibka
)

rem --- kladem moj main.dart v proekt ---
copy /Y "main.dart" "zholtap\lib\main.dart" >nul
if errorlevel 1 goto oshibka

cd zholtap
call "%FLUTTER%" config --enable-web >nul
echo.
echo Zapuskayu ZholTap v Chrome. Chtoby ostanovit: nazhmite q v etom okne.
echo.
call "%FLUTTER%" run -d chrome
pause
exit /b 0

:oshibka
echo.
echo Chto-to poshlo ne tak. Sfotografirujte eto okno i prishlite.
pause
exit /b 1
