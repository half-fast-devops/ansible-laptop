# ansible-laptop

Cross-platform laptop automation for macOS and Linux.

## Features

- **Cross-platform**: Works on macOS (Homebrew) and Linux (apt/dnf/pacman/zypper)
- **SSH Management**: Declarative SSH config and key management
- **Shell Profiles**: Drop-in based shell configuration
- **Git Repos**: Clone and configure repositories with per-repo git settings
- **Health Checks**: Doctor command to verify configuration

## Using This Repository

### Fork and Customize (Recommended)

The recommended way to use this repository is to **fork it** to your own GitHub account. This allows you to:
- Customize the configuration for your specific needs
- Keep your configuration private
- Receive updates and new features from the upstream repository
- Version control your personal configuration

### Initial Fork Setup

1. **Fork the repository** on GitHub (click the "Fork" button)

2. **Clone your fork**:
   ```bash
   git clone git@github.com:YOUR-USERNAME/ansible-laptop.git ~/ansible-laptop
   cd ~/ansible-laptop
   ```

3. **Add the upstream remote** to track the original repository:
   ```bash
   git remote add upstream git@github.com:ORIGINAL-OWNER/ansible-laptop.git
   git fetch upstream
   ```

4. **Verify your remotes**:
   ```bash
   git remote -v
   # origin    git@github.com:YOUR-USERNAME/ansible-laptop.git (your fork)
   # upstream  git@github.com:ORIGINAL-OWNER/ansible-laptop.git (original repo)
   ```

### Staying in Sync with Upstream

To receive new features, bug fixes, and improvements from the main repository:

```bash
# Fetch the latest changes from upstream
git fetch upstream

# Switch to your main branch
git checkout trunk

# Merge upstream changes
git merge upstream/trunk

# If there are no conflicts, push to your fork
git push origin trunk
```

**Handling merge conflicts:**

If you've modified core files (like roles or playbooks), you may encounter merge conflicts:

```bash
# After merge conflict occurs
git status                    # See which files have conflicts
# Edit conflicting files to resolve
git add <resolved-files>
git commit -m "Merge upstream changes"
git push origin trunk
```

**Best practices to minimize conflicts:**
- Keep your customizations in `inventory/group_vars/` files
- Avoid modifying core roles and playbooks when possible
- If you need custom behavior, consider creating new roles

### Sync Schedule

Consider syncing with upstream:
- **Monthly**: Check for new features and improvements
- **Before major changes**: Ensure you have the latest bug fixes
- **After seeing upstream activity**: When you notice updates to the main repo

### Alternative: Watch for Updates

Enable GitHub notifications for the upstream repository:
1. Visit the upstream repository on GitHub
2. Click "Watch" → "Custom" → "Releases"
3. You'll be notified when new versions are released

## New System Setup

### 1. Prerequisites

**macOS:**
```bash
# Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install Python 3.12+ and uv
brew install python@3.12
curl -LsSf https://astral.sh/uv/install.sh | sh
```

**Linux (Debian/Ubuntu):**
```bash
sudo apt update && sudo apt install -y python3 python3-pip git curl
curl -LsSf https://astral.sh/uv/install.sh | sh
```

**Linux (Fedora):**
```bash
sudo dnf install -y python3 python3-pip git curl
curl -LsSf https://astral.sh/uv/install.sh | sh
```

**Linux (OpenSUSE):**
```bash
sudo zypper install -y python3 python3-pip git curl
curl -LsSf https://astral.sh/uv/install.sh | sh
```

### 2. Clone and Install

```bash
# Clone the repository
git clone <your-repo-url> ~/ansible-laptop
cd ~/ansible-laptop

# Install Python dependencies
uv sync

# Install Ansible Galaxy collections
make deps
```

### 3. Configure Your System

Copy and customize the example configuration:

```bash
# Edit the main configuration file
vi inventory/group_vars/all/main.yml
```

