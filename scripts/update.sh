#!/usr/bin/env bash

set -euo pipefail

BOOTSTRAP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# shellcheck source=scripts/utils.sh
source "$BOOTSTRAP_DIR/scripts/utils.sh"

main() {
  require_termux

  log_info "Atualizando índices de pacotes."
  pkg update -y

  log_info "Atualizando pacotes instalados."
  pkg upgrade -y

  log_success "Sistema atualizado."
}

main "$@"
