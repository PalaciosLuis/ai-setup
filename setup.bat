@echo off
title ai-setup — Asistente de desarrollo
cd /d "%~dp0"

:: Forzar UTF-8 en la consola
chcp 65001 >nul

echo ================================================
echo   Configuracion de asistente de desarrollo
echo ================================================
echo.
echo   Ejecutando instalador de OpenCode + Gentle AI...
echo.
echo   Si Windows te pide permisos, aceptalos.
echo.

powershell -ExecutionPolicy Bypass -NoProfile -File "%~dp0setup.ps1"

echo.
echo   Listo. Esta ventana se va a cerrar.
pause >nul
