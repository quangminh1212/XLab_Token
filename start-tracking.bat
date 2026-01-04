@echo off
chcp 65001 >nul
setlocal EnableDelayedExpansion

echo.
echo ╔═══════════════════════════════════════════════════════════════╗
echo ║     🔮 TokenSage - Auto Track Mode                            ║
echo ║     Automatically intercept ALL AI requests                   ║
echo ╚═══════════════════════════════════════════════════════════════╝
echo.

cd /d "%~dp0"

:: Find mitmdump
set MITMDUMP=
where mitmdump >nul 2>&1 && set MITMDUMP=mitmdump
if "%MITMDUMP%"=="" (
    if exist "%USERPROFILE%\AppData\Roaming\Python\Python314\Scripts\mitmdump.exe" (
        set MITMDUMP=%USERPROFILE%\AppData\Roaming\Python\Python314\Scripts\mitmdump.exe
    )
)
if "%MITMDUMP%"=="" (
    if exist "%USERPROFILE%\AppData\Roaming\Python\Python313\Scripts\mitmdump.exe" (
        set MITMDUMP=%USERPROFILE%\AppData\Roaming\Python\Python313\Scripts\mitmdump.exe
    )
)
if "%MITMDUMP%"=="" (
    if exist "%USERPROFILE%\AppData\Roaming\Python\Python312\Scripts\mitmdump.exe" (
        set MITMDUMP=%USERPROFILE%\AppData\Roaming\Python\Python312\Scripts\mitmdump.exe
    )
)
if "%MITMDUMP%"=="" (
    if exist "%USERPROFILE%\AppData\Local\Programs\Python\Python314\Scripts\mitmdump.exe" (
        set MITMDUMP=%USERPROFILE%\AppData\Local\Programs\Python\Python314\Scripts\mitmdump.exe
    )
)

if "%MITMDUMP%"=="" (
    echo [ERROR] mitmdump not found!
    echo.
    echo Please install mitmproxy: pip install mitmproxy
    echo Then add Python Scripts to PATH or run again.
    pause
    exit /b 1
)

echo [INFO] Found mitmdump: %MITMDUMP%

:: Check if built
if not exist "dist\proxy.js" (
    echo [INFO] Building project...
    call npm run build
)

:: Start TokenSage server in background
echo [INFO] Starting TokenSage server...
start /b cmd /c "node dist/proxy.js"
timeout /t 2 /nobreak >nul

:: Enable Windows system proxy
echo [INFO] Enabling Windows system proxy...
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyEnable /t REG_DWORD /d 1 /f >nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyServer /t REG_SZ /d "127.0.0.1:8080" /f >nul

echo.
echo ───────────────────────────────────────────────────────────────
echo   ✅ System proxy ENABLED (127.0.0.1:8080)
echo   Dashboard:  http://localhost:4001
echo ───────────────────────────────────────────────────────────────
echo.
echo   ⚠️  First time? Install mitmproxy certificate:
echo   1. Open browser and go to: http://mitm.it
echo   2. Click "Windows" to download certificate
echo   3. Install certificate to "Trusted Root Certification Authorities"
echo ───────────────────────────────────────────────────────────────
echo.
echo   Press Ctrl+C to stop (proxy will be disabled automatically)
echo.

:: Open dashboard
start "" "http://localhost:4001"

:: Start mitmproxy
"%MITMDUMP%" -s addon.py --set block_global=false

:: When mitmproxy stops, disable proxy
echo.
echo [INFO] Disabling Windows system proxy...
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyEnable /t REG_DWORD /d 0 /f >nul
echo [INFO] Proxy disabled. Stopping TokenSage...
taskkill /f /im node.exe >nul 2>&1
echo [INFO] Done.
pause
