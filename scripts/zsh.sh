#!/usr/bin/env bash

set -euo pipefail

BOOTSTRAP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# shellcheck source=scripts/utils.sh
source "$BOOTSTRAP_DIR/scripts/utils.sh"

OH_MY_ZSH_DIR="$HOME/.oh-my-zsh"
ZSH_CUSTOM_DIR="${ZSH_CUSTOM:-$OH_MY_ZSH_DIR/custom}"

install_oh_my_zsh() {
  if [[ -d "$OH_MY_ZSH_DIR" ]]; then
    log_success "Oh My Zsh já instalado."
    return 0
  fi

  log_info "Instalando Oh My Zsh."
  git clone https://github.com/ohmyzsh/ohmyzsh.git "$OH_MY_ZSH_DIR"
  log_success "Oh My Zsh instalado."
}

install_zsh_plugin() {
  local name="$1"
  local repo="$2"
  local target="$ZSH_CUSTOM_DIR/plugins/$name"

  if [[ -d "$target/.git" ]]; then
    log_info "Atualizando plugin ZSH: $name"
    git -C "$target" pull --ff-only
  else
    log_info "Instalando plugin ZSH: $name"
    git clone "$repo" "$target"
  fi

  log_success "Plugin ZSH pronto: $name"
}

install_powerlevel10k() {
  local target="$ZSH_CUSTOM_DIR/themes/powerlevel10k"

  if [[ -d "$target/.git" ]]; then
    log_info "Atualizando Powerlevel10k."
    git -C "$target" pull --ff-only
  else
    log_info "Instalando Powerlevel10k."
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$target"
  fi

  log_success "Powerlevel10k pronto."
}

configure_zsh_files() {
  copy_file_if_changed "$BOOTSTRAP_DIR/configs/zsh/.zshrc" "$HOME/.zshrc"
  copy_file_if_changed "$BOOTSTRAP_DIR/configs/zsh/.p10k.zsh" "$HOME/.p10k.zsh"
}

configure_default_shell() {
  local zsh_path
  zsh_path="$(command -v zsh)"

  if command_exists chsh; then
    log_info "Definindo ZSH como shell padrão."
    chsh -s "$zsh_path" || log_warning "Não foi possível alterar o shell automaticamente."
  else
    log_warning "chsh não encontrado. Abra o ZSH executando: zsh"
  fi

  if [[ -z "$zsh_path" ]]; then
    log_error "ZSH não encontrado."
    return 1
  fi

  mkdir -p "$HOME/.termux"

  echo "$zsh_path" > "$HOME/.termux/shell"

  log_success "ZSH definido como shell padrão do Termux."

  if [[ "${SHELL:-}" != "$zsh_path" ]]; then
    export SHELL="$zsh_path"
  else
    log_success "ZSH já e o shell atual."
    return 0
  fi

  log_info "Reinicie o Termux para aplicar a alteração."
}

main() {
  require_termux
  command_exists git || install_package git
  command_exists zsh || install_package zsh

  install_oh_my_zsh
  install_powerlevel10k
  install_zsh_plugin "zsh-autosuggestions" "https://github.com/zsh-users/zsh-autosuggestions.git"
  install_zsh_plugin "zsh-syntax-highlighting" "https://github.com/zsh-users/zsh-syntax-highlighting.git"
  configure_zsh_files
  configure_default_shell
}

main "$@"
