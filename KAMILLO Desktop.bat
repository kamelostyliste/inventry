@echo off
title KAMILLO
cd /d "%~dp0"
echo Starting KAMILLO...

:: Kill old server
taskkill /f /im node.exe /fi "WINDOWTITLE eq KAMILLO" >nul 2>&1

:: Start server
start "KAMILLO" /min node server.cjs

:: Wait for server
:wait
timeout /t 1 /nobreak >nul
curl -s http://127.0.0.1:8080 >nul 2>&1 || goto wait

:: Open as standalone app
start chrome --app=http://127.0.0.1:8080

echo KAMILLO is running.
echo Close Chrome window and press Enter to stop.
pause >nul

:: Stop server
taskkill /f /im node.exe /fi "WINDOWTITLE eq KAMILLO" >nul 2>&1
echo Server stopped.
