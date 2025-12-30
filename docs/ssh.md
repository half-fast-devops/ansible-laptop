# SSH

Declarative SSH identity and configuration management.

## Features

- Creates `~/.ssh` directory with correct permissions (0700)
- Generates SSH keys on demand (ed25519 or rsa)
- Deploys SSH config from structured YAML definitions
- Validates configuration before applying
- Supports multiple identities for different services

## Usage

```bash
# Configure SSH (no key creation)
make ssh

# Create missing SSH keys
make ssh-create-keys

# Or with ansible-playbook directly
uv run ansible-playbook playbooks/ssh.yml -e ssh_create_keys=true
```

## Configuration

In `inventory/group_vars/all/main.yml`:

```yaml
# SSH directory path
ssh_config_dir: "{{ user_home }}/.ssh"

# SSH identities to manage
ssh_identities:
  - name: personal
    key_type: ed25519           # ed25519 (default) or rsa
    comment: "personal@laptop"
    create_if_missing: true     # Only created when ssh_create_keys=true
  - name: work
    key_type: ed25519
    comment: "work@company.com"
    create_if_missing: true

# SSH host configurations
ssh_hosts:
  - name: github.com-personal   # Host alias (use this in git clone)
    hostname: github.com        # Actual hostname (required)
    user: git                   # SSH user
    identity_file: "{{ user_home }}/.ssh/id_ed25519_personal"
  - name: github.com-work
    hostname: github.com
    user: git
    identity_file: "{{ user_home }}/.ssh/id_ed25519_work"
  - name: myserver
    hostname: 192.168.1.100
    user: admin
    port: 2222
    forward_agent: true
    extra_options:
      ServerAliveInterval: 60
      ServerAliveCountMax: 3
```

## Key Creation

Keys are only created when **both** conditions are met:

1. `ssh_create_keys=true` is passed at runtime
2. `create_if_missing: true` is set on the identity

This prevents accidental key regeneration.

```bash
# Creates keys for identities with create_if_missing: true
make ssh-create-keys

# Does NOT create keys, only configures
make ssh
```

## Generated SSH Config

The `ssh_hosts` list generates `~/.ssh/config`:

```
# SSH Config - Managed by Ansible
# Do not edit manually - changes will be overwritten

Host github.com-personal
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519_personal
    IdentitiesOnly yes

Host github.com-work
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519_work
    IdentitiesOnly yes

Host myserver
    HostName 192.168.1.100
    User admin
    Port 2222
    ForwardAgent yes
    ServerAliveInterval 60
    ServerAliveCountMax 3

# Global defaults
Host *
    AddKeysToAgent yes
    UseKeychain yes   # macOS only
```

## Using Multiple GitHub Accounts

To use multiple GitHub accounts on the same machine:

### 1. Configure identities

```yaml
ssh_identities:
  - name: personal
    create_if_missing: true
  - name: work
    create_if_missing: true
```

### 2. Configure host aliases

```yaml
ssh_hosts:
  - name: github.com-personal
    hostname: github.com
    user: git
    identity_file: "{{ user_home }}/.ssh/id_ed25519_personal"
  - name: github.com-work
    hostname: github.com
    user: git
    identity_file: "{{ user_home }}/.ssh/id_ed25519_work"
```

### 3. Clone using the alias

```bash
# Personal repos
git clone git@github.com-personal:myuser/repo.git

# Work repos
git clone git@github.com-work:company/repo.git
```

### 4. Update existing repos

```bash
# Change remote to use alias
git remote set-url origin git@github.com-work:company/repo.git
```

## Validation

The SSH role validates configurations before applying:

- **Host entries** must have `name` and `hostname` defined
- **Identity names** must be alphanumeric with dashes/underscores only (prevents injection)

Invalid configurations will fail with clear error messages.

## SSH Agent (Linux)

On Linux, the shell_profile role deploys an SSH agent initialization script that:

1. Starts ssh-agent if not running
2. Adds configured keys automatically

On macOS, the system keychain handles this automatically via `UseKeychain` and `AddKeysToAgent` in the SSH config.

## Troubleshooting

### Check SSH connectivity

```bash
# Test connection to GitHub
ssh -T git@github.com-personal

# Verbose output
ssh -vT git@github.com-personal
```

### View loaded keys

```bash
ssh-add -l
```

### Manually add key

```bash
ssh-add ~/.ssh/id_ed25519_personal
```

### Check permissions

```bash
# Run doctor checks
make doctor

# SSH directory should be 0700
ls -la ~/.ssh/
```

### Common issues

| Issue | Solution |
|-------|----------|
| "Permission denied (publickey)" | Add public key to GitHub/GitLab |
| "Bad owner or permissions" | Run `chmod 700 ~/.ssh && chmod 600 ~/.ssh/*` |
| "Could not open a connection to your authentication agent" | Start ssh-agent or run `make shell` |
