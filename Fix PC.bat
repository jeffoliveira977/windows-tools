@echo off
title Fix PC
color 0B
chcp 65001 >nul

echo ===============================================
echo     Fix PC
echo ===============================================
echo.

:: Verifica se está executando como administrador
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo Este script precisa ser executado como Administrador!
    pause
    exit /b 1
)

echo Verificando e reparando arquivos corrompidos...
sfc /scannow

echo Verificando e reparando imagem do sistema...
DISM /Online /Cleanup-Image /RestoreHealth

echo Agendando verificação de disco para o próximo reinício...
chkdsk C: /f /r

echo.
echo Necessário reiniciar o PC para continuar o reparo.
echo.
echo ===============================================

pause
exit /b 0