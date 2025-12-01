@echo off
title Limpeza Completa do PC
color 0B
echo ===============================================
echo      SCRIPT DE LIMPEZA COMPLETA DO PC
echo ===============================================
echo.

REM Verifica se está executando como administrador
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo Este script precisa ser executado como Administrador!
    echo.
    pause
    exit /b 1
)

CHOICE /C SN /M "A lixeira será esvaziada e todos os navegadores serão fechados. Certifique-se de salvar seu trabalho antes de continuar. Deseja prosseguir com a operação? (S/N)"
if %errorLevel% 2 exit /b 1

echo ===============================================
echo       FECHANDO PROGRAMAS EM EXECUCAO
echo ===============================================
echo.

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
echo.
timeout /t 3 /nobreak >nul

echo ===============================================
echo         INICIANDO LIMPEZA
echo ===============================================
echo.

echo Limpando arquivos temporarios do Windows...
echo -----------------------------------------------
del /q /f /s /a C:\Windows\Temp\*.* 2>nul
for /d %%x in (C:\Windows\Temp\*) do (
    rd /s /q "%%x" 2>nul
)
echo.

echo Limpando arquivos temporarios do usuario...
echo -----------------------------------------------
del /q /f /s /a %TEMP%\*.* 2>nul
for /d %%x in (%TEMP%\*) do (
    rd /s /q "%%x" 2>nul
)
if exist "C:\Users\" (
  for /D %%x in ("C:\Users\*") do (
    rmdir /s /q "%%x\AppData\Local\Temp"
  )
)

if exist "C:\Users\" (
   for /D %%x in ("C:\Users\*") do (
     rmdir /s /q "%%x\AppData\Local\Microsoft\Windows\Temporary Internet Files"
   )
)
echo.

echo Limpando Prefetch...
echo -----------------------------------------------
del /f/s/q %WINDIR%\Prefetch\*.*
echo.

echo Esvaziando Lixeira de todas as unidades...
echo -----------------------------------------------
rd /s /q C:\$Recycle.Bin 2>nul
rd /s /q D:\$Recycle.Bin 2>nul
rd /s /q E:\$Recycle.Bin 2>nul
echo.

echo Limpando cache de atualizacoes do Windows...
echo -----------------------------------------------
net stop wuauserv >nul 2>&1
net stop bits >nul 2>&1
timeout /t 2 /nobreak >nul
del /q /f /s C:\Windows\SoftwareDistribution\Download\*.* 2>nul
for /d %%x in (C:\Windows\SoftwareDistribution\Download\*) do (
    rd /s /q "%%x" 2>nul
)
net start wuauserv >nul 2>&1
net start bits >nul 2>&1
echo.

echo Limpando logs antigos do Windows...
echo -----------------------------------------------
REM Limpa apenas logs antigos (mais de 7 dias)
forfiles /P "C:\Windows\Logs" /S /M *.log /D -7 /C "cmd /c del /q @path" 2>nul
forfiles /P "C:\Windows\Logs" /S /M *.etl /D -7 /C "cmd /c del /q @path" 2>nul
echo.

echo Limpando arquivos de despejo de memoria...
echo -----------------------------------------------
del /q /f C:\Windows\*.dmp 2>nul
del /q /f C:\Windows\Minidump\*.dmp 2>nul
del /q /f "%LOCALAPPDATA%\CrashDumps\*.dmp" 2>nul
echo.

echo Limpando cache do Chrome...
echo -----------------------------------------------
for /d %%x in ("%LOCALAPPDATA%\Google\Chrome\User Data\*") do (
    if exist "%%x\Cache" rd /s /q "%%x\Cache" 2>nul
    if exist "%%x\Code Cache" rd /s /q "%%x\Code Cache" 2>nul
    if exist "%%x\GPUCache" rd /s /q "%%x\GPUCache" 2>nul
    if exist "%%x\Service Worker" rd /s /q "%%x\Service Worker" 2>nul
)
if exist "%LOCALAPPDATA%\Google\Chrome\User Data\ShaderCache" (
    rd /s /q "%LOCALAPPDATA%\Google\Chrome\User Data\ShaderCache" 2>nul
)
echo.

