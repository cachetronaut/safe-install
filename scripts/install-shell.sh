#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
line="source $root/activate.sh"
shell_rc="${1:-${HOME}/.zshrc}"

touch "$shell_rc"
if grep -Fqx "$line" "$shell_rc"; then
  printf 'safe-install: shell already configured: %s\n' "$shell_rc"
  exit 0
fi

{
  printf '\n# safe-install dependency isolation\n'
  printf '%s\n' "$line"
} >> "$shell_rc"

printf 'safe-install: added activation to %s\n' "$shell_rc"
