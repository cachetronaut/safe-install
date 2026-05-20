# Agent Plugin Strategy

## Goal

Make safe-install available as an installable agent plugin so users do not need to clone this repo, `cd` into it, or manually wire shell startup before their coding agent starts running package installs.

## Reference Pattern: Superpowers

Superpowers uses one repository with multiple harness manifests:

- `.claude-plugin/plugin.json` for Claude Code
- `.codex-plugin/plugin.json` for Codex
- `.cursor-plugin/plugin.json` for Cursor-compatible plugin loading
- `hooks/hooks.json` plus shell scripts for Claude Code lifecycle hooks
- `hooks/hooks-cursor.json` for Cursor lifecycle hooks
- `skills/` for model-visible workflow guidance
- `bin/` when a harness supports exposing plugin executables to command tools

The important pattern for safe-install is not the skills content. It is the packaging shape: plugin metadata, hooks, scripts, and optional harness-specific manifests can live side by side in one repo.

## Claude Code

Claude Code is the strongest fit.

Claude plugins can include a root `bin/` directory. When the plugin is enabled, Claude Code adds that directory to the Bash tool's `PATH`. That means the existing wrappers in `bin/npm`, `bin/pnpm`, `bin/uv`, `bin/pip`, and `bin/pip3` can become deterministic protection for Claude-run package installs.

The plugin also includes a `SessionStart` hook that injects the current `safe-install doctor` status into Claude's context. The hook does not start OrbStack/Docker during session startup. Real package installs already lazy-start OrbStack or Docker Desktop on macOS when needed.

Target user flow:

```txt
/plugin install safe-install@<marketplace>
/reload-plugins
```

Then Claude can run normal commands:

```sh
pnpm install
npm ci
uv sync
pip install -r requirements.txt
```

Those commands should resolve through the plugin's `bin/` wrappers.

## Codex

Codex plugin metadata and skills can be packaged now. Deterministic package-manager interception still needs verification in the Codex plugin runtime.

Known-good today:

- `.codex-plugin/plugin.json`
- `skills/safe-install/SKILL.md`
- existing one-command installer for machine-level PATH setup

Open question:

- Whether Codex plugin runtime exposes plugin `bin/` on command execution `PATH`, or supports a hook equivalent that can mutate command execution environment before shell commands run.

Until that is verified, the Codex plugin should be described as guidance plus installer access, not as deterministic enforcement by itself.

## Cursor

Cursor packaging is experimental. The repo includes `.cursor-plugin/plugin.json` and `hooks/hooks-cursor.json` following the same public shape used by Superpowers.

Open questions:

- Whether Cursor exposes plugin `bin/` to terminal/agent command execution.
- Whether Cursor hook output can reliably steer or block install commands.
- What Windows and non-Unix container runtime behavior should look like.

## Safety Boundary

The plugin should never claim that arbitrary untrusted code is safe. It only reduces install-time credential exposure by routing install-like package-manager commands through a disposable container with:

- project-only mount
- disposable `HOME=/tmp/safe-home`
- no host home directory
- dropped Linux capabilities
- `no-new-privileges`
- lifecycle scripts blocked by default for npm/pnpm

The mounted project remains writable unless `--readonly` is used.

## Next Steps

1. Validate the Claude plugin locally with `claude plugin validate .`.
2. Test Claude runtime behavior with `claude --plugin-dir .` and a Bash dry run:
   `SAFE_INSTALL_DRY_RUN=1 pnpm install`.
3. Create a safe-install marketplace repo or add marketplace metadata to this repo.
4. Test Codex plugin install/runtime behavior before promising deterministic Codex enforcement.
5. Keep Cursor support marked experimental until a local Cursor plugin runtime test passes.
