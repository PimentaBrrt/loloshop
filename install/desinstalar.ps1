# Remove o Loloshop instalado por instalar.ps1: o app, os atalhos, a atualizacao automatica e o
# servidor MCP do Claude Desktop. As preferencias do app (em %APPDATA%) e a pasta
# Imagens\Loloshop Claude ficam.
#   powershell -ExecutionPolicy Bypass -File "$env:LOCALAPPDATA\Programs\Loloshop\desinstalar.ps1"
$ErrorActionPreference = 'Continue'
if (Get-Process -Name 'Loloshop' -ErrorAction SilentlyContinue) {
  Write-Host 'Feche o Loloshop (salve o que estiver aberto) e rode de novo.'
  exit 1
}
# O Claude Desktop deixa o servidor MCP aberto, e um .exe aberto nao pode ser apagado. Fechar o
# servidor so desconecta o Loloshop do Claude, que ja vai perder o servidor logo abaixo.
Get-Process -Name 'loloshop-cli' -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Sleep -Milliseconds 500
Unregister-ScheduledTask -TaskName 'Loloshop - atualizar' -Confirm:$false -ErrorAction SilentlyContinue
foreach ($link in @(
    (Join-Path ([Environment]::GetFolderPath('Programs')) 'Loloshop.lnk'),
    (Join-Path ([Environment]::GetFolderPath('Desktop')) 'Loloshop.lnk'),
    (Join-Path ([Environment]::GetFolderPath('Startup')) 'Loloshop - atualizar.lnk'))) {
  Remove-Item $link -ErrorAction SilentlyContinue
}

$folders = @(Join-Path $env:APPDATA 'Claude')
$folders += @(Get-ChildItem (Join-Path $env:LOCALAPPDATA 'Packages') -Directory -Filter 'Claude_*' -ErrorAction SilentlyContinue |
  ForEach-Object { Join-Path $_.FullName 'LocalCache\Roaming\Claude' })
foreach ($folder in $folders) {
  $path = Join-Path $folder 'claude_desktop_config.json'
  if (-not (Test-Path $path)) { continue }
  try {
    $config = [IO.File]::ReadAllText($path) | ConvertFrom-Json
    if ($config.mcpServers -and $config.mcpServers.PSObject.Properties['loloshop']) {
      $config.mcpServers.PSObject.Properties.Remove('loloshop')
      Remove-TypeData System.Array -ErrorAction SilentlyContinue
      [IO.File]::WriteAllText($path, ($config | ConvertTo-Json -Depth 32), (New-Object Text.UTF8Encoding $false))
    }
  } catch {
    Write-Host "Aviso: nao deu para tirar o Loloshop de $path ($_)."
  }
}

Set-Location $env:TEMP
Remove-Item (Join-Path $env:LOCALAPPDATA 'Programs\Loloshop') -Recurse -Force
Write-Host 'Loloshop removido.'
