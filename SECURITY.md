# Security Policy

`safe-install` is a defense-in-depth tool for dependency installation. It reduces host exposure by putting package-manager install operations in a constrained container.

## Security Goals

- Do not mount the host home directory by default.
- Do not pass host credentials, SSH keys, npm tokens, PyPI tokens, GitHub tokens, browser profiles, or agent settings into containers by default.
- Intercept common package-manager install commands through PATH shims.
- Keep normal workflows low-friction enough that users do not bypass the tool.
- Make bypasses explicit and auditable.
- Keep Python installs out of the system interpreter by using a project virtualenv.

## Non-Goals

- It is not a malware sandbox for arbitrary code execution.
- It does not make a malicious package safe if the mounted project contains secrets.
- It does not stop commands that use absolute package-manager paths.
- It does not replace endpoint protection, secret scanning, signed releases, or locked dependency review.
- Python virtualenv installs run with the host interpreter so installed packages are executable on the host; this is usability isolation, not a malware sandbox.

## Reporting

Please open a private security advisory on GitHub or email the maintainer listed on the repository profile.

Include:

- Package manager and operating system.
- The command that bypassed isolation.
- Whether host secrets or home directories were exposed.
- A minimal reproduction when possible.
