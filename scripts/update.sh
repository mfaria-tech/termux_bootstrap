#!/usr/bin/env bash

set -euo pipefail

BOOTSTRAP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# shellcheck source=scripts/utils.sh
source "$BOOTSTRAP_DIR/scripts/utils.sh"

main() {
  require_termux

  log_info "Atualizando índices de pacotes."
  case "$(get_environment)" in
    "$ENV_TERMUX")
      pkg update -y
      ;;
    "$ENV_DEBIAN")
      apt update -y
      ;;
    *)
      return 1
      ;;
  esac

  log_info "Atualizando pacotes instalados."
  case "$(get_environment)" in
    "$ENV_TERMUX")
      pkg upgrade -y
      ;;
    "$ENV_DEBIAN")
      apt upgrade -y
      ;;
    *)
      return 1
      ;;
  esac

  log_success "Sistema atualizado."
}

main "$@"
