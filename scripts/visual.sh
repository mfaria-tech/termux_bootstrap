#!/usr/bin/env bash

set -euo pipefail

BOOTSTRAP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# shellcheck source=scripts/utils.sh
source "$BOOTSTRAP_DIR/scripts/utils.sh"

main() {
  require_termux

  log_info "Aplicando configurações visuais."
  bash "$BOOTSTRAP_DIR/scripts/zsh.sh"
  bash "$BOOTSTRAP_DIR/scripts/nvim.sh"
  #bash "$BOOTSTRAP_DIR/scripts/fonts.sh"

  log_success "Customizações visuais aplicadas."
}

main "$@"
