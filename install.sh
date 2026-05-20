#!/usr/bin/env bash
set -euo pipefail

repo_url="${SAFE_INSTALL_REPO_URL:-https://github.com/cachetronaut/safe-install.git}"
install_dir="${SAFE_INSTALL_HOME:-${HOME}/.local/share/safe-install}"
repo_dir="${SAFE_INSTALL_REPO:-$PWD}"

usage() {
  cat <<'USAGE'
safe-install installer

Usage:
  curl -fsSL https://raw.githubusercontent.com/cachetronaut/safe-install/main/install.sh | bash

Environment:
  SAFE_INSTALL_HOME      Install location. Default: ~/.local/share/safe-install
  SAFE_INSTALL_REPO      Repo to initialize. Default: current directory
  SAFE_INSTALL_REPO_URL  Source repository URL.
  SAFE_INSTALL_NO_START  Set to 1 to skip runtime startup during init.
USAGE
}

log() {
  printf 'safe-install installer: %s\n' "$*"
}

die() {
  printf 'safe-install installer: %s\n' "$*" >&2
  exit 2
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

if ! command -v git >/dev/null 2>&1; then
  die "git is required to install safe-install"
fi

if [[ -d "$install_dir/.git" ]]; then
  log "updating $install_dir"
  git -C "$install_dir" fetch --quiet origin
  git -C "$install_dir" checkout --quiet main
  git -C "$install_dir" pull --ff-only --quiet origin main
elif [[ -e "$install_dir" ]]; then
  die "install path exists but is not a git checkout: $install_dir"
else
  log "installing to $install_dir"
  mkdir -p "$(dirname "$install_dir")"
  git clone --quiet --depth 1 "$repo_url" "$install_dir"
fi

init_args=(--repo "$repo_dir")
if [[ "${SAFE_INSTALL_NO_START:-0}" == "1" ]]; then
  init_args+=(--no-start)
fi

log "initializing $repo_dir"
"$install_dir/bin/safe-install" init "${init_args[@]}"

cat <<EOF

safe-install is installed.

For this terminal only:
  source "$install_dir/activate.sh"

For future terminals and supported agents:
  restart Terminal and Claude Code, then run:
  safe-install doctor
EOF
