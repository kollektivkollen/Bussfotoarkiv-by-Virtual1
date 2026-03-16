@echo off
cd /d "%~dp0"
setlocal enabledelayedexpansion

echo ===============================
echo BUSSFOTOARKIV - UPPDATERING
echo ===============================
echo.

echo Steg 1:
echo Kor makethumbs.py manuellt i respektive bildmapp innan du fortsatter.
echo Exempel:
echo   python makethumbs.py images\transdev
echo   python makethumbs.py images\nobina
echo   python makethumbs.py images\bergkvarabuss
echo.
pause

:buildloop
echo.
set /p BUILDDIR=Ange bildkatalog att bygga ^(t.ex. nobina, transdev, bergkvarabuss^), eller tryck Enter for att ga vidare: 

if "%BUILDDIR%"=="" goto afterbuild

if not exist "images\%BUILDDIR%\" (
    echo.
    echo Katalogen images\%BUILDDIR%\ finns inte.
    echo Forsok igen.
    goto buildloop
)

echo.
echo Bygger vehicles for images\%BUILDDIR%\ ...
python buildvehicles.py "images/%BUILDDIR%" .
if errorlevel 1 goto :error

echo.
set /p MORE=Vill du bygga en till bildkatalog? ^(j/n^): 
if /i "%MORE%"=="j" goto buildloop
if /i "%MORE%"=="y" goto buildloop

:afterbuild
echo.
echo Slar ihop vehicles.json...
python mergevehicles.py . .
if errorlevel 1 goto :error

echo.
echo Laddar upp bilder till Cloudflare R2...
rclone copy images r2:bussfoto/images --progress
if errorlevel 1 goto :error

echo.
echo Laddar upp thumbnails till Cloudflare R2...
rclone copy thumbs r2:bussfoto/thumbs --progress
if errorlevel 1 goto :error

echo.
echo ===============================
echo Klart!
echo Kom ihag att commit + push i GitHub Desktop
echo ===============================
pause
goto :eof

:error
echo.
echo ===============================
echo Nagot gick fel. Batchfilen avbryts.
echo ===============================
pause
exit /b 1