$OutputEncoding = [System.Text.UTF8Encoding]::new($false)
$ErrorActionPreference = 'SilentlyContinue'
$ProgressPreference = 'SilentlyContinue'

$LogFile = "C:\Temp\log.txt"

function Log-ToFile {
    param ([string]$Message, [string]$Type = "INFO")
    $LogEntry = "[$Type] $Message"
    Add-Content -Path $LogFile -Value $LogEntry -Encoding UTF8
}

function Download-File {
    param (
        [string]$Url,
        [string]$OutFile,
        [string]$Name
    )
    
    Log-ToFile -Message "Iniciando download de $Name..." -Type "INFO"
    Remove-Item -Path $OutFile -Force -ErrorAction SilentlyContinue

    try {
        Invoke-WebRequest -Uri $Url -OutFile $OutFile -UseBasicParsing -TimeoutSec 300 | Out-Null
        if (Test-Path $OutFile) {
            Log-ToFile -Message "$Name baixado com sucesso." -Type "SUCCESS"
            return $true
        }
        else {
            Log-ToFile -Message "Arquivo $Name não foi criado após download." -Type "ERROR"
            return $false
        }
    }
    catch {
        Log-ToFile -Message "Falha ao baixar $Name. Erro: $($_.Exception.Message)" -Type "ERROR"
        return $false
    }
}

function Install-Program {
    param (
        [string]$Name,
        [string]$Url,
        [string]$OutFile,
        [string]$InstallCmd,
        [string]$CheckPath
    )

    if (Test-Path $CheckPath) {
         Log-ToFile -Message "$Name já instalado." -Type "INFO"
         return $true
    }

    if (Download-File -Url $Url -OutFile $OutFile -Name $Name) {
        
         $exe, $args = $InstallCmd -split ' ', 2
            
         $process = Start-Process -FilePath $exe -ArgumentList $args -Wait -PassThru -WindowStyle Hidden

        if ($process.ExitCode -eq 0 -or $process.ExitCode -eq 3010) {
            Log-ToFile -Message "$Name instalado com sucesso (ExitCode: $($process.ExitCode))." -Type "SUCCESS"
        }
        else {
            Log-ToFile -Message "$Name falhou na instalação (ExitCode: $($process.ExitCode))." -Type "ERROR"
        }
    }
    else {
        Log-ToFile -Message "Download falhou. instalação de $Name abortada." -Type "ERROR"
    }
}


Install-Program `
    -Name "Google Chrome" `
    -Url "https://dl.google.com/chrome/install/latest/chrome_installer.exe" `
    -OutFile "C:\Temp\Chrome.exe" `
    -InstallCmd "`"C:\Temp\Chrome.exe`" /silent /install" `
    -CheckPath "${env:ProgramFiles}\Google\Chrome\Application\chrome.exe"

Install-Program `
    -Name "Mozilla Firefox" `
    -Url "https://download.mozilla.org/?product=firefox-latest&os=win64&lang=pt-BR" `
    -OutFile "C:\Temp\Firefox.exe" `
    -InstallCmd "`"C:\Temp\Firefox.exe`" /S" `
    -CheckPath "${env:ProgramFiles}\Mozilla Firefox\firefox.exe"

Install-Program `
    -Name "LibreOffice" `
    -Url "https://download.documentfoundation.org/libreoffice/stable/25.8.2/win/x86_64/LibreOffice_25.8.2_Win_x86-64.msi" `
    -OutFile "C:\Temp\LibreOffice.msi" `
    -InstallCmd "msiexec.exe /i `"C:\Temp\LibreOffice.msi`" /quiet /qn /norestart ALLUSERS=1" `
    -CheckPath "${env:ProgramFiles}\LibreOffice\program\soffice.exe" 

Install-Program `
    -Name "Foxit PDF Reader" `
    -Url "https://cdn01.foxitsoftware.com/product/reader/desktop/win/2025.2.1/FoxitPDFReader202521_L10N_Setup_x64.exe" `
    -OutFile "C:\Temp\FoxitReader.exe" `
    -InstallCmd "`"C:\Temp\FoxitReader.exe`" /quiet" `
    -CheckPath "${env:ProgramFiles}\Foxit Software\Foxit PDF Reader\FoxitPDFReader.exe"
    
