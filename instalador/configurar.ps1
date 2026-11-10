# O que o instalador (instalador.iss) faz fora dos arquivos e atalhos, para um app:
#   - a tarefa "<App> - atualizar", todo dia ao meio-dia
#   - com -Claude, o servidor MCP do app no Claude Desktop: le a pasta Imagens e grava em
#     Imagens\<App> Claude
#   - avisa o Explorer que o .exe e os atalhos mudaram (o icone novo aparece sem reiniciar)
# Com -Remove, desfaz tudo isso; as preferencias do app e a pasta Imagens\<App> Claude ficam.
#
# O mesmo que install/instalar.ps1 e install/desinstalar.ps1 de cada repositorio fazem, com os
# mesmos nomes: o instalador pode ir por cima de uma instalacao feita por eles, e vice-versa.
param(
  [Parameter(Mandatory = $true)][ValidateSet('Loloshop', 'Illostrator')][string] $App,
  [switch] $Claude,
  [switch] $Remove
)
$ErrorActionPreference = 'Stop'

$Key = $App.ToLowerInvariant()
$Dir = Join-Path $env:LOCALAPPDATA "Programs\$App"
$Exe = Join-Path $Dir "$App.exe"
$Cli = Join-Path $Dir "$Key-cli.exe"
$Task = "$App - atualizar"
$Links = @(
  (Join-Path ([Environment]::GetFolderPath('Programs')) "$App.lnk"),
  (Join-Path ([Environment]::GetFolderPath('Desktop')) "$App.lnk"),
  (Join-Path ([Environment]::GetFolderPath('Startup')) "$App - atualizar.lnk")
)

# O Claude Desktop le os servidores MCP de claude_desktop_config.json: em %APPDATA%\Claude, ou, na
# versao da Microsoft Store, dentro da pasta do pacote.
function Get-ClaudeFolders {
  $folders = @(Join-Path $env:APPDATA 'Claude')
  $folders += @(Get-ChildItem (Join-Path $env:LOCALAPPDATA 'Packages') -Directory -Filter 'Claude_*' -ErrorAction SilentlyContinue |
    ForEach-Object { Join-Path $_.FullName 'LocalCache\Roaming\Claude' } | Where-Object { Test-Path $_ })
  return $folders
}

function Write-Config([string] $Path, $Config) {
  # Sem isso, o Windows PowerShell 5.1 escreve listas como {"value": [...], "Count": n}.
  Remove-TypeData System.Array -ErrorAction SilentlyContinue
  [IO.File]::WriteAllText($Path, ($Config | ConvertTo-Json -Depth 32), (New-Object Text.UTF8Encoding $false))
}

# As outras configuracoes do arquivo ficam; a primeira vez guarda uma copia em
# claude_desktop_config.json.antes-do-<app>.
function Set-ClaudeServer([string] $Folder, $Server) {
  $path = Join-Path $Folder 'claude_desktop_config.json'
  $config = $null
  if (Test-Path $path) {
    $text = [IO.File]::ReadAllText($path)
    # JSON invalido para aqui, antes de mexer no arquivo.
    if ($text.Trim()) { $config = $text | ConvertFrom-Json }
    if (-not (Test-Path "$path.antes-do-$Key")) { Copy-Item $path "$path.antes-do-$Key" }
  }
  if (-not $config) { $config = New-Object PSObject }
  if (-not $config.mcpServers) { $config | Add-Member -NotePropertyName mcpServers -NotePropertyValue (New-Object PSObject) -Force }
  $config.mcpServers | Add-Member -NotePropertyName $Key -NotePropertyValue $Server -Force
  New-Item -ItemType Directory -Force -Path $Folder | Out-Null
  Write-Config $path $config
}

function Remove-ClaudeServer([string] $Folder) {
  $path = Join-Path $Folder 'claude_desktop_config.json'
  if (-not (Test-Path $path)) { return }
  $config = [IO.File]::ReadAllText($path) | ConvertFrom-Json
  if ($config.mcpServers -and $config.mcpServers.PSObject.Properties[$Key]) {
    $config.mcpServers.PSObject.Properties.Remove($Key)
    Write-Config $path $config
  }
}

# O Windows guarda o icone de cada arquivo e nao percebe quando o .exe muda.
function Update-Icons {
  if (-not ('Craft.Shell' -as [type])) {
    Add-Type -Namespace Craft -Name Shell -MemberDefinition '[DllImport("shell32.dll", CharSet = CharSet.Unicode)] public static extern void SHChangeNotify(int eventId, uint flags, string item1, IntPtr item2);'
  }
  foreach ($path in @($Exe) + $Links) {
    [Craft.Shell]::SHChangeNotify(0x2000, 0x1005, $path, [IntPtr]::Zero) # SHCNE_UPDATEITEM, SHCNF_PATHW | SHCNF_FLUSH
  }
  [Craft.Shell]::SHChangeNotify(0x8000000, 0x1000, $null, [IntPtr]::Zero) # SHCNE_ASSOCCHANGED, SHCNF_FLUSH
}

$failed = @()

if ($Remove) {
  # O Claude Desktop deixa o servidor MCP aberto, e um .exe aberto nao pode ser apagado.
  Get-Process -Name "$Key-cli" -ErrorAction SilentlyContinue | Stop-Process -Force
  Unregister-ScheduledTask -TaskName $Task -Confirm:$false -ErrorAction SilentlyContinue
  # Os atalhos que o instalador nao criou (de uma instalacao feita por instalar.ps1).
  foreach ($link in $Links) { Remove-Item $link -ErrorAction SilentlyContinue }
  foreach ($folder in Get-ClaudeFolders) {
    try { Remove-ClaudeServer $folder } catch { $failed += "Claude Desktop em ${folder}: $_" }
  }
} else {
  # Todo dia ao meio-dia (ou assim que o PC ligar, se estava desligado). Ao entrar no Windows,
  # o atalho que o instalador poe na pasta Inicializar.
  try {
    $run = "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$(Join-Path $Dir 'atualizar.ps1')`""
    $action = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument $run
    $trigger = New-ScheduledTaskTrigger -Daily -At '12:00'
    $settings = New-ScheduledTaskSettingsSet -StartWhenAvailable -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -ExecutionTimeLimit (New-TimeSpan -Minutes 30)
    Register-ScheduledTask -TaskName $Task -Action $action -Trigger $trigger -Settings $settings -Description "Baixa a versao nova do $App" -Force | Out-Null
  } catch {
    $failed += "tarefa diaria: $_"
  }
  if ($Claude) {
    $pictures = [Environment]::GetFolderPath('MyPictures')
    $output = Join-Path $pictures "$App Claude"
    New-Item -ItemType Directory -Force -Path $output | Out-Null
    $server = [pscustomobject]@{
      command = $Cli
      args = @('mcp', '--automation-read-root', $pictures, '--automation-write-root', $output)
    }
    foreach ($folder in Get-ClaudeFolders) {
      try { Set-ClaudeServer $folder $server } catch { $failed += "Claude Desktop em ${folder}: $_" }
    }
  }
  try { Update-Icons } catch { }
}

if ($failed) {
  $failed | Set-Content -Path (Join-Path $env:TEMP "configurar-$Key.log")
  exit 1
}
