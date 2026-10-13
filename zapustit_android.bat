@echo off
chcp 65001 >nul
title ZholTap - Android
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
set "ADB=%LOCALAPPDATA%\Android\Sdk\platform-tools\adb.exe"

rem --- pervyj zapusk: sozdat proekt ---
if not exist "zholtap_android\pubspec.yaml" (
  echo Sozdayu proekt zholtap_android, pervyj raz eto 1-3 minuty...
  call "%FLUTTER%" create --platforms=android --project-name zholtap zholtap_android
  if errorlevel 1 goto oshibka
)
copy /Y "main.dart" "zholtap_android\lib\main.dart" >nul
if errorlevel 1 goto oshibka
powershell -NoProfile -Command "$f='zholtap_android\android\app\src\main\AndroidManifest.xml'; (Get-Content $f) -replace 'android:label=\"zholtap\"','android:label=\"ZholTap\"' | Set-Content $f"
cd zholtap_android

rem --- esli BlueStacks otkryt i v nyom vklyuchen ADB, podklyuchaemsya k nemu ---
if exist "%ADB%" "%ADB%" connect 127.0.0.1:5555 >nul 2>nul

rem --- esli podklyuchen telefon (USB-otladka), emulyator ili BlueStacks: zapuskaem na nyom ---
call "%FLUTTER%" devices --machine > "%TEMP%\zt_dev.txt" 2>nul
findstr /C:"\"android-" "%TEMP%\zt_dev.txt" >nul
if not errorlevel 1 (
  echo Najden Android-telefon ili emulyator. Zapuskayu ZholTap na nyom...
  echo Chtoby ostanovit: nazhmite q v etom okne.
  call "%FLUTTER%" run
  pause
  exit /b 0
)

rem --- inache: sobiraem APK i stavim v BlueStacks ---
echo.
echo Telefon ne podklyuchen. Sobirayu ZholTap.apk.
echo Pervaya sborka dolgaya: 5-15 minut, skachivaetsya Gradle. Ne zakryvajte okno.
echo.
call "%FLUTTER%" build apk --release
if errorlevel 1 goto oshibka
copy /Y "build\app\outputs\flutter-apk\app-release.apk" "..\ZholTap.apk" >nul
cd ..
echo.
echo Gotovo: fajl ZholTap.apk lezhit ryadom s etim fajlom.

if exist "%ADB%" (
  "%ADB%" connect 127.0.0.1:5555 >nul 2>nul
  "%ADB%" -s 127.0.0.1:5555 install -r "ZholTap.apk" >nul 2>nul
  if not errorlevel 1 (
    "%ADB%" -s 127.0.0.1:5555 shell monkey -p com.example.zholtap 1 >nul 2>nul
    echo ZholTap ustanovlen i otkryt v BlueStacks.
    pause
    exit /b 0
  )
)
echo Otkryvayu ZholTap.apk: BlueStacks sam ego ustanovit.
start "" "ZholTap.apk"
pause
exit /b 0

:oshibka
echo.
echo Chto-to poshlo ne tak. Sfotografirujte eto okno i prishlite.
pause
exit /b 1
