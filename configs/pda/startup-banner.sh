#!/usr/bin/env bash

# PDA Boot Screen for Termux + ZSH.
# It is intentionally local-first and fast: no network calls unless enabled.

pda_stop_boot() {
  return 0 2>/dev/null || exit 0
}

[[ "${PDA_BOOT_SCREEN:-1}" == "0" ]] && pda_stop_boot
[[ -n "${PDA_BOOT_SCREEN_SHOWN:-}" ]] && pda_stop_boot
export PDA_BOOT_SCREEN_SHOWN=1
export PDA_SESSION_STARTED="${PDA_SESSION_STARTED:-$(date +%s)}"

PDA_CONFIG_DIR="${PDA_CONFIG_DIR:-$HOME/.config/pda}"
PDA_THEME_FILE="$PDA_CONFIG_DIR/theme.sh"
PDA_MESSAGES_FILE="$PDA_CONFIG_DIR/cute_messages.txt"
PDA_LOGO_FILE="$PDA_CONFIG_DIR/ascii/logo.txt"
PDA_MASCOT_FILE="$PDA_CONFIG_DIR/ascii/mascot.txt"
PDA_CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/pda"
PDA_COLUMNS="${COLUMNS:-$(tput cols 2>/dev/null || printf "80")}"

[[ -f "$PDA_THEME_FILE" ]] && source "$PDA_THEME_FILE"

PDA_RESET="${PDA_RESET:-$'\033[0m'}"
PDA_BOLD="${PDA_BOLD:-$'\033[1m'}"
PDA_DIM="${PDA_DIM:-$'\033[2m'}"
PDA_LAVENDER="${PDA_LAVENDER:-$'\033[38;5;183m'}"
PDA_PINK="${PDA_PINK:-$'\033[38;5;218m'}"
PDA_YELLOW="${PDA_YELLOW:-$'\033[38;5;229m'}"
PDA_MINT="${PDA_MINT:-$'\033[38;5;194m'}"
PDA_WHITE="${PDA_WHITE:-$'\033[38;5;15m'}"
PDA_DARK_LAVENDER="${PDA_DARK_LAVENDER:-$'\033[38;5;60m'}"
PDA_MOON_PURPLE="${PDA_MOON_PURPLE:-$'\033[38;5;97m'}"

pda_term_width() {
  local width="$PDA_COLUMNS"
  [[ "$width" =~ ^[0-9]+$ ]] || width=80
  (( width > 80 )) && width=80
  (( width < 44 )) && width=44
  printf "%s" "$width"
}

pda_repeat() {
  local char="$1"
  local count="$2"
  local out=""
  local i
  for ((i = 0; i < count; i++)); do
    out+="$char"
  done
  printf "%s" "$out"
}

pda_cmd() {
  command -v "$1" >/dev/null 2>&1
}

pda_safe_read() {
  local file="$1"
  [[ -r "$file" ]] && head -n 1 "$file" 2>/dev/null || printf ""
}

pda_human_seconds() {
  local seconds="$1"
  local minutes=$(( seconds / 60 ))
  local hours=$(( minutes / 60 ))
  if (( hours > 0 )); then
    printf "%dh %02dm" "$hours" "$(( minutes % 60 ))"
  elif (( minutes > 0 )); then
    printf "%dm %02ds" "$minutes" "$(( seconds % 60 ))"
  else
    printf "%ds" "$seconds"
  fi
}

pda_visible_len() {
  local text="$1"
  printf "%s" "$text" | pda_strip_ansi | wc -m | tr -d " "
}

pda_strip_ansi() {
  sed -E $'s/\x1B\\[[0-9;]*[A-Za-z]//g'
}

pda_center() {
  local text="$1"
  local width="${2:-$(pda_term_width)}"
  local length padding
  length="$(pda_visible_len "$text")"
  padding=$(( (width - length) / 2 ))
  (( padding < 0 )) && padding=0
  printf "%*s%s\n" "$padding" "" "$text"
}

pda_line() {
  local width="${1:-$(pda_term_width)}"
  printf "%b%s%b\n" "$PDA_DARK_LAVENDER" "$(pda_repeat "─" "$width")" "$PDA_RESET"
}

