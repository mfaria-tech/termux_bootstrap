#!/usr/bin/env bash

set -euo pipefail

if [[ -z "${BOOTSTRAP_DIR:-}" ]]; then
  BOOTSTRAP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
fi

readonly COLOR_RESET="\033[0m"
readonly COLOR_INFO="\033[1;34m"
readonly COLOR_SUCCESS="\033[1;32m"
readonly COLOR_WARNING="\033[1;33m"
readonly COLOR_ERROR="\033[1;31m"

log_info() {
  printf "%b[INFO]%b %s\n" "$COLOR_INFO" "$COLOR_RESET" "$*"
}

log_success() {
  printf "%b[OK]%b %s\n" "$COLOR_SUCCESS" "$COLOR_RESET" "$*"
}

log_warning() {
  printf "%b[AVISO]%b %s\n" "$COLOR_WARNING" "$COLOR_RESET" "$*"
}

log_error() {
  printf "%b[ERRO]%b %s\n" "$COLOR_ERROR" "$COLOR_RESET" "$*" >&2
}

die() {
  log_error "$*"
  exit 1
}

command_exists() {
  command -v "$1" >/dev/null 2>&1
}

require_termux() {
  if [[ -z "${PREFIX:-}" || "${PREFIX:-}" != *"com.termux"* ]]; then
    log_warning "Este instalador foi projetado para Termux. Continuando mesmo assim."
  fi

  command_exists pkg || die "Comando 'pkg' não encontrado. Execute dentro do Termux."
}

ask_yes_no() {
  local prompt="$1"
  local default="${2:-n}"
  local answer
  local suffix

  case "$default" in
    y|Y) suffix="[S/n]" ;;
    n|N) suffix="[s/N]" ;;
    *) die "Valor padrão inválido para ask_yes_no: $default" ;;
  esac

  while true; do
    read -r -p "$prompt $suffix " answer || return 1
    answer="${answer:-$default}"

    case "$answer" in
      s|S|sim|SIM|y|Y|yes|YES) return 0 ;;
      n|N|nao|não|NAO|NÃO|no|NO) return 1 ;;
      *) log_warning "Responda com sim ou não." ;;
    esac
  done
}

trim() {
  local value="$1"
  value="${value#"${value%%[![:space:]]*}"}"
  value="${value%"${value##*[![:space:]]}"}"
  printf "%s" "$value"
}

check_package() {
  local package="$1"
  dpkg -s "$package" >/dev/null 2>&1
}

install_package() {
  local package="$1"

  if check_package "$package"; then
    log_success "Pacote já instalado: $package"
    return 0
  fi

  log_info "Instalando pacote: $package"
  pkg install -y "$package"
  log_success "Pacote instalado: $package"
}

ensure_directory() {
  local directory="$1"
  mkdir -p "$directory"
}

copy_file_if_changed() {
  local source_file="$1"
  local target_file="$2"

  ensure_directory "$(dirname "$target_file")"

  if [[ -f "$target_file" ]] && cmp -s "$source_file" "$target_file"; then
    log_success "Configuração já atualizada: $target_file"
    return 0
  fi

  cp "$source_file" "$target_file"
  log_success "Configuração aplicada: $target_file"
}
