# safe-install

Invisible dependency isolation for local development and coding agents.

`safe-install` routes risky package-manager operations through a disposable Docker-compatible container. On macOS, OrbStack is the intended low-friction runtime. The goal is simple: keep normal `pnpm install`, `npm ci`, `uv sync`, and `pip install` workflows feeling ordinary while host secrets stay out of reach.

## What It Protects

By default, install commands run with:

- only the current project mounted at `/work`
- container `HOME=/tmp/safe-home`
- no host home directory
- no SSH keys, browser profiles, npm tokens, PyPI tokens, GitHub tokens, or agent settings
- dropped Linux capabilities
- `no-new-privileges`
- npm/pnpm lifecycle scripts disabled unless explicitly allowed
- Python `pip install` commands install into a project `.venv` and the `python`/`python3` shims auto-use that environment from inside the project

## Install

### Claude Code Plugin

Claude Code can load safe-install as a plugin. When enabled, the plugin's `bin/` wrappers are available to Claude's Bash tool, so package-manager installs run through safe-install without shell rc setup.

For local testing from this checkout:

```sh
claude --plugin-dir .
```

To install the local development marketplace:

```sh
claude plugin marketplace add /path/to/safe-install --scope user
claude plugin marketplace update safe-install-dev
claude plugin install safe-install@safe-install-dev --scope user
```

In Claude Code, verify:

```sh
safe-install doctor
SAFE_INSTALL_DRY_RUN=1 pnpm install
```

The intended marketplace flow is:

```txt
/plugin install safe-install@<marketplace>
/reload-plugins
```

### Shell Installer

From the project you want to protect, run:

```sh
curl -fsSL https://raw.githubusercontent.com/cachetronaut/safe-install/main/install.sh | bash
```

Then restart Terminal and Claude Code.

For the current terminal only:

```sh
source ~/.local/share/safe-install/activate.sh
safe-install doctor
```

Expected:

```txt
pnpm: protected
npm: protected
uv: protected
pip3: protected
python3: protected
```

If you already cloned the repo locally, run:

```sh
./bin/safe-install init --repo /path/to/your/project
```

`init` does four visible things:

- adds shell activation to your shell rc file
- installs a repo-local pre-commit guard when the current directory is a git repo
- configures Claude Code when `~/.claude/settings.json` exists
- starts OrbStack/Docker when possible

Open a new terminal after `init`, or run `source /path/to/safe-install/activate.sh` once in the current terminal.
Restart Claude Code after `init`, then run `safe-install doctor` inside Claude.

## Normal Use

Use your usual commands:

```sh
pnpm install
npm ci
uv sync --locked
uv pip install pytest
pip install -r requirements.txt
```

The wrappers intercept install-like operations and run them in the container. Other commands pass through to the real host package manager.

Python is the exception for local usability: bare `pip install ...` creates or reuses `.venv` in the current project, installs there with the host Python, and subsequent `python` or `python3` commands automatically use that `.venv` through the safe-install shims. This avoids disappearing container-only installs and macOS externally-managed Python failures.

## Direct Use

```sh
safe-install --pm pnpm -- install
safe-install --pm npm -- ci
safe-install --pm uv -- sync --locked
safe-install --pm pip -- install -r requirements.txt
```

Preview without running Docker:

```sh
SAFE_INSTALL_DRY_RUN=1 pnpm install
safe-install --pm pnpm --dry-run -- install
SAFE_INSTALL_DRY_RUN=1 pip install pdfplumber
```

Run without network for already-downloaded material:

```sh
safe-install --pm pnpm --no-network --readonly -- install
```

Allow npm/pnpm lifecycle scripts only when you trust the dependency tree:

```sh
safe-install --pm pnpm --allow-scripts -- install
```

## Agent Enforcement

Claude Code plugin sessions are protected when the plugin's `bin/` directory is on Claude's Bash `PATH`. Shell and other coding-agent sessions are protected when their shell environment resolves package managers through `safe-install/bin` first.

Check any terminal or agent session:

```sh
safe-install doctor
```

Start the local container runtime when needed:

```sh
safe-install start
```

Real install commands also try to start OrbStack or Docker Desktop automatically on macOS when Docker is not reachable. Set `SAFE_INSTALL_AUTO_START=0` to disable that behavior.

Install a repo-local pre-commit guard:

```sh
safe-install install-git-hook --repo /path/to/repo
```

The guard blocks commits that stage dependency files when `safe-install` is not active on `PATH`.

For Claude Code, prefer the plugin route. The shell installer still configures `~/.claude/settings.json` automatically when that file exists. If Claude Code was already open, restart it and check:

```sh
safe-install doctor
```

Manual Claude Code setup is still available:

```sh
node ./scripts/install-claude-env.js
```

For Codex CLI sessions launched from your shell, shell activation is enough. For desktop apps that do not inherit your login shell, start them from an activated terminal or configure their launcher environment with:

```sh
PATH=/path/to/safe-install/bin:$PATH
```

## Wrapped Commands

- `pnpm`: `install`, `i`, `add`, `update`, `up`, `import`, `dlx`
- `npm`: `install`, `i`, `ci`, `update`, `up`, `exec`, `x`, `init`
- `uv`: `sync`, `add`, `pip`, `tool`, `python`
- `pip` and `pip3`: `install`, `wheel`, `download`
- `python` and `python3`: auto-dispatch to a project `.venv` when one exists, otherwise pass through

Bypass is explicit:

```sh
SAFE_INSTALL_BYPASS=1 pnpm install
```

## Resource Defaults

The default container budget is intentionally small for everyday local development:

- memory: `2g`
- CPUs: `2`
- tmpfs: `512m`

Override per command or session when a dependency tree needs more room:

```sh
SAFE_INSTALL_MEMORY=4g SAFE_INSTALL_CPUS=4 pnpm install
SAFE_INSTALL_TMPFS_SIZE=1g uv sync
```

## Extending Backends

The first backend targets Docker-compatible runtimes. That covers OrbStack on macOS, Docker Desktop, Colima, Podman-compatible Docker sockets, and Linux Docker engines.

Future backends should preserve the same policy contract:

- project-only mount
- disposable home
- no ambient secrets
- optional network isolation
- package-manager-specific lifecycle-script controls
- `safe-install doctor` visibility

Python virtualenv management is intentionally host-side because Linux container virtualenvs and compiled wheels are not generally executable on macOS hosts. Use `SAFE_INSTALL_PYTHON_CONTAINER=1 pip install ...` only when you explicitly want the previous disposable-container behavior.

See [CONTRIBUTING.md](./CONTRIBUTING.md).

## Security Model

This reduces risk from dependency installs. It does not make arbitrary untrusted code safe.

The mounted project directory is still writable by default. With network enabled, code inside the container can still reach the internet. Keep secrets out of project folders and use `--no-network --readonly` when inspecting suspicious material.

See [SECURITY.md](./SECURITY.md).
