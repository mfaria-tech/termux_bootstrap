#!/usr/bin/env bash

set -euo pipefail

BOOTSTRAP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# shellcheck source=scripts/utils.sh
source "$BOOTSTRAP_DIR/scripts/utils.sh"

get_packages_file() {
    case "$(get_environment)" in
        termux)
            echo "$BOOTSTRAP_DIR/packages.conf"
            ;;
        debian)
            echo "$BOOTSTRAP_DIR/packages_debian.conf"
            ;;
        *)
            return 1
            ;;
    esac
}

PACKAGES_FILE="$(get_packages_file)"

install_packages_from_file() {
  local packages_file="$1"
  local package

  [[ -f "$packages_file" ]] || die "Arquivo de pacotes não encontrado: $packages_file"

  while IFS= read -r package || [[ -n "$package" ]]; do
    package="${package%%#*}"
    package="$(trim "$package")"

    [[ -z "$package" ]] && continue
    install_package "$package"
  done < "$packages_file"
}

main() {
  require_termux
  log_info "Instalando pacotes definidos em packages.conf."
  install_packages_from_file "$PACKAGES_FILE"
  log_success "Pacotes principais verificados."
}

main "$@"