pda_box_line() {
  local label="$1"
  local value="$2"
  local width="${3:-$(pda_term_width)}"
  local content="${label} ${value}"
  local length pad max_content
  max_content=$(( width - 4 ))
  length="$(pda_visible_len "$content")"
  if (( length > max_content )); then
    content="$(printf "%s" "$content" | pda_strip_ansi | cut -c 1-$(( max_content - 3 )))..."
    length="$(pda_visible_len "$content")"
  fi
  pad=$(( width - length - 4 ))
  (( pad < 1 )) && pad=1
  printf "%b║%b %s%*s %b║%b\n" "$PDA_MOON_PURPLE" "$PDA_RESET" "$content" "$pad" "" "$PDA_MOON_PURPLE" "$PDA_RESET"
}

pda_get_ip() {
  local ip_addr=""
  if pda_cmd ip; then
    ip_addr="$(ip -o -4 addr show scope global 2>/dev/null | awk '{split($4,a,"/"); print a[1]; exit}')"
  elif pda_cmd ifconfig; then
    ip_addr="$(
      ifconfig 2>/dev/null |
      awk '/inet / && $2 != "127.0.0.1" { print $2; exit }'
    )"
  fi
  [[ -n "$ip_addr" ]] && printf "%s" "$ip_addr" || printf "offline"
}

pda_get_model() {
  local model=""
  if pda_cmd getprop; then
    model="$(getprop ro.product.model 2>/dev/null)"
  fi
  [[ -n "$model" ]] && printf "%s" "$model" || printf "Android device"
}

pda_get_android_version() {
  local version=""
  if pda_cmd getprop; then
    version="$(getprop ro.build.version.release 2>/dev/null)"
  fi
  [[ -n "$version" ]] && printf "Android %s" "$version" || printf "Android"
}

pda_get_shell() {
  if [[ -n "${ZSH_VERSION:-}" ]]; then
    printf "zsh %s" "$ZSH_VERSION"
  else
    basename "${SHELL:-shell}"
  fi
}

pda_get_python() {
  pda_cmd python && python --version 2>/dev/null | awk '{print $2}' || printf "not found"
}

pda_get_node() {
  pda_cmd node && node --version 2>/dev/null || printf "not found"
}

pda_get_storage() {
  df -h "$HOME" 2>/dev/null | awk 'NR==2 {print $4 " free / " $5 " used"}'
}

pda_get_memory() {
  awk '
    /MemTotal/ {total=$2}
    /MemAvailable/ {available=$2}
    END {
      if (total > 0) {
        used=total-available
        printf "%d%% used", (used*100)/total
      } else {
        printf "unknown"
      }
    }
  ' /proc/meminfo 2>/dev/null
}

pda_get_battery_field() {
  local field="$1"
  local value=""
  if pda_cmd termux-battery-status; then
    value="$(termux-battery-status 2>/dev/null | awk -F'[:,]' -v key="\"$field\"" '$1 ~ key {gsub(/[ \"}]/,"",$2); print $2; exit}')"
  fi
  if [[ -z "$value" ]]; then
    case "$field" in
      percentage) value="$(pda_safe_read /sys/class/power_supply/battery/capacity)" ;;
      temperature) value="$(pda_safe_read /sys/class/power_supply/battery/temp)" ;;
    esac
  fi
  printf "%s" "$value"
}

pda_get_battery_percent() {
  local percent
  percent="$(pda_get_battery_field percentage)"
  [[ -n "$percent" ]] && printf "%s%%" "$percent" || printf "unknown"
}

pda_get_battery_temp() {
  local temp
  temp="$(pda_get_battery_field temperature)"
  if [[ "$temp" =~ ^[0-9]+$ ]]; then
    if (( temp > 1000 )); then
      printf "%s.%s C" "$(( temp / 10 ))" "$(( temp % 10 ))"
    else
      printf "%s C" "$temp"
    fi
  elif [[ "$temp" =~ ^[0-9]+([.][0-9]+)?$ ]]; then
    printf "%s C" "$temp"
  else
    printf "unavailable"
  fi
}

