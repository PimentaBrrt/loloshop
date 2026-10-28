# Loloshop: baixa a versao mais nova dos Releases do GitHub e instala quando o programa estiver fechado.
# Roda escondido ao entrar no Windows e todo dia ao meio-dia (instalar.ps1 configura isso).
# Cuida de dois arquivos, cada um trocado quando o seu processo estiver fechado:
#   Loloshop.exe      o app
#   loloshop-cli.exe  o servidor MCP que o Claude Desktop abre (fica aberto junto com o Claude)
# Com o programa aberto, a versao nova fica guardada e entra na proxima vez que este script rodar.
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$Repo = 'PimentaBrrt/loloshop'
$Dir = $PSScriptRoot
$Log = Join-Path $Dir 'atualizar.log'
$Files = @(
  @{ Asset = 'Loloshop-windows-x64.exe'; Name = 'Loloshop.exe'; Version = 'versao.txt' },
  @{ Asset = 'Loloshop-cli-windows-x64.exe'; Name = 'loloshop-cli.exe'; Version = 'versao-cli.txt' }
)

function Write-Log([string] $Message) {
  Add-Content -Path $Log -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') $Message"
}

function Read-Tag([string] $Path) {
  if (Test-Path $Path) { return (Get-Content $Path -Raw).Trim() }
  return ''
}

try {
  $release = Invoke-RestMethod "https://api.github.com/repos/$Repo/releases/latest" -Headers @{ 'User-Agent' = 'Loloshop-updater' }
  $tag = $release.tag_name
  foreach ($f in $Files) {
    $exe = Join-Path $Dir $f.Name
    $new = "$exe.new"
    $file = $release.assets | Where-Object { $_.name -eq $f.Asset } | Select-Object -First 1
    $wanted = ($tag -ne (Read-Tag (Join-Path $Dir $f.Version))) -or -not (Test-Path $exe)
    $ready = (Test-Path $new) -and ((Read-Tag "$new.txt") -eq $tag)
    if ($file -and $wanted -and -not $ready) {
      $part = "$new.part"
      Invoke-WebRequest $file.browser_download_url -OutFile $part -UseBasicParsing -Headers @{ 'User-Agent' = 'Loloshop-updater' }
      if ((Get-Item $part).Length -ne $file.size) { throw "download incompleto de $($f.Name) $tag" }
      Move-Item $part $new -Force
      Set-Content -Path "$new.txt" -Value $tag
      Write-Log "baixada $($f.Name) $tag"
    }
  }
} catch {
  Write-Log "nao deu para buscar atualizacao: $_"
}

# O atualizador antigo guardava a versao pendente do app em versao.new.txt.
$legacy = Join-Path $Dir 'versao.new.txt'
if ((Test-Path $legacy) -and -not (Test-Path (Join-Path $Dir 'Loloshop.exe.new.txt'))) {
  Move-Item $legacy (Join-Path $Dir 'Loloshop.exe.new.txt') -Force
}

foreach ($f in $Files) {
  $exe = Join-Path $Dir $f.Name
  $new = "$exe.new"
  if (-not (Test-Path $new)) { continue }
  $process = [IO.Path]::GetFileNameWithoutExtension($f.Name)
  if (Get-Process -Name $process -ErrorAction SilentlyContinue) {
    Write-Log "$($f.Name) aberto; a versao nova entra na proxima vez"
    continue
  }
  try {
    Move-Item $new $exe -Force
    Move-Item "$new.txt" (Join-Path $Dir $f.Version) -Force
    Write-Log "instalada $($f.Name) $(Read-Tag (Join-Path $Dir $f.Version))"
  } catch {
    Write-Log "nao deu para trocar $($f.Name): $_"
  }
}
