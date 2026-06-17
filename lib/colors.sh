#!/bin/bash
# Shared color/tty/animation detection, used by bin/sak and install.sh.

sak_use_color() {
  [[ -t 1 ]] && [[ -z "${NO_COLOR:-}" ]] && tput colors >/dev/null 2>&1
}

sak_animate() {
  sak_use_color && [[ -z "${CI:-}" ]] && [[ -z "${SAK_NO_ANIMATION:-}" ]]
}

sak_set_colors() {
  if sak_use_color; then
    C_ACCENT="$(tput setaf 6)"
    C_GREEN="$(tput setaf 2)"
    C_DIM="$(tput dim 2>/dev/null || true)"
    C_BOLD="$(tput bold)"
    C_RESET="$(tput sgr0)"
  else
    C_ACCENT=""
    C_GREEN=""
    C_DIM=""
    C_BOLD=""
    C_RESET=""
  fi
}
