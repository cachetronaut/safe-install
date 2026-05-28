# Agent Enforcement

The wrappers only enforce installs when the safe-install `bin` directory appears before normal package managers in `PATH`.

## Interactive Shells

From the project you want to protect, run the installer:

```sh
curl -fsSL https://raw.githubusercontent.com/cachetronaut/safe-install/main/install.sh | bash
```

Open a new terminal and confirm:

```sh
safe-install doctor
```

For the current terminal only:

```sh
source ~/.local/share/safe-install/activate.sh
```

## Claude Code

Prefer the plugin route for Claude Code. The plugin includes the safe-install `bin/` wrappers, and Claude Code makes plugin `bin/` available to the Bash tool while the plugin is enabled.

Local plugin test:

```sh
claude --plugin-dir /path/to/safe-install
```

Inside Claude Code:

```sh
safe-install doctor
SAFE_INSTALL_DRY_RUN=1 pnpm install
```

The shell installer still configures Claude Code when `~/.claude/settings.json` exists:

```sh
curl -fsSL https://raw.githubusercontent.com/cachetronaut/safe-install/main/install.sh | bash
```

Manual settings setup is also available:

```sh
node ./scripts/install-claude-env.js
```

Or add this key manually to the `env` object:

```json
"env": {
  "CLAUDE_CODE_DISABLE_1M_CONTEXT": "1",
  "PATH": "/path/to/safe-install/bin:${PATH}"
}
```

Then open a new Claude Code session and run:

```sh
safe-install doctor
```

If Claude settings do not exist yet, open Claude Code once, quit it, and rerun `safe-install init`.

## Codex

For Codex CLI sessions launched from your shell, sourcing `activate.sh` in your shell rc file is enough.

For Codex Desktop sessions, run this once inside the session to check whether the app inherited your shell PATH:

```sh
safe-install doctor
```

If it reports `bypassing safe-install`, start Codex from a terminal that has sourced `activate.sh`, or add the same PATH prefix to the environment launcher you use for Codex.

For an already-open Codex worktree after install or update, refresh the current shell in place:

```sh
eval "$($HOME/.local/share/safe-install/bin/safe-install reload)"
safe-install doctor
```

## Runtime Startup

Run this when you want to warm the container runtime before an install:

```sh
safe-install start
```

Real install commands also try to start OrbStack or Docker Desktop automatically on macOS. On other platforms, `doctor` and failed installs tell the user to start their Docker-compatible runtime.

## Expected Protected Commands

These should print a Docker command when `SAFE_INSTALL_DRY_RUN=1` is set:

```sh
SAFE_INSTALL_DRY_RUN=1 pnpm install
SAFE_INSTALL_DRY_RUN=1 pnpm dlx vite --version
SAFE_INSTALL_DRY_RUN=1 npm ci
SAFE_INSTALL_DRY_RUN=1 npx prettier --version
SAFE_INSTALL_DRY_RUN=1 bun install
SAFE_INSTALL_DRY_RUN=1 bunx cowsay hi
SAFE_INSTALL_DRY_RUN=1 uv sync --locked
SAFE_INSTALL_DRY_RUN=1 uv run python --version
SAFE_INSTALL_DRY_RUN=1 uv pip install pytest
SAFE_INSTALL_DRY_RUN=1 pip install -r requirements.txt
```

For Node, Bun, and uv package executables, use the ecosystem launcher instead of host paths or direct `node_modules/.bin` guesses: `pnpm exec`, `pnpm dlx`, `npx`, `bun run`, `bunx`, `uv run`, or `uv tool run`. Note that `pnpm exec`, `pnpm run`, and `bun run` run local code on the host (not sandboxed); only the remote-fetching launchers (`pnpm dlx`, `npx`, `bunx`) are sandboxed.

For uv project work, keep the project's declared Python constraint intact. The wrapper uses a generic uv image and a container-local `.venv`, so do not downgrade `requires-python` or similar project metadata just to match the wrapper image.

For Python package work, `pip install ...` creates or reuses `.venv` in the current project. Later `python` and `python3` calls automatically use that virtualenv through the safe-install shims, so agents should not retry with `python3 -m pip --user`, `--break-system-packages`, or a manually activated venv.

## Bypass

For a single command:

```sh
SAFE_INSTALL_BYPASS=1 pnpm install
```

Use bypass only when you intentionally want host-level package-manager behavior.
