# Loloshop

Um editor de imagens com camadas, máscaras, ajustes, texto, pincéis e arquivos PSD.

Loloshop é o [PhotoCraft](https://github.com/storytold/photocraft) (editor de imagens de código
aberto em Rust, MIT OR Apache-2.0) com outro nome, outro ícone e sem os links e o atualizador do
ArtCraft. Este repositório não guarda uma cópia do PhotoCraft: guarda só as mudanças, e toda
semana o GitHub Actions aplica essas mudanças no PhotoCraft mais novo, compila e publica um
Release. Assim as novidades do PhotoCraft chegam sozinhas.

## Instalar

No PowerShell:

```powershell
irm https://raw.githubusercontent.com/PimentaBrrt/loloshop/main/install/instalar.ps1 | iex
```

Isso coloca o Loloshop no Menu Iniciar e na Área de Trabalho e liga a atualização automática
(ao entrar no Windows e todo dia ao meio-dia). Com o app aberto, a versão nova espera ele fechar.
O log fica em `%LOCALAPPDATA%\Programs\Loloshop\atualizar.log`. Para remover:
`%LOCALAPPDATA%\Programs\Loloshop\desinstalar.ps1`.

## Como funciona

| Arquivo | O que faz |
|---|---|
| `layer/rename.sh` | Troca "PhotoCraft" por "Loloshop" nos fontes Rust e nas traduções (com algumas exceções, explicadas no script) |
| `layer/loloshop.patch` | As mudanças de código feitas à mão: menu Ajuda, tela inicial, Sobre, atualizador desligado, metadados do `.exe`, uma tradução |
| `layer/BASE` | O commit do PhotoCraft em que o patch foi feito |
| `layer/overlay/` | Arquivos que substituem os do PhotoCraft (o ícone) |
| `layer/build-tree.sh` | Monta a árvore do Loloshop a partir de um commit do PhotoCraft |
| `layer/make-patch.sh` | Salva mudanças de código como o novo `loloshop.patch` |
| `.github/workflows/release.yml` | Todo domingo: monta, compila, testa e publica o Release |
| `install/` | Instalação e atualização no PC dela |

O workflow só publica quando o PhotoCraft ou a camada mudaram, e só se a compilação e os testes
passarem. Se algo falhar, a última versão continua sendo a que ela recebe, e o GitHub manda um
e-mail avisando da falha.

## Compilar no Windows

Precisa do Rust e do Visual Studio Build Tools (C++). No Git Bash, monte a árvore; no PowerShell,
compile (no Git Bash, o `link` do coreutils atrapalha o linker do MSVC):

```bash
layer/build-tree.sh upstream main
```

```powershell
cd upstream; cargo run --release -p photocraft
```

## Quando o patch para de aplicar

Se o PhotoCraft mudar um dos arquivos que o patch altera, o workflow falha com `conflict: <arquivo>`.
Para consertar:

```bash
layer/build-tree.sh upstream main          # falha e mostra os arquivos em conflito
cd upstream
git cherry-pick refs/loloshop/layer
# resolva os conflitos nos arquivos, depois:
git add -A && git -c user.name=x -c user.email=x@x cherry-pick --continue
cd .. && layer/make-patch.sh upstream      # grava o novo patch e o novo BASE
git add layer && git commit -m "Atualiza o patch" && git push
```

O push dispara uma build nova.

## Licença

O código do PhotoCraft é MIT OR Apache-2.0 (veja o `NOTICE` e as licenças na árvore montada).
As mudanças e o ícone deste repositório seguem a mesma licença dupla.
