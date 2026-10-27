# Remove o Loloshop instalado por instalar.ps1: o app, os atalhos e a atualizacao automatica.
# As preferencias do app (em %APPDATA%) ficam.
#   powershell -ExecutionPolicy Bypass -File "$env:LOCALAPPDATA\Programs\Loloshop\desinstalar.ps1"
$ErrorActionPreference = 'Continue'
Unregister-ScheduledTask -TaskName 'Loloshop - atualizar' -Confirm:$false -ErrorAction SilentlyContinue
foreach ($link in @(
    (Join-Path ([Environment]::GetFolderPath('Programs')) 'Loloshop.lnk'),
    (Join-Path ([Environment]::GetFolderPath('Desktop')) 'Loloshop.lnk'),
    (Join-Path ([Environment]::GetFolderPath('Startup')) 'Loloshop - atualizar.lnk'))) {
  Remove-Item $link -ErrorAction SilentlyContinue
}
Set-Location $env:TEMP
Remove-Item (Join-Path $env:LOCALAPPDATA 'Programs\Loloshop') -Recurse -Force
Write-Host 'Loloshop removido.'
