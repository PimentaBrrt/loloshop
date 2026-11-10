# Remove o Loloshop e o Illostrator instalados pelo instalador (instalador.iss): os apps, os
# atalhos, a atualização automática e os servidores MCP do Claude Desktop. As preferências dos apps
# e as pastas Imagens\Loloshop Claude e Imagens\Illostrator Claude ficam.
#
# É o que Configurações › Apps › Apps instalados › "Loloshop e Illostrator" roda (a chave que o
# instalador grava). Um script, não um .exe: o Controle Inteligente de Aplicativos do Windows
# bloqueia o desinstalador sem assinatura que o Inno Setup faria.
# Com -Silencioso, não pergunta nem avisa (para testar).
param([switch] $Silencioso)
$ErrorActionPreference = 'Continue'
$Here = $PSScriptRoot
$Title = 'Loloshop e Illostrator'
$Apps = @('Loloshop', 'Illostrator')
$Keys = @(
  'HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\Loloshop e Illostrator',
  # A do desinstalador do Inno de uma versão anterior do instalador.
  'HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\{3024DDF6-8928-489F-944D-CE0CE1AF82E4}_is1'
)
$shell = New-Object -ComObject WScript.Shell
function Show([string] $Text, [int] $Kind) {
  if ($Silencioso) { Write-Host $Text; return 6 }
  return $shell.Popup($Text, 0, $Title, $Kind)
}

if (Get-Process -Name $Apps -ErrorAction SilentlyContinue) {
  Show 'Feche o Loloshop e o Illostrator (salve o que estiver aberto) e tente de novo.' 0x30 | Out-Null
  exit 1
}
# 0x24: Sim/Não com interrogação; 6 é Sim.
if ((Show 'Remover o Loloshop e o Illostrator deste computador?' 0x24) -ne 6) { exit 1 }

# A tarefa diária, os servidores MCP e os atalhos (configurar.ps1, em outro processo: ele termina
# com exit quando algo falha).
foreach ($app in $Apps) {
  & powershell.exe -NoProfile -ExecutionPolicy Bypass -File (Join-Path $Here 'configurar.ps1') -App $app -Remove
}
Start-Sleep -Milliseconds 500

Set-Location $env:TEMP
$left = @()
foreach ($app in $Apps) {
  $dir = Join-Path $env:LOCALAPPDATA "Programs\$app"
  Remove-Item $dir -Recurse -Force -ErrorAction SilentlyContinue
  if (Test-Path $dir) { $left += $dir }
}
foreach ($key in $Keys) { Remove-Item $key -Recurse -Force -ErrorAction SilentlyContinue }
Remove-Item $Here -Recurse -Force -ErrorAction SilentlyContinue

if ($left) {
  Show "O Loloshop e o Illostrator foram removidos, mas não deu para apagar:`n$($left -join "`n")`n`nApague essas pastas depois de reiniciar o computador." 0x30 | Out-Null
} else {
  Show 'O Loloshop e o Illostrator foram removidos.' 0x40 | Out-Null
}