pda_moon_phase() {
  local day month year yy mm k phase index
  day="$(date +%d)"
  month="$(date +%m)"
  year="$(date +%Y)"
  yy="$year"
  mm="$month"
  if (( mm < 3 )); then
    yy=$(( yy - 1 ))
    mm=$(( mm + 12 ))
  fi
  k=$(( yy / 100 ))
  phase=$(( (((((yy % 100) * 5) / 4) + (((mm + 1) * 13) / 5) + day - k + (k / 4) + 15) % 30 )))
  index=$(( phase / 4 ))
  case "$index" in
    0) printf "new moon" ;;
    1) printf "waxing crescent" ;;
    2) printf "first quarter" ;;
    3) printf "waxing gibbous" ;;
    4) printf "full moon" ;;
    5) printf "waning gibbous" ;;
    6) printf "last quarter" ;;
    *) printf "waning crescent" ;;
  esac
}

pda_pending_tasks() {
  local tasks_file="${PDA_TASKS_FILE:-$PDA_CONFIG_DIR/tasks.txt}"
  [[ -f "$tasks_file" ]] || { printf "0"; return; }
  grep -cE '^[[:space:]]*(- \[ \]|\[ \]|TODO|todo)' "$tasks_file" 2>/dev/null || printf "0"
}

pda_pomodoros_today() {
  local log_file="${PDA_POMODORO_FILE:-$PDA_CONFIG_DIR/pomodoros.log}"
  local today
  today="$(date +%F)"
  [[ -f "$log_file" ]] || { printf "0"; return; }
  grep -c "^$today" "$log_file" 2>/dev/null || printf "0"
}

pda_weather_widget() {
  [[ "${PDA_ENABLE_WEATHER:-0}" == "1" ]] || return 0
  [[ -n "${PDA_WEATHER_CMD:-}" ]] || return 0
  if pda_cmd ping && ping -c 1 -W 1 1.1.1.1 >/dev/null 2>&1; then
    eval "$PDA_WEATHER_CMD" 2>/dev/null | head -n 1
  fi
}

print_header() {
  local width inner
  width="$(pda_term_width)"
  inner=$(( width - 2 ))
  printf "%b╔%s╗%b\n" "$PDA_MOON_PURPLE" "$(pda_repeat "═" "$inner")" "$PDA_RESET"
  pda_box_line "${PDA_BOLD}PDA TERMINAL SYSTEM${PDA_RESET}" "${PDA_DIM}v1.0 pastel boot${PDA_RESET}" "$width"
  printf "%b╚%s╝%b\n" "$PDA_MOON_PURPLE" "$(pda_repeat "═" "$inner")" "$PDA_RESET"
}

print_ascii_logo() {
  local i=0
  local line
  local color
  local width
  width="$(pda_term_width)"
  if (( width < 70 )); then
    pda_center "${PDA_LAVENDER}${PDA_BOLD}█▄ ▄█ █▀ █▀█ █▀█ █ ▄▀█${PDA_RESET}" "$width"
    pda_center "${PDA_PINK}${PDA_BOLD}MFARIA TECH${PDA_RESET}" "$width"
    return 0
  fi

  if [[ -f "$PDA_LOGO_FILE" ]]; then
    while IFS= read -r line; do
      case $(( i % 3 )) in
        0) color="$PDA_LAVENDER" ;;
        1) color="$PDA_PINK" ;;
        *) color="$PDA_MOON_PURPLE" ;;
      esac
      printf "%b%s%b\n" "$color" "$line" "$PDA_RESET"
      i=$(( i + 1 ))
    done < "$PDA_LOGO_FILE"
  else
    pda_center "${PDA_LAVENDER}${PDA_BOLD}MFARIA TECH${PDA_RESET}"
  fi
}

print_battery() {
  pda_box_line "${PDA_ICON_BATTERY:-🔋} Battery:" "${PDA_WHITE}$(pda_get_battery_percent)${PDA_RESET}"
  pda_box_line "${PDA_ICON_TEMP:-🌡️} Temp:" "${PDA_WHITE}$(pda_get_battery_temp)${PDA_RESET}"
}

