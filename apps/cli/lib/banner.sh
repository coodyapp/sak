#!/bin/bash
# Welcome banner shown for bare `sak` (no subcommand): a big logo + usage,
# revealed line by line for a quick animated feel in real terminals.

_reveal() {
  local text="$1" color="$2" animate="$3" l
  while IFS= read -r l; do
    printf '%s%s%s\n' "$color" "$l" "$C_RESET"
    if [[ "$animate" -eq 1 ]]; then sleep 0.012; fi
  done <<< "$text"
}

_box_repeat() {
  local char="$1" count="$2"
  [[ "$count" -le 0 ]] && return 0
  printf "%${count}s" "" | tr ' ' "$char"
}

_box_pad() {
  local str="$1" width="$2"
  local len=${#str}
  if [[ "$len" -ge "$width" ]]; then
    printf '%s' "${str:0:$width}"
  else
    printf '%s%s' "$str" "$(_box_repeat ' ' "$((width - len))")"
  fi
}

# Two-column welcome box: tool count on the left, a quick tip on the right.
_welcome_box() {
  local version="$1" tool_count="$2" left=32 right=36
  local title=" sak $version " fill
  fill=$(( left - ${#title} ))

  printf '┌%s%s┬%s┐\n' "$title" "$(_box_repeat '─' "$fill")" "$(_box_repeat '─' "$right")"
  printf '│%s│%s│\n' "$(_box_pad "  Available tools: $tool_count" "$left")" "$(_box_pad "  New here? Run: sak list" "$right")"
  printf '└%s┴%s┘\n' "$(_box_repeat '─' "$left")" "$(_box_repeat '─' "$right")"
}

render_banner() {
  local version="$1"
  sak_set_colors

  local logo=(
    '  █████████    █████████   █████   ████'
    ' ███░░░░░███  ███░░░░░███ ░░███   ███░ '
    '░███    ░░░  ░███    ░███  ░███  ███   '
    '░░█████████  ░███████████  ░███████    '
    ' ░░░░░░░░███ ░███░░░░░███  ░███░░███   '
    ' ███    ░███ ░███    ░███  ░███ ░░███  '
    '░░█████████  █████   █████ █████ ░░████'
    ' ░░░░░░░░░  ░░░░░   ░░░░░ ░░░░░   ░░░░ '
  )

  local animate=0
  sak_animate && animate=1

  local logo_text="" line
  for line in "${logo[@]}"; do logo_text+="${line}"$'\n'; done

  _reveal "${logo_text%$'\n'}" "$C_BOLD" "$animate"
  echo
  _reveal "  Powered by coody.app" "$C_DIM" "$animate"
  echo
  _reveal "$(_welcome_box "$version" "$(list_tools | wc -l | tr -d ' ')")" "$C_DIM" "$animate"
  echo
  _reveal "$(usage)" "" "$animate"
  return 0
}