**Minimal configuration example:**

```yaml
# inventory/group_vars/all/main.yml

# Directories to create
directories:
  - "{{ user_home }}/code"
  - "{{ user_home }}/work"
  - path: "{{ user_home }}/private"
    mode: "0700"

# SSH identities to manage
ssh_identities:
  - name: personal
    key_type: ed25519
    comment: "personal@laptop"
    create_if_missing: true

# SSH host aliases
ssh_hosts:
  - name: github.com
    hostname: github.com
    user: git
    identity_file: "{{ user_home }}/.ssh/id_ed25519_personal"

# Git repositories to clone
git_repos:
  - repo: git@github.com:yourusername/dotfiles.git
    dest: "{{ user_home }}/dotfiles"
```

### 4. Configure OS-Specific Packages

**macOS** (`inventory/group_vars/macos/main.yml`):
```yaml
brew_packages:
  - git
  - fzf
  - nvim
  - ripgrep
  - stow
  - tmux

cask_packages:
  - iterm2
  - visual-studio-code
  - rectangle
```

**Linux** (`inventory/group_vars/linux/main.yml`):
```yaml
linux_packages:
  - git
  - fzf
  - neovim
  - ripgrep
  - stow
  - tmux
```

### 5. Run Initial Setup

```bash
# Run full setup (creates SSH keys if configured)
make setup

# Or run without creating SSH keys
make run
```

### 6. Verify Installation

```bash
# Run health checks
make doctor
```

## Usage

### Common Commands

| Command | Description |
|---------|-------------|
| `make run` | Full configuration (no SSH key creation) |
| `make setup` | Initial setup (creates SSH keys) |
| `make maint` | Update packages and git repos |
| `make doctor` | Run health checks |

### Individual Components

| Command | Description |
|---------|-------------|
| `make ssh` | Configure SSH only |
| `make ssh-create-keys` | SSH + create missing keys |
| `make shell` | Configure shell profiles |
| `make brew` | Homebrew packages (macOS) |
| `make dirs` | Create directories |
| `make git` | Clone/update git repos |

### Using Tags

```bash
make run TAGS=ssh,shell   # Run specific tags
make run TAGS=packages    # Packages only
```

## Configuration Reference

### Path Variables

Always use `{{ user_home }}` for home directory paths:

```yaml
# Correct
directories:
  - "{{ user_home }}/code"

# Incorrect (~ is not expanded by Ansible)
directories:
  - ~/code
```

The `user_home` variable is defined in inventory with a fallback:
```yaml
user_home: "{{ ansible_user_dir | default(lookup('env', 'HOME')) }}"
```

### SSH Configuration

```yaml
# SSH directory (auto-created with mode 0700)
ssh_config_dir: "{{ user_home }}/.ssh"

# SSH identities
ssh_identities:
  - name: personal              # Used in key filename: id_ed25519_personal
    key_type: ed25519           # ed25519 (default) or rsa
    comment: "email@example.com"
    create_if_missing: true     # Only creates if ssh_create_keys=true

# SSH host configurations
ssh_hosts:
  - name: github.com-personal   # Host alias for SSH config
    hostname: github.com        # Actual hostname (required)
    user: git                   # SSH user
    identity_file: "{{ user_home }}/.ssh/id_ed25519_personal"
    port: 22                    # Optional, defaults to 22
    forward_agent: false        # Optional
    extra_options:              # Optional additional SSH options
      ServerAliveInterval: 60
```

### Git Repositories

```yaml
git_repos:
  - repo: git@github.com:user/project.git  # Git URL (required)
    dest: "{{ user_home }}/code/project"  # Local path (required)
    version: main               # Branch/tag/commit (default: HEAD)
    name: "Your Name"           # Optional: sets local git user.name
    email: "you@example.com"    # Optional: sets local git user.email
```

### Shell Profile

