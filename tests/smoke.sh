#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

bash -n "$repo_root/bin/safe-install" "$repo_root/bin/pnpm" "$repo_root/bin/npm" \
  "$repo_root/bin/npx" "$repo_root/bin/pnpx" \
  "$repo_root/bin/bun" "$repo_root/bin/bunx" \
  "$repo_root/bin/uv" "$repo_root/bin/pip" "$repo_root/bin/pip3" \
  "$repo_root/bin/python" "$repo_root/bin/python3" \
  "$repo_root/scripts/install-shell.sh" "$repo_root/install.sh" \
  "$repo_root/hooks/run-hook.cmd" "$repo_root/hooks/session-start"

python3 -m json.tool "$repo_root/.claude-plugin/plugin.json" >/dev/null
python3 -m json.tool "$repo_root/.claude-plugin/marketplace.json" >/dev/null
python3 -m json.tool "$repo_root/.codex-plugin/plugin.json" >/dev/null
python3 -m json.tool "$repo_root/.agents/plugins/marketplace.json" >/dev/null
python3 -m json.tool "$repo_root/.cursor-plugin/plugin.json" >/dev/null
python3 -m json.tool "$repo_root/hooks/hooks.json" >/dev/null
python3 -m json.tool "$repo_root/hooks/hooks-cursor.json" >/dev/null

pnpm_dry="$(PATH="$repo_root/bin:$PATH" SAFE_INSTALL_DRY_RUN=1 pnpm install)"
pnpm_exec_dry="$(PATH="$repo_root/bin:$PATH" SAFE_INSTALL_DRY_RUN=1 pnpm exec vite --version)"
pnpx_dry="$(PATH="$repo_root/bin:$PATH" SAFE_INSTALL_DRY_RUN=1 pnpx cowsay hi)"
npm_dry="$(PATH="$repo_root/bin:$PATH" SAFE_INSTALL_DRY_RUN=1 npm ci)"
npx_dry="$(PATH="$repo_root/bin:$PATH" SAFE_INSTALL_DRY_RUN=1 npx prettier --version)"
bun_dry="$(PATH="$repo_root/bin:$PATH" SAFE_INSTALL_DRY_RUN=1 bun install)"
bunx_dry="$(PATH="$repo_root/bin:$PATH" SAFE_INSTALL_DRY_RUN=1 bunx cowsay hi)"
uv_dry="$(PATH="$repo_root/bin:$PATH" SAFE_INSTALL_DRY_RUN=1 uv sync --locked)"
uv_run_dry="$(PATH="$repo_root/bin:$PATH" SAFE_INSTALL_DRY_RUN=1 uv run python --version)"
pip_dry="$(PATH="$repo_root/bin:$PATH" SAFE_INSTALL_DRY_RUN=1 pip install -r requirements.txt)"
doctor="$(PATH="$repo_root/bin:$PATH" safe-install doctor)"
env_out="$("$repo_root/bin/safe-install" env)"
hook_out="$(CLAUDE_PLUGIN_ROOT="$repo_root" "$repo_root/hooks/run-hook.cmd" session-start)"
HOOK_OUT="$hook_out" python3 - <<'PY'
import json
import os

payload = json.loads(os.environ["HOOK_OUT"])
context = payload["hookSpecificOutput"]["additionalContext"]
assert "safe-install plugin is enabled" in context
assert "safe-install doctor" in context
PY

tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT
bash_activate="$(bash -c "cd '$tmp_dir' && source '$repo_root/activate.sh' && command -v safe-install")"
zsh_activate="$(zsh -c "cd '$tmp_dir' && source '$repo_root/activate.sh' && command -v safe-install")"
git init -q "$tmp_dir/repo"
mkdir -p "$tmp_dir/claude"
printf '{"env":{"EXISTING":"1"}}\n' > "$tmp_dir/claude/settings.json"
init_out="$(PATH="$repo_root/bin:$PATH" "$repo_root/bin/safe-install" init --repo "$tmp_dir/repo" --shell-rc "$tmp_dir/zshrc" --claude-settings "$tmp_dir/claude/settings.json" --no-start)"

