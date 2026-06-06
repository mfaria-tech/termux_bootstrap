#!/usr/bin/env bash

set -euo pipefail

BOOTSTRAP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck source=scripts/utils.sh
source "$BOOTSTRAP_DIR/scripts/utils.sh"

main() {
  log_info "Iniciando configuração do Termux Bootstrap."
  require_termux

  bash "$BOOTSTRAP_DIR/scripts/update.sh"
  bash "$BOOTSTRAP_DIR/scripts/packages.sh"

  if ask_yes_no "Deseja instalar aplicativos PDA?" "n"; then
    bash "$BOOTSTRAP_DIR/scripts/pda.sh"
  else
    log_warning "Instalação de aplicativos PDA ignorada."
  fi

  if ask_yes_no "Deseja aplicar customizações visuais?" "n"; then
    bash "$BOOTSTRAP_DIR/scripts/visual.sh"
  else
    log_warning "Customizações visuais ignoradas."
  fi

  log_success "Termux Bootstrap finalizado com sucesso."
}

main "$@"
