@echo off
title Clean PC
color 0B
chcp 65001 >nul

setlocal enabledelayedexpansion

echo ===============================================
echo     Cleanup PC
echo ===============================================
echo.

:: Verifica se está executando como administrador
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo Este script precisa ser executado como Administrador!
    echo.
    pause
    exit /b 1
)

CHOICE /C SN /M "A lixeira será esvaziada e todos os navegadores serão fechados. Certifique-se de salvar seu trabalho antes de continuar. Deseja prosseguir com a operação? (S/N)"

if %errorLevel%==2 exit /B 1

taskkill /f /im explorer.exe
start explorer.exe

echo Fechando Programas...
taskkill /F /IM chrome.exe >nul 2>&1
taskkill /F /IM firefox.exe >nul 2>&1
taskkill /F /IM msedge.exe >nul 2>&1
taskkill /F /IM opera.exe >nul 2>&1
taskkill /F /IM brave.exe >nul 2>&1

taskkill /F /IM OneDrive.exe >nul 2>&1
taskkill /F /IM dropbox.exe >nul 2>&1
taskkill /F /IM spotify.exe >nul 2>&1
timeout /t 3 /nobreak >nul

echo Iniciando limpeza...
echo.

echo Limpando arquivos temporários do Windows...
del /q /f /s /a C:\Windows\Temp\*.* 2>nul
for /d %%x in (C:\Windows\Temp\*) do (
    rd /s /q "%%x" 2>nul
)

del /q /f /s /a %TEMP%\*.* 2>nul
for /d %%x in (%TEMP%\*) do (
    rd /s /q "%%x" 2>nul
)

echo Limpando Prefetch...
del /f/s/q %WINDIR%\Prefetch\*.*

echo Esvaziando Lixeira de todas as unidades...
rd /s /q C:\$Recycle.Bin 2>nul
rd /s /q D:\$Recycle.Bin 2>nul
rd /s /q E:\$Recycle.Bin 2>nul

echo Limpando cache de atualizações do Windows...
net stop wuauserv >nul 2>&1
net stop bits >nul 2>&1
timeout /t 2 /nobreak >nul
del /q /f /s C:\Windows\SoftwareDistribution\Download\*.* 2>nul
for /d %%x in (C:\Windows\SoftwareDistribution\Download\*) do (
    rd /s /q "%%x" 2>nul
)

net start wuauserv >nul 2>&1
net start bits >nul 2>&1

echo Limpando logs antigos do Windows...
forfiles /P "C:\Windows\Logs" /S /M *.log /D -7 /C "cmd /c del /q @path" 2>nul
forfiles /P "C:\Windows\Logs" /S /M *.etl /D -7 /C "cmd /c del /q @path" 2>nul

echo Limpando arquivos de despejo de memória...
del /q /f C:\Windows\*.dmp 2>nul
del /q /f C:\Windows\Minidump\*.dmp 2>nul

