@echo off
chcp 65001 >nul
title ZholTap - dlya iPhone
cd /d "%~dp0"

rem --- ishchem Flutter ---
set "FLUTTER=flutter"
where flutter >nul 2>nul
if errorlevel 1 set "FLUTTER=%USERPROFILE%\flutter\bin\flutter.bat"
if not "%FLUTTER%"=="flutter" if not exist "%FLUTTER%" (
  echo Flutter ne najden. Ustanovite ego po instrukcii prepodavatelya.
  pause
  exit /b 1
)

rem --- pervyj zapusk: sozdat web-proekt ---
if not exist "zholtap_web\pubspec.yaml" (
  echo Sozdayu proekt zholtap_web, pervyj raz eto 1-3 minuty...
  call "%FLUTTER%" create --platforms=web --project-name zholtap zholtap_web
  if errorlevel 1 goto oshibka
  powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0iphone_nastroika.ps1"
)
copy /Y "main.dart" "zholtap_web\lib\main.dart" >nul
if errorlevel 1 goto oshibka
cd zholtap_web
call "%FLUTTER%" config --enable-web >nul

echo.
echo ============================================================
echo  1. iPhone i etot komp'yuter dolzhny byt' v ODNOJ Wi-Fi seti.
echo  2. Na iPhone otkrojte Safari i vvedite odin iz adresov:
for /f "tokens=2 delims=:" %%a in ('ipconfig ^| findstr /c:"IPv4"') do (
  for /f "tokens=* delims= " %%b in ("%%a") do echo         http://%%b:8080
)
echo  3. V Safari: knopka "Podelit'sya" - "Na ekran Domoj".
echo     Poyavitsya ikonka ZholTap, otkryvaetsya kak prilozhenie.
echo  Esli Windows sprosit pro brandmauer - nazhmite "Razreshit'".
echo  Okno ne zakryvajte, poka pol'zuetes' prilozheniem.
echo ============================================================
echo.
echo Pervaya sborka zanimaet 1-3 minuty...
call "%FLUTTER%" run --release -d web-server --web-hostname 0.0.0.0 --web-port 8080
pause
exit /b 0

:oshibka
echo.
echo Chto-to poshlo ne tak. Sfotografirujte eto okno i prishlite.
pause
exit /b 1
