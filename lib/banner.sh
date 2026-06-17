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

render_banner() {
  sak_set_colors

  local logo=(
    '██████████    ██████    ██      ██'
    '██████████    ██████    ██      ██'
    '██          ██      ██  ██    ██  '
    '██          ██      ██  ██    ██  '
    '██████████  ██████████  ██████    '
    '██████████  ██████████  ██████    '
    '        ██  ██      ██  ██    ██  '
    '        ██  ██      ██  ██    ██  '
    '██████████  ██      ██  ██      ██'
    '██████████  ██      ██  ██      ██'
  )

  local animate=0
  sak_animate && animate=1

  local logo_text="" line
  for line in "${logo[@]}"; do logo_text+="${line}"$'\n'; done

  _reveal "${logo_text%$'\n'}" "$C_BOLD" "$animate"
  echo
  _reveal "  Powered by coody.app" "$C_DIM" "$animate"
  echo
  _reveal "$(usage)" "" "$animate"
  return 0
}
