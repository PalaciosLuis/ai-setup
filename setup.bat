@echo off
title ai-setup — Asistente de desarrollo
cd /d "%~dp0"

echo ════════════════════════════════════════════
echo   Configuración de asistente de desarrollo
echo ════════════════════════════════════════════
echo.
echo   Ejecutando instalador de OpenCode + Gentle AI...
echo   (Esto abre una ventana de PowerShell automáticamente)
echo.
echo   Si Windows te pide permisos, aceptalos.
echo.

powershell -ExecutionPolicy Bypass -NoProfile -File "%~dp0setup.ps1"

echo.
echo   La ventana se va a cerrar automáticamente.
pause >nul