print_storage() {
  pda_box_line "${PDA_ICON_DISK:-💾} Storage:" "${PDA_WHITE}$(pda_get_storage)${PDA_RESET}"
  pda_box_line "${PDA_ICON_RAM:-🧠} RAM:" "${PDA_WHITE}$(pda_get_memory)${PDA_RESET}"
}

print_system_info() {
  local now_date now_time session_now session_uptime weather
  now_date="$(date '+%d/%m/%Y')"
  now_time="$(date '+%H:%M:%S')"
  session_now="$(date +%s)"
  session_uptime="$(pda_human_seconds "$(( session_now - PDA_SESSION_STARTED ))")"

  pda_box_line "${PDA_ICON_MOON:-🌙} Nome:" "${PDA_WHITE}Marcus Faria${PDA_RESET}"
  pda_box_line "${PDA_ICON_BOLT:-⚡} GitHub:" "${PDA_WHITE}github.com/mfaria-tech${PDA_RESET}"
  pda_box_line "${PDA_ICON_CAL:-📅} Data:" "${PDA_WHITE}$now_date${PDA_RESET}"
  pda_box_line "${PDA_ICON_CLOCK:-🕒} Hora:" "${PDA_WHITE}$now_time | sessao $session_uptime${PDA_RESET}"
  pda_box_line "${PDA_ICON_PHONE:-📱} Device:" "${PDA_WHITE}$(pda_get_model) | $(pda_get_android_version)${PDA_RESET}"
  pda_box_line "${PDA_ICON_NET:-📡} IP local:" "${PDA_WHITE}$(pda_get_ip)${PDA_RESET}"
  pda_box_line "${PDA_ICON_SHELL:-🐚} Shell:" "${PDA_WHITE}$(pda_get_shell)${PDA_RESET}"
  pda_box_line "${PDA_ICON_PYTHON:-🐍} Python:" "${PDA_WHITE}$(pda_get_python)${PDA_RESET}"
  pda_box_line "${PDA_ICON_NODE:-🟢} Node:" "${PDA_WHITE}$(pda_get_node)${PDA_RESET}"
  print_storage
  #print_battery
  pda_box_line "${PDA_ICON_MOON:-🌙} Moon:" "${PDA_WHITE}$(pda_moon_phase)${PDA_RESET}"
  pda_box_line "${PDA_ICON_TASK:-☑️} Tasks:" "${PDA_WHITE}$(pda_pending_tasks) pending${PDA_RESET}"
  pda_box_line "${PDA_ICON_POMO:-🍅} Pomodoros:" "${PDA_WHITE}$(pda_pomodoros_today) today${PDA_RESET}"
  weather="$(pda_weather_widget)"
  [[ -n "$weather" ]] && pda_box_line "Weather:" "${PDA_WHITE}$weather${PDA_RESET}"
}

print_random_message() {
  local message
  if [[ -f "$PDA_MESSAGES_FILE" ]]; then
    message="$(awk 'NF {lines[++count]=$0} END {srand(); if (count) print lines[int(rand()*count)+1]}' "$PDA_MESSAGES_FILE")"
  else
    message="Seu PDA acredita em voce ✨"
  fi
  pda_line
  pda_center "${PDA_PINK}${PDA_ICON_HEART:-💖} $message${PDA_RESET}"
  pda_line
}

print_mascot() {
  local line
  if [[ -f "$PDA_MASCOT_FILE" ]]; then
    while IFS= read -r line; do
      pda_center "${PDA_MINT}$line${PDA_RESET}"
    done < "$PDA_MASCOT_FILE"
  else
    pda_center "${PDA_MINT}/_/\\\\${PDA_RESET}"
    pda_center "${PDA_MINT}(=^･ω･^=)${PDA_RESET}"
    pda_center "${PDA_MINT}(\")_(\")${PDA_RESET}"
  fi
}

print_pda_boot_screen() {
  mkdir -p "$PDA_CACHE_DIR" 2>/dev/null || true
  printf "\n"
  print_header
  print_ascii_logo
  pda_line
  print_system_info
  print_random_message
  print_mascot
  printf "%b%s%b\n\n" "$PDA_DIM" "Boot complete. Welcome back, Marcus." "$PDA_RESET"
}

print_pda_boot_screen
