---
description: Use when checking, initializing, or troubleshooting safe-install dependency isolation for package-manager installs.
---

# safe-install

Use safe-install when a user asks whether dependency installs are protected, wants to initialize a repo, or wants to run npm, pnpm, uv, or pip install-like commands safely.

## Checks

Run:

```sh
safe-install doctor
```

Protected output should show package managers resolving through a `safe-install/bin` path.

For a dry run that proves interception without installing packages:

```sh
SAFE_INSTALL_DRY_RUN=1 pnpm install
SAFE_INSTALL_DRY_RUN=1 pnpm exec vite --version
SAFE_INSTALL_DRY_RUN=1 npm ci
SAFE_INSTALL_DRY_RUN=1 npx prettier --version
SAFE_INSTALL_DRY_RUN=1 bun install
SAFE_INSTALL_DRY_RUN=1 bunx cowsay hi
SAFE_INSTALL_DRY_RUN=1 uv sync --locked
SAFE_INSTALL_DRY_RUN=1 uv run python --version
SAFE_INSTALL_DRY_RUN=1 pip install -r requirements.txt
```

The npm, pnpm, bun, and uv output should be a `docker run ...` command with a project-only mount and `HOME=/tmp/safe-home`. `pip install ...` should show the project `.venv` path because Python installs need a host-executable virtualenv.

The uv dry run should use the generic Debian uv image, hide `/work/.venv` with a container-local volume, and set uv's Python/cache directories under `/safe-install` so downloaded interpreters are executable inside the container.

## Initialization

For a repo/machine install outside a plugin-managed session:

```sh
curl -fsSL https://raw.githubusercontent.com/cachetronaut/safe-install/main/install.sh | bash
```

For a checked-out repo:

```sh
safe-install init
```

## Rules

- Do not bypass safe-install unless the user explicitly asks.
- Use `SAFE_INSTALL_DRY_RUN=1` before a real install when troubleshooting.
- If Docker is not reachable on macOS, `safe-install` will try to start OrbStack or Docker Desktop during the real install.
- Keep secrets out of project directories because the project directory is mounted into the container.
- For Node, Bun, and uv package executables, use `pnpm exec`, `pnpm dlx`, `npx`, `bun run`, `bunx`, `uv run`, or `uv tool run`; do not guess host paths or bypass the wrappers.
- After `pip install ...`, run Python with `python` or `python3` normally; the shims auto-use `.venv` from inside the project.
