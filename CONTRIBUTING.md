# Contributing

The project is intentionally small. Contributions should preserve secure defaults and low friction.

## Design Rules

- Add new package-manager support as a narrow command mapping.
- Do not mount host home directories by default.
- Do not pass through secrets by default.
- Do not make lifecycle scripts run by default for npm or pnpm.
- Prefer visible doctor/audit commands over noisy prompts during normal installs.
- Bypasses must be explicit, documented, and easy to search for.

## Local Checks

```sh
./tests/smoke.sh
```

## Backend Ideas

The first backend is Docker-compatible runtimes, including OrbStack on macOS. Future backends should keep the same policy contract:

- project-only mount
- disposable home
- no ambient secrets
- optional network isolation
- package-manager-specific script controls
