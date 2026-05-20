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
SAFE_INSTALL_DRY_RUN=1 npm ci
SAFE_INSTALL_DRY_RUN=1 uv sync --locked
SAFE_INSTALL_DRY_RUN=1 uv pip install pytest
SAFE_INSTALL_DRY_RUN=1 pip install -r requirements.txt
```

## Bypass

For a single command:

```sh
SAFE_INSTALL_BYPASS=1 pnpm install
```

Use bypass only when you intentionally want host-level package-manager behavior.
