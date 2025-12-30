# Architecture

Boring by design. This ansible-laptop repo follows standard Ansible conventions with minimal abstraction.

## Structure

```
ansible-laptop/
├── inventory/
│   ├── hosts.yml           # Target hosts
│   └── group_vars/         # Variables by group
│       ├── all/main.yml    # Shared variables
│       ├── macos/main.yml  # macOS-specific
│       └── linux/main.yml  # Linux-specific
├── playbooks/
│   ├── setup.yml           # Initial setup
│   ├── maintenance.yml     # Updates and upgrades
│   ├── ssh.yml             # SSH configuration
│   ├── shell.yml           # Shell profile setup
│   └── doctor.yml          # Health checks
├── roles/
│   ├── directories/        # Create standard directories
│   ├── doctor/             # System diagnostics
│   ├── git_repos/          # Clone and configure repos
│   ├── homebrew/           # macOS packages
│   ├── packages/           # Linux packages
│   ├── shell_profile/      # Shell configuration
│   └── ssh/                # SSH identities and config
└── site.yml                # Main entry point
```

## Execution Order

1. **directories** - Ensure standard directories exist
2. **homebrew/packages** - Install system packages (OS-dependent)
3. **ssh** - Configure SSH identities and hosts
4. **shell_profile** - Set up shell environment
5. **git_repos** - Clone and configure repositories

## Cross-Platform Support

Uses `group_by` to assign hosts to `macos` or `linux` groups based on `ansible_system`. OS-specific variables live in `group_vars/macos/` and `group_vars/linux/`.
