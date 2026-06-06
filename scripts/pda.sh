#!/usr/bin/env bash

set -euo pipefail

BOOTSTRAP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# shellcheck source=scripts/utils.sh
source "$BOOTSTRAP_DIR/scripts/utils.sh"

APPS_FILE="$BOOTSTRAP_DIR/apps/apps.json"
PDA_REPO_URL="${PDA_REPO_URL:-}"
PDA_DIR="${PDA_DIR:-}"

load_pda_config() {
  local apps_file="$1"
  local configured_repo_url
  local configured_target_dir

  [[ -f "$apps_file" ]] || die "Arquivo apps.json não encontrado: $apps_file"
  command_exists jq || install_package jq

  configured_repo_url="$(jq -r '.repository.url // empty' "$apps_file")"
  configured_target_dir="$(jq -r '.repository.target_dir // "$HOME/pda-apps"' "$apps_file")"

  PDA_REPO_URL="${PDA_REPO_URL:-$configured_repo_url}"
  PDA_DIR="${PDA_DIR:-$configured_target_dir}"
  PDA_DIR="${PDA_DIR/\$HOME/$HOME}"
  PDA_DIR="${PDA_DIR:-$HOME/pda-apps}"
}

clone_or_update_repo() {
  local repo_url="$1"
  local target_dir="$2"

  [[ -n "$repo_url" ]] || die "Defina PDA_REPO_URL antes de instalar os aplicativos PDA."

  if [[ -d "$target_dir/.git" ]]; then
    log_info "Atualizando repositório PDA em $target_dir."
    git -C "$target_dir" pull --ff-only
  else
    log_info "Clonando repositório PDA em $target_dir."
    git clone "$repo_url" "$target_dir"
  fi
}

install_app() {
  local name="$1"
  local command_to_run="$2"
  local working_dir="$3"
  local check_command="$4"

  if [[ -n "$check_command" ]] && command_exists "$check_command"; then
    log_success "Aplicativo PDA já instalado: $name"
    return 0
  fi

  log_info "Instalando aplicativo PDA: $name"

  if [[ -n "$working_dir" ]]; then
    (cd "$working_dir" && bash -lc "$command_to_run")
  else
    bash -lc "$command_to_run"
  fi

  log_success "Aplicativo PDA instalado: $name"
}

install_apps_from_json() {
  local apps_file="$1"
  local apps_length
  local index
  local name
  local enabled
  local install_command
  local working_dir
  local check_command

  [[ -f "$apps_file" ]] || die "Arquivo apps.json não encontrado: $apps_file"

  apps_length="$(jq '.apps | length' "$apps_file")"

  for ((index = 0; index < apps_length; index++)); do
    enabled="$(jq -r ".apps[$index].enabled // true" "$apps_file")"
    [[ "$enabled" == "true" ]] || continue

    name="$(jq -r ".apps[$index].name" "$apps_file")"
    install_command="$(jq -r ".apps[$index].install" "$apps_file")"
    working_dir="$(jq -r ".apps[$index].working_dir // empty" "$apps_file")"
    check_command="$(jq -r ".apps[$index].check_command // empty" "$apps_file")"

    [[ "$name" != "null" && -n "$name" ]] || die "Aplicativo PDA sem nome no índice $index."
    [[ "$install_command" != "null" && -n "$install_command" ]] || die "Aplicativo PDA sem comando de instalação: $name."

    working_dir="${working_dir/\$PDA_DIR/$PDA_DIR}"
    install_app "$name" "$install_command" "$working_dir" "$check_command"
  done
}

main() {
  require_termux
  command_exists git || install_package git
  command_exists jq || install_package jq

  load_pda_config "$APPS_FILE"
  clone_or_update_repo "$PDA_REPO_URL" "$PDA_DIR"
  install_apps_from_json "$APPS_FILE"
}

main "$@"
