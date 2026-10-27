# Loloshop: baixa a versao mais nova dos Releases do GitHub e instala quando o app estiver fechado.
# Roda escondido ao entrar no Windows e todo dia ao meio-dia (instalar.ps1 configura isso).
# Com o Loloshop aberto, a versao nova fica guardada e entra na proxima vez que este script rodar.
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$Repo = 'PimentaBrrt/loloshop'
$Asset = 'Loloshop-windows-x64.exe'
$Dir = $PSScriptRoot
$Exe = Join-Path $Dir 'Loloshop.exe'
$New = Join-Path $Dir 'Loloshop.exe.new'
$Version = Join-Path $Dir 'versao.txt'
$NewVersion = Join-Path $Dir 'versao.new.txt'
$Log = Join-Path $Dir 'atualizar.log'

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
  $file = $release.assets | Where-Object { $_.name -eq $Asset } | Select-Object -First 1
  $wanted = ($tag -ne (Read-Tag $Version)) -or -not (Test-Path $Exe)
  $ready = (Test-Path $New) -and ((Read-Tag $NewVersion) -eq $tag)
  if ($file -and $wanted -and -not $ready) {
    $part = "$New.part"
    Invoke-WebRequest $file.browser_download_url -OutFile $part -UseBasicParsing -Headers @{ 'User-Agent' = 'Loloshop-updater' }
    if ((Get-Item $part).Length -ne $file.size) { throw "download incompleto de $tag" }
    Move-Item $part $New -Force
    Set-Content -Path $NewVersion -Value $tag
    Write-Log "baixada $tag"
  }
} catch {
  Write-Log "nao deu para buscar atualizacao: $_"
}

if (Test-Path $New) {
  $open = Get-Process -Name 'Loloshop' -ErrorAction SilentlyContinue
  if ($open) {
    Write-Log "Loloshop aberto; a versao nova entra na proxima vez"
  } else {
    Move-Item $New $Exe -Force
    Move-Item $NewVersion $Version -Force
    Write-Log "instalada $(Read-Tag $Version)"
  }
}
