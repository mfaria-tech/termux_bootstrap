#!/usr/bin/env bash

set -euo pipefail

BOOTSTRAP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# shellcheck source=scripts/utils.sh
source "$BOOTSTRAP_DIR/scripts/utils.sh"

NVIM_CONFIG_DIR="$HOME/.config/nvim"
LVIM_INSTALL_URL="https://raw.githubusercontent.com/LunarVim/LunarVim/master/utils/installer/install.sh"

configure_neovim() {
  command_exists nvim || install_package neovim

  ensure_directory "$NVIM_CONFIG_DIR"
  copy_file_if_changed "$BOOTSTRAP_DIR/configs/nvim/init.lua" "$NVIM_CONFIG_DIR/init.lua"
}

install_lunarvim() {
  command_exists nvim || die "Neovim nao esta instalado corretamente."
  command_exists git || install_package git
  command_exists curl || install_package curl

  if command_exists lvim; then
    log_success "LunarVim ja instalado."
    return 0
  fi

  if ask_yes_no "Deseja instalar LunarVim?" "n"; then
    log_info "Instalando LunarVim."
    bash <(curl -fsSL "$LVIM_INSTALL_URL")
    log_success "LunarVim instalado."
  else
    log_warning "Instalacao do LunarVim ignorada."
  fi
}

main() {
  require_termux
  configure_neovim
  install_lunarvim
}

main "$@"