grep -q -- '--ignore-scripts' <<< "$pnpm_dry"
grep -q -- 'safe-install-pnpm' <<< "$pnpm_exec_dry"
grep -q -- 'vite' <<< "$pnpm_exec_dry"
grep -q -- 'safe-install-pnpm' <<< "$pnpx_dry"
grep -q -- 'cowsay' <<< "$pnpx_dry"
grep -q -- '--ignore-scripts' <<< "$npm_dry"
grep -q -- 'safe-install-npm' <<< "$npx_dry"
grep -q -- 'prettier' <<< "$npx_dry"
grep -q -- 'oven/bun:1' <<< "$bun_dry"
grep -q -- '--ignore-scripts' <<< "$bun_dry"
grep -q -- 'safe-install-bun' <<< "$bunx_dry"
grep -q -- 'cowsay' <<< "$bunx_dry"
grep -q 'ghcr.io/astral-sh/uv:debian' <<< "$uv_dry"
grep -q -- 'dst=/work/.venv' <<< "$uv_dry"
! grep -q 'ghcr.io/astral-sh/uv:python' <<< "$uv_dry"
grep -q -- 'safe-install-uv' <<< "$uv_run_dry"
grep -q -- 'python' <<< "$uv_run_dry"
grep -q -- '--memory 2g' <<< "$pnpm_dry"
grep -q -- '--cpus 2' <<< "$pnpm_dry"
grep -q -- 'size=512m' <<< "$pnpm_dry"
grep -q -- 'safe-install python-venv' <<< "$pip_dry"
grep -q -- '.venv/bin/python' <<< "$pip_dry"
[[ "$bash_activate" == "$repo_root/bin/safe-install" ]]
[[ "$zsh_activate" == "$repo_root/bin/safe-install" ]]
grep -q 'pnpm: protected' <<< "$doctor"
grep -q 'pnpx: protected' <<< "$doctor"
grep -q 'npx:  protected' <<< "$doctor"
grep -q 'bun:  protected' <<< "$doctor"
grep -q 'bunx: protected' <<< "$doctor"
grep -q 'uv:   protected' <<< "$doctor"
grep -q 'python3: protected' <<< "$doctor"
grep -q 'export SAFE_INSTALL_ACTIVE=1' <<< "$env_out"
grep -q 'safe-install: added activation' <<< "$init_out"
grep -q 'safe-install: installed pre-commit guard' <<< "$init_out"
grep -q 'safe-install: updated Claude PATH' <<< "$init_out"
grep -q 'restart Claude Code' <<< "$init_out"
grep -q "source $repo_root/activate.sh" "$tmp_dir/zshrc"
grep -q 'safe-install" guard' "$tmp_dir/repo/.git/hooks/pre-commit"
grep -q "$repo_root/bin" "$tmp_dir/claude/settings.json"
grep -q '"EXISTING": "1"' "$tmp_dir/claude/settings.json"

git clone -q "$repo_root" "$tmp_dir/source"
mkdir -p "$tmp_dir/project"
git init -q "$tmp_dir/project"
installer_out="$(HOME="$tmp_dir/home" SAFE_INSTALL_REPO_URL="file://$tmp_dir/source" SAFE_INSTALL_REPO="$tmp_dir/project" SAFE_INSTALL_CLAUDE_SETTINGS="$tmp_dir/missing-claude.json" SAFE_INSTALL_NO_START=1 "$repo_root/install.sh")"
grep -q 'safe-install installer: installing to' <<< "$installer_out"
grep -q 'safe-install installer: initializing' <<< "$installer_out"
grep -q 'safe-install: skipped runtime start' <<< "$installer_out"
grep -q 'safe-install is installed' <<< "$installer_out"
grep -q 'source "' <<< "$installer_out"
test -x "$tmp_dir/home/.local/share/safe-install/bin/safe-install"
test -x "$tmp_dir/project/.git/hooks/pre-commit"

mkdir -p "$tmp_dir/python-project"
touch "$tmp_dir/python-project/requirements.txt"
(
  cd "$tmp_dir/python-project"
  PATH="$repo_root/bin:$PATH" pip install -r requirements.txt >/dev/null
  venv_prefix="$(PATH="$repo_root/bin:$PATH" python3 -c 'import sys; print(sys.prefix)')"
  expected_prefix="$(cd "$tmp_dir/python-project/.venv" && pwd -P)"
  actual_prefix="$(cd "$venv_prefix" && pwd -P)"
  [[ "$actual_prefix" == "$expected_prefix" ]]
)

printf 'safe-install smoke tests passed\n'
