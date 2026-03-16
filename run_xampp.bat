@echo off
setlocal EnableDelayedExpansion

REM Move to this script folder
cd /d "%~dp0"

REM Check XAMPP mysql client exists
if not exist "C:\xampp\mysql\bin\mysql.exe" (
    echo [ERROR] XAMPP MySQL client not found at C:\xampp\mysql\bin\mysql.exe
    echo Please install XAMPP or update this path in run_xampp.bat
    pause
    exit /b 1
)

REM Ask for password (blank for default XAMPP root with no password)
set /p MYSQL_PASS=Enter MySQL root password (leave blank if none): 

REM Remove accidental spaces-only input
if "%MYSQL_PASS: =%"=="" set "MYSQL_PASS="

if "%MYSQL_PASS%"=="" (
    echo Running with user root and no password...
    "C:\xampp\mysql\bin\mysql.exe" --protocol=tcp -h 127.0.0.1 -P 3307 -u root --execute="source run_all.sql"
) else (
    echo Running with user root and provided password...
    "C:\xampp\mysql\bin\mysql.exe" --protocol=tcp -h 127.0.0.1 -P 3307 -u root -p"%MYSQL_PASS%" --execute="source run_all.sql"
)

if errorlevel 1 (
    echo.
    echo [FAILED] Could not run SQL files.
    echo - Check XAMPP MySQL is started in XAMPP Control Panel
    echo - Check root password is correct
    echo - If needed, open XAMPP shell and run: mysql -u root -p
    pause
    exit /b 1
)

echo.
echo [SUCCESS] All scripts executed.
echo You can verify in phpMyAdmin: database datawarehousing_practical
pause
exit /b 0
