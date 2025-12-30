# Conventions

Intentional defaults. Explicit over implicit.

## Variable Naming

- `brew_packages` / `cask_packages` - macOS Homebrew packages
- `linux_packages` - Linux system packages
- `directories` - List of directories to create
- `git_repos` - List of repositories to clone
- `ssh_identities` - SSH keys to manage
- `ssh_hosts` - SSH host configurations
- `doctor_*` - Health check configuration

## Role Defaults

Each role has sensible defaults in `defaults/main.yml`. Override in `group_vars/` as needed.

## Tags

Playbooks support tags for selective execution:
- `--tags ssh` - SSH only
- `--tags shell` - Shell profile only
- `--tags packages` - Package installation only

## Extra Variables

Control behavior at runtime:
- `-e ssh_create_keys=true` - Create missing SSH keys
- `-e doctor_strict=true` - Fail on health check warnings

## Secrets

Sensitive data goes in vault-encrypted files:
- `inventory/group_vars/*/vault.yml` - Encrypted variables
- `.vault_pass` - Vault password file (not committed)
