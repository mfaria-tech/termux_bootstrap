#!/usr/bin/env bash

set -euo pipefail

BOOTSTRAP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# shellcheck source=scripts/utils.sh
source "$BOOTSTRAP_DIR/scripts/utils.sh"

FONT_DIR="$HOME/.termux"
FONT_TARGET="$FONT_DIR/font.ttf"
NERD_FONTS_BASE_URL="https://github.com/ryanoasis/nerd-fonts/releases/latest/download"

download_font() {
  local font_name="$1"
  local archive_name="$2"
  local font_file="$3"
  local temp_dir

  temp_dir="$(mktemp -d)"

  log_info "Baixando $font_name."
  curl -fL "$NERD_FONTS_BASE_URL/$archive_name" -o "$temp_dir/$archive_name"

  unzip -o "$temp_dir/$archive_name" "$font_file" -d "$temp_dir" >/dev/null
  ensure_directory "$FONT_DIR"
  cp "$temp_dir/$font_file" "$FONT_TARGET"
  rm -rf "$temp_dir"

  log_success "$font_name instalado como fonte ativa do Termux."
}

install_meslo_font() {
  download_font "Meslo Nerd Font" "Meslo.zip" "MesloLGS NF Regular.ttf"
}

install_fira_code_font() {
  download_font "Fira Code Nerd Font" "FiraCode.zip" "FiraCodeNerdFont-Regular.ttf"
}

reload_termux_settings() {
  if command_exists termux-reload-settings; then
    termux-reload-settings
    log_success "Configuracoes visuais do Termux recarregadas."
  else
    log_warning "termux-reload-settings nao encontrado. Reinicie o Termux para aplicar a fonte."
  fi
}

main() {
  require_termux
  command_exists curl || install_package curl
  command_exists unzip || install_package unzip

  if ask_yes_no "Deseja instalar Meslo Nerd Font?" "y"; then
    install_meslo_font
  fi

  if ask_yes_no "Deseja instalar Fira Code Nerd Font?" "n"; then
    install_fira_code_font
  fi

  reload_termux_settings
}

main "$@"
