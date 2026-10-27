# Instala o Loloshop para o usuario atual (sem precisar de administrador):
#   - o app em %LOCALAPPDATA%\Programs\Loloshop
#   - atalhos "Loloshop" no Menu Iniciar e na Area de Trabalho
#   - atualizacao automatica: ao entrar no Windows (pasta Inicializar) e todo dia ao meio-dia
#
# No PowerShell:
#   irm https://raw.githubusercontent.com/PimentaBrrt/loloshop/main/install/instalar.ps1 | iex
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$Raw = 'https://raw.githubusercontent.com/PimentaBrrt/loloshop/main/install'
$Dir = Join-Path $env:LOCALAPPDATA 'Programs\Loloshop'
$Exe = Join-Path $Dir 'Loloshop.exe'
$Updater = Join-Path $Dir 'atualizar.ps1'
$Run = "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$Updater`""

New-Item -ItemType Directory -Force -Path $Dir | Out-Null
Invoke-WebRequest "$Raw/atualizar.ps1" -OutFile $Updater -UseBasicParsing
Invoke-WebRequest "$Raw/desinstalar.ps1" -OutFile (Join-Path $Dir 'desinstalar.ps1') -UseBasicParsing

Write-Host 'Baixando o Loloshop (uns 100 MB)...'
& powershell.exe -NoProfile -ExecutionPolicy Bypass -File $Updater
if (-not (Test-Path $Exe)) { throw "Nao deu para baixar o Loloshop; veja $Dir\atualizar.log" }

$shell = New-Object -ComObject WScript.Shell
foreach ($folder in 'Programs', 'Desktop') {
  $link = $shell.CreateShortcut((Join-Path ([Environment]::GetFolderPath($folder)) 'Loloshop.lnk'))
  $link.TargetPath = $Exe
  $link.WorkingDirectory = $Dir
  $link.IconLocation = "$Exe,0"
  $link.Description = 'Loloshop'
  $link.Save()
}

# Ao entrar no Windows: um atalho escondido na pasta Inicializar.
$startup = $shell.CreateShortcut((Join-Path ([Environment]::GetFolderPath('Startup')) 'Loloshop - atualizar.lnk'))
$startup.TargetPath = 'powershell.exe'
$startup.Arguments = $Run
$startup.WindowStyle = 7
$startup.Save()

# Todo dia ao meio-dia (ou assim que o PC ligar, se estava desligado).
try {
  $action = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument $Run
  $trigger = New-ScheduledTaskTrigger -Daily -At '12:00'
  $settings = New-ScheduledTaskSettingsSet -StartWhenAvailable -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -ExecutionTimeLimit (New-TimeSpan -Minutes 30)
  Register-ScheduledTask -TaskName 'Loloshop - atualizar' -Action $action -Trigger $trigger -Settings $settings -Description 'Baixa a versao nova do Loloshop' -Force | Out-Null
} catch {
  Write-Host "Aviso: a tarefa diaria nao foi criada ($_). A atualizacao ainda roda ao entrar no Windows."
}

Write-Host 'Pronto! O Loloshop esta no Menu Iniciar e na Area de Trabalho.'
