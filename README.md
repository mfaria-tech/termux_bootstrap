# termux-bootstrap

Instalador básico para automatizar a configuração inicial de um ambiente Termux no Android.

## Recursos

- Atualização do sistema com `pkg update` e `pkg upgrade`.
- Instalação de pacotes definidos em `packages.conf`.
- Fluxo opcional para aplicativos PDA configurados em `apps/apps.json`.
- Customizações opcionais para ZSH, Oh My Zsh, Powerlevel10k, Neovim, Nerd Fonts e LunarVim.
- Logs para informação, sucesso, aviso e erro.
- Funções reutilizáveis em `scripts/utils.sh`.

## Requisitos

- Android com Termux instalado.
- Permissão de armazenamento configurada se você pretende trabalhar com arquivos fora do `$HOME` do Termux.

Opcionalmente, execute:

```bash
termux-setup-storage
```

## Instalação

Clone o repositório e execute o instalador:

```bash
git clone https://github.com/seu-usuario/termux-bootstrap.git
cd termux-bootstrap
chmod +x install.sh scripts/*.sh
./install.sh
```

Também é possível executar etapas específicas:

```bash
bash scripts/update.sh
bash scripts/packages.sh
bash scripts/zsh.sh
bash scripts/nvim.sh
bash scripts/fonts.sh
```

## Estrutura de diretórios

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

## Personalização de pacotes

Edite `packages.conf` para adicionar ou remover pacotes. Cada linha representa um pacote do Termux. Linhas vazias e comentários iniciados com `#` são ignorados.

Exemplo:

```conf
git
neovim
python
```

O instalador verifica cada pacote com `dpkg -s` antes de instalar, evitando reinstalações desnecessárias.

## Aplicativos PDA

A etapa PDA é opcional. Para usá-la, defina a URL do repositório antes de rodar o instalador:

```bash
export PDA_REPO_URL="https://github.com/seu-usuario/seu-repositorio-pda.git"
export PDA_DIR="$HOME/pda-apps"
./install.sh
```

Você também pode configurar diretamente em `apps/apps.json`:

```json
{
  "repository": {
    "url": "https://github.com/seu-usuario/seu-repositorio-pda.git",
    "target_dir": "$HOME/pda-apps"
  }
}
```

O arquivo `apps/apps.json` controla quais aplicativos serão instalados:

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
- `check_command`: comando usado para detectar se o app já está instalado.
- `working_dir`: diretório onde o comando será executado.
- `install`: comando de instalação.

## Customizações visuais

Ao confirmar a etapa visual, o instalador executa:

- instalação do Oh My Zsh;
- instalação do tema Powerlevel10k;
- instalação dos plugins `zsh-autosuggestions` e `zsh-syntax-highlighting`;
- aplicação de `.zshrc` e `.p10k.zsh`;
- configuração inicial do Neovim;
- instalação opcional de Meslo Nerd Font e Fira Code Nerd Font;
- instalação opcional do LunarVim.

## Neovim

A configuração em `configs/nvim/init.lua` habilita:

- números de linha;
- números relativos;
- indentação com 4 espaços;
- cores true color;
- clipboard;
- leader key com espaco;
- atalhos básicos para salvar, sair, limpar busca e abrir explorador.

## LunarVim

O LunarVim só é oferecido quando o Neovim está instalado. Se `lvim` já existir no sistema, a instalação é ignorada.

## Solução de problemas

### `pkg` não encontrado

Execute o projeto dentro do Termux. O instalador depende do gerenciador de pacotes do Termux.

### Fonte não mudou

Reinicie o Termux. Em alguns dispositivos, `termux-reload-settings` pode não estar disponível ou não recarregar a fonte imediatamente.

### Erro ao instalar pacote

Atualize os repositórios e rode novamente:

```bash
pkg update -y
pkg upgrade -y
./install.sh
```

### PDA_REPO_URL não definido

Defina a variável antes de confirmar a etapa PDA:

```bash
export PDA_REPO_URL="https://github.com/seu-usuario/seu-repositorio-pda.git"
```

### Clipboard no Neovim

O suporte a clipboard no Termux pode exigir pacotes adicionais ou integração com o app Termux:API, dependendo do dispositivo.

## Roadmap

- Perfil de instalação mínimo, padrão e completo.
- Backup automático antes de sobrescrever configurações.
- Suporte a dry-run.
- Instalação opcional de linguagens extras.
- Validação JSON mais detalhada para `apps/apps.json`.
- Testes automatizados com ShellCheck e bats.

## Publicação no GitHub

Antes de publicar:

```bash
chmod +x install.sh scripts/*.sh
shellcheck install.sh scripts/*.sh
git init
git add .
git commit -m "Initial termux bootstrap"
```

O projeto está organizado para ser usado diretamente como repositório GitHub.
