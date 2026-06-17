#!/bin/bash
# Animated welcome banner shown for bare `sak` (no subcommand).
# Written without bash 4.3+ features (namerefs) so it also runs under
# macOS's stock bash 3.2 during local dev via ./run.sh.

_repeat() {
  local char="$1" count="$2"
  [[ "$count" -le 0 ]] && return 0
  printf "%${count}s" "" | tr ' ' "$char"
}

_pad() {
  local str="$1" width="$2"
  local len=${#str}
  if [[ "$len" -gt "$width" ]]; then
    if [[ "$width" -gt 1 ]]; then
      printf '%s…' "${str:0:$((width - 1))}"
    else
      printf '%s' "${str:0:$width}"
    fi
  elif [[ "$len" -eq "$width" ]]; then
    printf '%s' "$str"
  else
    printf '%s%s' "$str" "$(_repeat ' ' "$((width - len))")"
  fi
}

# Renders one row pair from the two newline-joined globals
# _BANNER_LEFT / _BANNER_RIGHT (avoids namerefs for bash 3.2 compat).
_box_pair_rows() {
  local left_width="$1" right_width="$2"
  local -a left_arr right_arr
  local old_ifs="$IFS"
  IFS=$'\n'
  set -f
  left_arr=($_BANNER_LEFT)
  right_arr=($_BANNER_RIGHT)
  set +f
  IFS="$old_ifs"

  local max=${#left_arr[@]}
  [[ ${#right_arr[@]} -gt "$max" ]] && max=${#right_arr[@]}

  local i
  for (( i = 0; i < max; i++ )); do
    local l="${left_arr[$i]:-}"
    local r="${right_arr[$i]:-}"
    printf '│%s│%s│\n' "$(_pad "$l" "$left_width")" "$(_pad "$r" "$right_width")"
  done
}

_box_top() {
  local version="$1" left_width="$2" right_width="$3"
  local title=" sak $version "
  local fill=$(( left_width - ${#title} ))
  printf '┌%s%s┬%s┐\n' "$title" "$(_repeat '─' "$fill")" "$(_repeat '─' "$right_width")"
}

_box_divider() {
  local left_width="$1" right_width="$2"
  printf '├%s┼%s┤\n' "$(_repeat '─' "$left_width")" "$(_repeat '─' "$right_width")"
}

_box_bottom() {
  local left_width="$1" right_width="$2"
  printf '└%s┴%s┘\n' "$(_repeat '─' "$left_width")" "$(_repeat '─' "$right_width")"
}

_render_banner_plain() {
  local version="$1" os_label="$2" who_host="$3" cwd="$4"
  echo "sak $version"
  echo "Welcome, $(whoami)!"
  echo "$os_label"
  echo "$who_host"
  echo "$cwd"
  echo
  echo "Tips for getting started"
  echo "  Run 'sak list' to see available tools"
  echo "  Run 'sak install <tool>' to install one"
  echo
  cmd_list
}

render_banner() {
  local version="$1"

  local is_tty=0
  [[ -t 1 ]] && is_tty=1

  local animate=1
  if [[ "$is_tty" -eq 0 || -n "${NO_COLOR:-}" || -n "${CI:-}" || -n "${SAK_NO_ANIMATION:-}" ]]; then
    animate=0
  fi

  local use_color=1
  if [[ "$is_tty" -eq 0 || -n "${NO_COLOR:-}" ]] || ! tput colors >/dev/null 2>&1; then
    use_color=0
  fi

  local c_accent="" c_reset=""
  if [[ "$use_color" -eq 1 ]]; then
    c_accent="$(tput setaf 6)"
    c_reset="$(tput sgr0)"
  fi

  local term_cols=80
  if [[ "$is_tty" -eq 1 ]]; then
    term_cols="$(tput cols 2>/dev/null || echo 80)"
  fi

  local os_label="Debian-based Linux"
  is_debian_based || os_label="unsupported OS"

  local cwd="${PWD/#$HOME/~}"
  local who_host
  who_host="$(whoami)@$(hostname -s 2>/dev/null || hostname)"

  local tools=()
  local t
  while IFS= read -r t; do tools+=("$t"); done < <(list_tools)

  if [[ "$term_cols" -lt 62 ]]; then
    _render_banner_plain "$version" "$os_label" "$who_host" "$cwd"
    return
  fi

  # Logo: 17 cols wide, spelling "SAK" in block characters.
  local logo=(
    '█████  ███  █   █'
    '█     █   █ █  █ '
    '█████ █████ ███  '
    '    █ █   █ █  █ '
    '█████ █   █ █   █'
  )

  local box_width=$(( term_cols - 2 ))
  [[ "$box_width" -gt 78 ]] && box_width=78
  local left_width=$(( box_width / 2 - 1 ))
  local right_width=$(( box_width - left_width - 3 ))

  local left_top="
  Welcome, $(whoami)!
"
  for i in "${logo[@]}"; do left_top+="
       $i"
  done
  left_top+="
          powered by coody
"

  local right_top="
  Tips for getting started

  sak list
    see available tools
  sak install <tool>
    install one"

  local left_bottom="  sak $version · $os_label
  $who_host
  $cwd"

  local right_bottom="  Available tools (${#tools[@]})"
  for t in "${tools[@]}"; do right_bottom+="
    • $t"
  done

  local output=""
  output+="$(_box_top "$version" "$left_width" "$right_width")
"
  _BANNER_LEFT="$left_top" _BANNER_RIGHT="$right_top"
  output+="$(_box_pair_rows "$left_width" "$right_width")
"
  output+="$(_box_divider "$left_width" "$right_width")
"
  _BANNER_LEFT="$left_bottom" _BANNER_RIGHT="$right_bottom"
  output+="$(_box_pair_rows "$left_width" "$right_width")
"
  output+="$(_box_bottom "$left_width" "$right_width")"

  local line
  while IFS= read -r line; do
    printf '%s%s%s\n' "$c_accent" "$line" "$c_reset"
    if [[ "$animate" -eq 1 ]]; then sleep 0.012; fi
  done <<< "$output"
  return 0
}
