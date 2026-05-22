@echo off
title ai-setup — Asistente de desarrollo
cd /d "%~dp0"

:: Forzar UTF-8
chcp 65001 >nul

:: Detectar Git Bash
set "GIT_BASH="
if exist "%ProgramFiles%\Git\bin\bash.exe" set "GIT_BASH=%ProgramFiles%\Git\bin\bash.exe"
if exist "%ProgramFiles(x86)%\Git\bin\bash.exe" set "GIT_BASH=%ProgramFiles(x86)%\Git\bin\bash.exe"
if exist "%LocalAppData%\Programs\Git\bin\bash.exe" set "GIT_BASH=%LocalAppData%\Programs\Git\bin\bash.exe"

echo ================================================
echo   Setup de asistente de desarrollo
echo ================================================
echo.

if defined GIT_BASH (
    echo   Git Bash detectado. Ejecutando setup.sh...
    echo.
    "%GIT_BASH%" -c "./setup.sh"
) else (
    echo   Git Bash no encontrado. Usando PowerShell...
    echo.
    echo   Si tenes Git Bash, instalalo desde: https://git-scm.com
    echo.
    powershell -ExecutionPolicy Bypass -NoProfile -File "%~dp0setup.ps1"
)

echo.
echo   Listo. Esta ventana se va a cerrar.
pause >nul