echo Limpando cache do Firefox...
echo -----------------------------------------------
if exist "%LOCALAPPDATA%\Mozilla\Firefox\Profiles" (
    for /d %%x in ("%LOCALAPPDATA%\Mozilla\Firefox\Profiles\*") do (
        if exist "%%x\cache2" rd /s /q "%%x\cache2" 2>nul
        if exist "%%x\startupCache" rd /s /q "%%x\startupCache" 2>nul
        if exist "%%x\jumpListCache" rd /s /q "%%x\jumpListCache" 2>nul
        if exist "%%x\OfflineCache" rd /s /q "%%x\OfflineCache" 2>nul
        if exist "%%x\shader-cache" rd /s /q "%%x\shader-cache" 2>nul
    )
)
echo.

echo Limpando cache do Edge...
echo -----------------------------------------------
for /d %%x in ("%LOCALAPPDATA%\Microsoft\Edge\User Data\*") do (
    if exist "%%x\Cache" rd /s /q "%%x\Cache" 2>nul
    if exist "%%x\Code Cache" rd /s /q "%%x\Code Cache" 2>nul
    if exist "%%x\GPUCache" rd /s /q "%%x\GPUCache" 2>nul
)
echo.

echo Limpando arquivos de relatorios de erros...
echo -----------------------------------------------
del /q /f /s "%LOCALAPPDATA%\CrashDumps\*.*" 2>nul
del /q /f /s "C:\ProgramData\Microsoft\Windows\WER\ReportQueue\*.*" 2>nul
del /q /f /s "C:\ProgramData\Microsoft\Windows\WER\ReportArchive\*.*" 2>nul
for /d %%x in ("C:\ProgramData\Microsoft\Windows\WER\ReportQueue\*") do rd /s /q "%%x" 2>nul
for /d %%x in ("C:\ProgramData\Microsoft\Windows\WER\ReportArchive\*") do rd /s /q "%%x" 2>nul
echo.

echo Limpando miniaturas e icones em cache...
echo -----------------------------------------------
timeout /t 2 /nobreak >nul
del /q /f /a "%LOCALAPPDATA%\Microsoft\Windows\Explorer\*.db" 2>nul
del /q /f /a "%LOCALAPPDATA%\IconCache.db" 2>nul
del /q /f /a "%LOCALAPPDATA%\Microsoft\Windows\Explorer\iconcache_*.db" 2>nul
echo.


echo Limpando arquivos de instalacao antigos do Windows...
echo -----------------------------------------------
REM Remove instaladores antigos do Windows Update
dism /online /Cleanup-Image /StartComponentCleanup /ResetBase >nul 2>&1
del /q /f /s C:\Windows\SoftwareDistribution\*.* 2>nul
echo.

echo Limpando pasta de downloads do Windows...
echo -----------------------------------------------
del /q /f "%USERPROFILE%\Downloads\*.tmp" 2>nul
del /q /f "%USERPROFILE%\Downloads\*.temp" 2>nul
del /q /f "%USERPROFILE%\Downloads\*.crdownload" 2>nul
del /q /f "%USERPROFILE%\Downloads\*.part" 2>nul
echo.

echo Limpando arquivos desnecessarios do sistema...
echo -----------------------------------------------
REM Configura e executa limpeza de disco automática
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Temporary Files" /v "StateFlags0001" /t REG_DWORD /d 2 /f >nul
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Temporary Setup Files" /v "StateFlags0001" /t REG_DWORD /d 2 /f >nul
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Downloaded Program Files" /v "StateFlags0001" /t REG_DWORD /d 2 /f >nul
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Internet Cache Files" /v "StateFlags0001" /t REG_DWORD /d 2 /f >nul
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Recycle Bin" /v "StateFlags0001" /t REG_DWORD /d 2 /f >nul
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Thumbnail Cache" /v "StateFlags0001" /t REG_DWORD /d 2 /f >nul
start /min cleanmgr /sagerun:1
timeout /t 5 /nobreak >nul
echo.

echo ===============================================
echo            LIMPEZA CONCLUIDA COM SUCESSO
echo ===============================================
echo
echo Necessário reiniciar o PC.
echo.
echo ===============================================

pause

exit /b 0