```yaml
shell_profile_dir: "{{ user_home }}/.profile.d"
shell_profile_managed: true
shell_ssh_agent_enabled: true   # Auto-start SSH agent (Linux only)

# RC files to modify
shell_rc_files:
  - "{{ user_home }}/.bashrc"
  - "{{ user_home }}/.zshrc"

# Custom profile scripts
shell_profile_scripts:
  - name: 20-aliases.sh
    content: |
      alias ll='ls -la'
      alias gs='git status'
```

### Secrets with Ansible Vault

The sudo password is required for Linux package installation and some macOS casks.

#### Step 1: Set your vault password

```bash
# Create vault password file (already in .gitignore)
echo "your-vault-password" > .vault_pass
chmod 600 .vault_pass
```

#### Step 2: Edit the vault file with your sudo password

```bash
# Edit the vault file (will prompt for vault password if not using .vault_pass)
uv run ansible-vault edit inventory/group_vars/all/vault.yml
```

Change `CHANGE_ME` to your actual sudo password:

```yaml
# inventory/group_vars/all/vault.yml
ansible_become_password: "your-actual-sudo-password"
sudo_password: "{{ ansible_become_password }}"
```

#### Step 3: Encrypt the vault file

```bash
# Encrypt the file
uv run ansible-vault encrypt inventory/group_vars/all/vault.yml
```

#### Managing the vault

```bash
# View encrypted contents
uv run ansible-vault view inventory/group_vars/all/vault.yml

# Edit encrypted file
uv run ansible-vault edit inventory/group_vars/all/vault.yml

# Re-encrypt with new password
uv run ansible-vault rekey inventory/group_vars/all/vault.yml
```

The `ansible_become_password` variable is automatically used by Ansible for sudo operations.

## Project Structure

```
ansible-laptop/
├── site.yml                    # Main entry point
├── ansible.cfg                 # Ansible configuration
├── requirements.yml            # Galaxy dependencies
├── pyproject.toml              # Python/uv configuration
├── Makefile                    # Convenience commands
├── inventory/
│   ├── hosts.yml               # Host inventory
│   └── group_vars/
│       ├── all/main.yml        # Common variables
│       ├── macos/main.yml      # macOS-specific
│       └── linux/main.yml      # Linux-specific
├── playbooks/
│   ├── setup.yml               # Initial setup
│   ├── maintenance.yml         # Updates & upgrades
│   ├── doctor.yml              # Health checks
│   ├── ssh.yml                 # SSH only
│   └── shell.yml               # Shell only
└── roles/
    ├── directories/            # Create directories
    ├── homebrew/               # macOS packages
    ├── packages/               # Linux packages
    ├── ssh/                    # SSH configuration
    ├── shell_profile/          # Shell profiles
    ├── git_repos/              # Git repositories
    └── doctor/                 # Health checks
```

## Roles

| Role | Description |
|------|-------------|
| `directories` | Creates directories with configurable permissions |
| `homebrew` | Installs Homebrew packages and casks (macOS) |
| `packages` | Installs packages via apt/dnf/pacman/zypper (Linux) |
| `ssh` | Manages SSH config and keys |
| `shell_profile` | Drop-in shell profile management |
| `git_repos` | Clones repos with per-repo git config |
| `doctor` | Health checks and diagnostics |

## Maintenance

### Regular Updates

```bash
# Update all packages and git repos
make maint
```

### Adding SSH Keys to GitHub/GitLab

After initial setup, add your public keys to your Git hosting service:

```bash
# Display public key
cat ~/.ssh/id_ed25519_personal.pub
```

### Troubleshooting

```bash
# Run health checks
make doctor

# Run strict health checks (fails on issues)
make doctor-strict

# Check syntax
uv run ansible-playbook site.yml --syntax-check

# Verbose output
uv run ansible-playbook site.yml -v
```

## Development

```bash
# Lint playbooks
make lint

# Check syntax
uv run ansible-playbook site.yml --syntax-check
```
