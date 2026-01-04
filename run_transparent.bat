@echo off
:: ═══════════════════════════════════════════════════════════════════
:: TokenSage - TRANSPARENT MODE (WinDivert)
:: WARNING: May cause network issues! Use run.bat for safe mode.
:: ═══════════════════════════════════════════════════════════════════

:: Check for admin rights
net session >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo [INFO] Requesting Administrator privileges...
    powershell -NoProfile -Command "Start-Process cmd -ArgumentList '/c \"%~f0\"' -Verb RunAs"
    exit /b
)

chcp 65001 >nul
cd /d "%~dp0"

echo.
echo ╔═══════════════════════════════════════════════════════════════╗
echo ║     🔮 TokenSage - TRANSPARENT MODE (WinDivert)               ║
echo ║     ⚠️  WARNING: May cause network issues!                    ║
echo ╚═══════════════════════════════════════════════════════════════╝
echo.

:: Stop conflicting services
echo [INFO] Stopping conflicting services...
taskkill /f /im "Cloudflare WARP.exe" >nul 2>&1
net stop CloudflareWARP >nul 2>&1
net stop "WireGuard" >nul 2>&1

:: Find mitmdump
set MITMDUMP=
where mitmdump >nul 2>&1 && set MITMDUMP=mitmdump
if "%MITMDUMP%"=="" (
    for %%V in (314 313 312 311 310) do (
        if exist "%USERPROFILE%\AppData\Roaming\Python\Python%%V\Scripts\mitmdump.exe" (
            set MITMDUMP=%USERPROFILE%\AppData\Roaming\Python\Python%%V\Scripts\mitmdump.exe
            goto :found
        )
    )
)
:found

if "%MITMDUMP%"=="" (
    echo [ERROR] mitmproxy not found!
    pause
    exit /b 1
)

:: Start TokenSage server
echo [INFO] Starting TokenSage server...
start /b cmd /c "node dist/proxy.js"
timeout /t 2 /nobreak >nul

echo.
echo   Dashboard: http://localhost:4001
echo   Press Ctrl+C to stop (network will restore)
echo.

start "" "http://localhost:4001"

:: Run transparent proxy - intercept only port 443
"%MITMDUMP%" --mode "local:!443" -s addon.py --set block_global=false

:: Cleanup
echo [INFO] Stopping...
taskkill /f /im node.exe >nul 2>&1
net start CloudflareWARP >nul 2>&1
echo [INFO] Done.
