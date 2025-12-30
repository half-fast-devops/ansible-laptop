# Quickstart Guide

Get your new machine configured in 5 minutes.

## TL;DR

```bash
# 1. Install prerequisites (macOS)
brew install python@3.12 && curl -LsSf https://astral.sh/uv/install.sh | sh

# 2. Clone and setup
git clone <your-repo> ~/ansible-laptop && cd ~/ansible-laptop
uv sync && make deps

# 3. Configure (edit to your needs)
vi inventory/group_vars/all/main.yml

# 4. Run
make setup

# 5. Verify
make doctor
```

## Step-by-Step

### Step 1: Install Prerequisites

#### macOS

```bash
# Install Homebrew (if not already installed)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install Python and uv
brew install python@3.12
curl -LsSf https://astral.sh/uv/install.sh | sh

# Restart shell or source profile
source ~/.zshrc  # or ~/.bashrc
```

#### Ubuntu/Debian

```bash
sudo apt update
sudo apt install -y python3 python3-pip git curl
curl -LsSf https://astral.sh/uv/install.sh | sh
source ~/.bashrc
```

#### Fedora

```bash
sudo dnf install -y python3 python3-pip git curl
curl -LsSf https://astral.sh/uv/install.sh | sh
source ~/.bashrc
```

#### Arch Linux

```bash
sudo pacman -S python python-pip git curl
curl -LsSf https://astral.sh/uv/install.sh | sh
source ~/.bashrc
```

#### OpenSUSE

```bash
sudo zypper install -y python3 python3-pip git curl
curl -LsSf https://astral.sh/uv/install.sh | sh
source ~/.bashrc
```

### Step 2: Clone Repository

```bash
git clone <your-repo-url> ~/ansible-laptop
cd ~/ansible-laptop
```

### Step 3: Install Dependencies

```bash
# Install Python dependencies
uv sync

# Install Ansible Galaxy collections
make deps
```

### Step 4: Configure

Edit the main configuration file:

```bash
vi inventory/group_vars/all/main.yml
```

#### Minimal Configuration

```yaml
# Directories to create
directories:
  - "{{ user_home }}/code"
  - "{{ user_home }}/work"

# SSH identity (optional - remove if you have existing keys)
ssh_identities:
  - name: personal
    key_type: ed25519
    create_if_missing: true

# SSH host config (optional)
ssh_hosts:
  - name: github.com
    hostname: github.com
    user: git
    identity_file: "{{ user_home }}/.ssh/id_ed25519_personal"

# Git repos to clone (optional)
git_repos: []
```

#### Configure Packages

**macOS** - Edit `inventory/group_vars/macos/main.yml`:

```yaml
brew_packages:
  - git
  - fzf
  - nvim
  - ripgrep

cask_packages:
  - iterm2
```

**Linux** - Edit `inventory/group_vars/linux/main.yml`:

```yaml
linux_packages:
  - git
  - fzf
  - neovim
  - ripgrep
```

### Step 5: Configure Sudo Password (Linux/Some macOS Casks)

For Linux package installation or macOS casks that need sudo:

```bash
# Set your vault password
echo "your-vault-password" > .vault_pass
chmod 600 .vault_pass

# Edit vault.yml and set your sudo password
uv run ansible-vault edit inventory/group_vars/all/vault.yml
# Change CHANGE_ME to your actual sudo password

# Encrypt the vault file
uv run ansible-vault encrypt inventory/group_vars/all/vault.yml
```

### Step 6: Run Setup

```bash
# Full setup with SSH key creation
make setup

# Or without creating SSH keys
make run
```

### Step 7: Post-Setup Tasks

#### Add SSH Key to GitHub

```bash
# Copy public key
cat ~/.ssh/id_ed25519_personal.pub | pbcopy  # macOS
cat ~/.ssh/id_ed25519_personal.pub | xclip   # Linux

# Add to GitHub: Settings > SSH Keys > New SSH Key
```

#### Test SSH Connection

```bash
ssh -T git@github.com
# Should see: "Hi username! You've successfully authenticated..."
```

#### Verify Configuration

```bash
make doctor
```

## What Gets Configured

| Component | What Happens |
|-----------|--------------|
| **Directories** | Creates ~/code, ~/work, etc. |
| **Packages** | Installs configured packages via Homebrew/apt/dnf/pacman/zypper |
| **SSH** | Creates ~/.ssh, generates keys, deploys SSH config |
| **Shell** | Sets up ~/.profile.d for drop-in scripts, configures SSH agent |
| **Git Repos** | Clones configured repositories |

## Common Workflows

### Re-run After Config Changes

```bash
make run
```

### Update Packages and Repos

```bash
make maint
```

### Only Configure SSH

```bash
make ssh
```

### Check System Health

```bash
make doctor
```

## Troubleshooting

### "uv: command not found"

```bash
# Re-source your shell profile
source ~/.zshrc  # or ~/.bashrc

# Or add to PATH manually
export PATH="$HOME/.cargo/bin:$PATH"
```

### "ansible-galaxy: command not found"

```bash
# Run via uv
uv run ansible-galaxy collection install -r requirements.yml
```

### SSH Key Already Exists

The setup won't overwrite existing keys. To regenerate:

```bash
# Backup existing key
mv ~/.ssh/id_ed25519_personal ~/.ssh/id_ed25519_personal.backup

# Re-run setup
make setup
```

### Permission Denied on Linux

```bash
# Some tasks require sudo
make run  # Will prompt for password when needed
```

## Next Steps

1. Read [SSH Configuration](ssh.md) for multi-account GitHub setup
2. Check [Shell Configuration](shell.md) for custom aliases
3. Review [Architecture](architecture.md) for project structure
