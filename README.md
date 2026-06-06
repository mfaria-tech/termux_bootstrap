# termux-bootstrap

Instalador modular para automatizar a configuracao inicial de um ambiente Termux no Android. O projeto foi pensado para ser simples de auditar, facil de personalizar e seguro para executar mais de uma vez.

## Recursos

- Atualizacao do sistema com `pkg update` e `pkg upgrade`.
- Instalacao idempotente de pacotes definidos em `packages.conf`.
- Fluxo opcional para aplicativos PDA configurados em `apps/apps.json`.
- Customizacoes opcionais para ZSH, Oh My Zsh, Powerlevel10k, Neovim, Nerd Fonts e LunarVim.
- Logs coloridos para informacao, sucesso, aviso e erro.
- Funcoes reutilizaveis em `scripts/utils.sh`.

## Requisitos

- Android com Termux instalado.
- Conexao com a internet.
- Permissao de armazenamento configurada se voce pretende trabalhar com arquivos fora do `$HOME` do Termux.

Opcionalmente, execute:

```bash
termux-setup-storage
```

## Instalacao

Clone o repositorio e execute o instalador:

```bash
git clone https://github.com/seu-usuario/termux-bootstrap.git
cd termux-bootstrap
chmod +x install.sh scripts/*.sh
./install.sh
```

Tambem e possivel executar etapas especificas:

```bash
bash scripts/update.sh
bash scripts/packages.sh
bash scripts/zsh.sh
bash scripts/nvim.sh
bash scripts/fonts.sh
```

## Estrutura de diretorios

```text
termux-bootstrap/
+-- install.sh
+-- README.md
+-- scripts/
|   +-- update.sh
|   +-- packages.sh
|   +-- pda.sh
|   +-- visual.sh
|   +-- fonts.sh
|   +-- zsh.sh
|   +-- nvim.sh
|   +-- utils.sh
+-- configs/
|   +-- zsh/
|   |   +-- .zshrc
|   |   +-- .p10k.zsh
|   +-- nvim/
|       +-- init.lua
+-- packages.conf
+-- apps/
    +-- apps.json
```

## Personalizacao de pacotes

Edite `packages.conf` para adicionar ou remover pacotes. Cada linha representa um pacote do Termux. Linhas vazias e comentarios iniciados com `#` sao ignorados.

Exemplo:

```conf
git
neovim
python
```

O instalador verifica cada pacote com `dpkg -s` antes de instalar, evitando reinstalacoes desnecessarias.

## Aplicativos PDA

A etapa PDA e opcional. Para usa-la, defina a URL do repositorio antes de rodar o instalador:

```bash
export PDA_REPO_URL="https://github.com/seu-usuario/seu-repositorio-pda.git"
export PDA_DIR="$HOME/pda-apps"
./install.sh
```

Voce tambem pode configurar diretamente em `apps/apps.json`:

```json
{
  "repository": {
    "url": "https://github.com/seu-usuario/seu-repositorio-pda.git",
    "target_dir": "$HOME/pda-apps"
  }
}
```

O arquivo `apps/apps.json` controla quais aplicativos serao instalados:

```json
{
  "apps": [
    {
      "name": "meu-app",
      "enabled": true,
      "check_command": "meu-app",
      "working_dir": "$PDA_DIR/meu-app",
      "install": "bash install.sh"
    }
  ]
}
```

Campos:

- `name`: nome exibido nos logs.
- `enabled`: use `false` para manter o app registrado sem instalar.
- `check_command`: comando usado para detectar se o app ja esta instalado.
- `working_dir`: diretorio onde o comando sera executado.
- `install`: comando de instalacao.

## Customizacoes visuais

Ao confirmar a etapa visual, o instalador executa:

- instalacao do Oh My Zsh;
- instalacao do tema Powerlevel10k;
- instalacao dos plugins `zsh-autosuggestions` e `zsh-syntax-highlighting`;
- aplicacao de `.zshrc` e `.p10k.zsh`;
- configuracao inicial do Neovim;
- instalacao opcional de Meslo Nerd Font e Fira Code Nerd Font;
- instalacao opcional do LunarVim.

## Neovim

A configuracao em `configs/nvim/init.lua` habilita:

- numeros de linha;
- numeros relativos;
- indentacao com 4 espacos;
- cores true color;
- clipboard;
- leader key com espaco;
- atalhos basicos para salvar, sair, limpar busca e abrir explorador.

## LunarVim

O LunarVim so e oferecido quando o Neovim esta instalado. Se `lvim` ja existir no sistema, a instalacao e ignorada.

## Solucao de problemas

### `pkg` nao encontrado

Execute o projeto dentro do Termux. O instalador depende do gerenciador de pacotes do Termux.

### Fonte nao mudou

Reinicie o Termux. Em alguns dispositivos, `termux-reload-settings` pode nao estar disponivel ou nao recarregar a fonte imediatamente.

### Erro ao instalar pacote

Atualize os repositorios e rode novamente:

```bash
pkg update -y
pkg upgrade -y
./install.sh
```

### PDA_REPO_URL nao definido

Defina a variavel antes de confirmar a etapa PDA:

```bash
export PDA_REPO_URL="https://github.com/seu-usuario/seu-repositorio-pda.git"
```

### Clipboard no Neovim

O suporte a clipboard no Termux pode exigir pacotes adicionais ou integracao com o app Termux:API, dependendo do dispositivo.

## Roadmap

- Perfil de instalacao minimo, padrao e completo.
- Backup automatico antes de sobrescrever configuracoes.
- Suporte a dry-run.
- Instalacao opcional de linguagens extras.
- Validacao JSON mais detalhada para `apps/apps.json`.
- Testes automatizados com ShellCheck e bats.

## Publicacao no GitHub

Antes de publicar:

```bash
chmod +x install.sh scripts/*.sh
shellcheck install.sh scripts/*.sh
git init
git add .
git commit -m "Initial termux bootstrap"
```

O projeto esta organizado para ser usado diretamente como repositorio GitHub.