for /D %%u in ("C:\Users\*") do (
    echo.

    set "user=%%~nu"

    echo Limpando arquivos temporários de !user!
    if exist "%%u\AppData\Local\Temp" (
        rmdir /s /q "%%u\AppData\Local\Temp"
    )

    rmdir /s /q "%%x\AppData\Local\Microsoft\Windows\Temporary Internet Files"

    echo Limpando logs de !user!...
    if exist "%%u\AppData\Local\CrashDumps" (
        del /q /f "%%u\AppData\Local\CrashDumps\*.dmp" 2>nul
        del /q /f /s "%%u\AppData\Local\CrashDumps\*.*" 2>nul
    )

    echo Limpando cache do Chrome de !user!...
    for /d %%x in ("%%u\AppData\Local\Google\Chrome\User Data\*") do (
        if exist "%%x\Cache" rd /s /q "%%x\Cache" 2>nul
        if exist "%%x\Code Cache" rd /s /q "%%x\Code Cache" 2>nul
        if exist "%%x\GPUCache" rd /s /q "%%x\GPUCache" 2>nul
        if exist "%%x\Service Worker" rd /s /q "%%x\Service Worker" 2>nul
    )

    if exist "%%u\AppData\Local\Google\Chrome\User Data\ShaderCache" (
        rd /s /q "%%u\AppData\Local\Google\Chrome\User Data\ShaderCache" 2>nul
    )

    echo Limpando cache do Firefox de !user!...
    if exist "%%u\AppData\Local\Mozilla\Firefox\Profiles" (
        for /d %%x in ("%%u\AppData\Local\Mozilla\Firefox\Profiles\*") do (
            if exist "%%x\cache2" rd /s /q "%%x\cache2" 2>nul
            if exist "%%x\startupCache" rd /s /q "%%x\startupCache" 2>nul
            if exist "%%x\jumpListCache" rd /s /q "%%x\jumpListCache" 2>nul
            if exist "%%x\OfflineCache" rd /s /q "%%x\OfflineCache" 2>nul
            if exist "%%x\shader-cache" rd /s /q "%%x\shader-cache" 2>nul
        )
    )

    echo Limpando cache do Edge de !user!...
    for /d %%x in ("%%u\AppData\Local\Microsoft\Edge\User Data\*") do (
        if exist "%%x\Cache" rd /s /q "%%x\Cache" 2>nul
        if exist "%%x\Code Cache" rd /s /q "%%x\Code Cache" 2>nul
        if exist "%%x\GPUCache" rd /s /q "%%x\GPUCache" 2>nul
    )
)

echo Limpando arquivos de relatórios de erros...
del /q /f /s "C:\ProgramData\Microsoft\Windows\WER\ReportQueue\*.*" 2>nul
del /q /f /s "C:\ProgramData\Microsoft\Windows\WER\ReportArchive\*.*" 2>nul
for /d %%x in ("C:\ProgramData\Microsoft\Windows\WER\ReportQueue\*") do rd /s /q "%%x" 2>nul
for /d %%x in ("C:\ProgramData\Microsoft\Windows\WER\ReportArchive\*") do rd /s /q "%%x" 2>nul

echo Limpando miniaturas e ícones em cache...
timeout /t 2 /nobreak >nul
del /q /f /a "%LOCALAPPDATA%\Microsoft\Windows\Explorer\*.db" 2>nul
del /q /f /a "%LOCALAPPDATA%\IconCache.db" 2>nul
del /q /f /a "%LOCALAPPDATA%\Microsoft\Windows\Explorer\iconcache_*.db" 2>nul

echo Limpando arquivos de instalação antigos do Windows...
dism /online /Cleanup-Image /StartComponentCleanup /ResetBase >nul 2>&1
del /q /f /s C:\Windows\SoftwareDistribution\*.* 2>nul

echo Limpando arquivos temporários da pasta de downloads do Windows...
del /q /f "%USERPROFILE%\Downloads\*.tmp" 2>nul
del /q /f "%USERPROFILE%\Downloads\*.temp" 2>nul
del /q /f "%USERPROFILE%\Downloads\*.crdownload" 2>nul
del /q /f "%USERPROFILE%\Downloads\*.part" 2>nul

echo Limpando arquivos desnecessários do sistema...
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Temporary Files" /v "StateFlags0001" /t REG_DWORD /d 2 /f >nul
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Temporary Setup Files" /v "StateFlags0001" /t REG_DWORD /d 2 /f >nul
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Downloaded Program Files" /v "StateFlags0001" /t REG_DWORD /d 2 /f >nul
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Internet Cache Files" /v "StateFlags0001" /t REG_DWORD /d 2 /f >nul
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Recycle Bin" /v "StateFlags0001" /t REG_DWORD /d 2 /f >nul
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Thumbnail Cache" /v "StateFlags0001" /t REG_DWORD /d 2 /f >nul
start /wait cleanmgr /sagerun:1
timeout /t 5 /nobreak >nul

echo Limpeza concluída com sucesso!
echo.
echo Necessário reiniciar o PC.
echo.
echo ===============================================

pause
exit /b 0