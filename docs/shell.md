# Shell Configuration

Drop-in based shell profile management.

## How It Works

1. Creates `~/.profile.d/` directory
2. Adds a loader block to shell rc files (`.bashrc`, `.zshrc`)
3. Sources all `*.sh` files from profile.d in alphabetical order

The loader block added to your rc files:

```bash
# BEGIN ANSIBLE MANAGED - profile.d loader
# Source all scripts in ~/.profile.d
if [ -d "$HOME/.profile.d" ]; then
  for f in "$HOME/.profile.d"/*.sh; do
    [ -r "$f" ] && . "$f"
  done
  unset f
fi
# END ANSIBLE MANAGED - profile.d loader
```

## Profile Scripts

Scripts are named with numeric prefixes for ordering:

| Script | Purpose |
|--------|---------|
| `10-ssh-agent.sh` | SSH agent initialization (auto-deployed on Linux) |
| `20-path.sh` | PATH modifications |
| `30-env.sh` | Environment variables |
| `50-aliases.sh` | Shell aliases |

## Usage

```bash
# Deploy shell profile configuration
make shell
```

## Configuration

In `inventory/group_vars/all/main.yml`:

```yaml
# Enable shell profile management
shell_profile_managed: true

# Drop-in directory location
shell_profile_dir: "{{ user_home }}/.profile.d"

# RC files to add the loader to
shell_rc_files:
  - "{{ user_home }}/.bashrc"
  - "{{ user_home }}/.zshrc"

# Auto-start SSH agent (Linux only, macOS uses keychain)
shell_ssh_agent_enabled: true

# Custom scripts to deploy
shell_profile_scripts: []
```

## Custom Scripts

Add custom profile scripts via configuration:

```yaml
shell_profile_scripts:
  - name: 20-path.sh
    content: |
      # Add local bin to PATH
      export PATH="$HOME/.local/bin:$PATH"
      export PATH="$HOME/go/bin:$PATH"

  - name: 30-env.sh
    content: |
      export EDITOR=nvim
      export VISUAL=nvim

  - name: 50-aliases.sh
    content: |
      alias ll='ls -la'
      alias gs='git status'
      alias gp='git push'
      alias gc='git commit'
```

## SSH Agent (Linux)

On Linux systems, the `10-ssh-agent.sh` script is automatically deployed when `shell_ssh_agent_enabled: true`. It:

1. Starts `ssh-agent` if not already running
2. Adds configured SSH keys automatically

**macOS**: SSH agent management is handled by the system keychain via `UseKeychain` and `AddKeysToAgent` options in SSH config. No shell script is needed.

## Ordering

Scripts are sourced in alphabetical order. Use numeric prefixes to control order:

- `10-*` - Early initialization (agents, environment setup)
- `20-*` - PATH modifications
- `30-*` - Environment variables
- `50-*` - Aliases and functions
- `90-*` - Late initialization

## Manual Script Management

You can also manually add scripts to `~/.profile.d/`:

```bash
# Create a custom script
cat > ~/.profile.d/99-custom.sh << 'EOF'
# My custom configuration
export MY_VAR="value"
EOF

# Make it executable (optional, but good practice)
chmod +x ~/.profile.d/99-custom.sh

# Reload shell or source manually
source ~/.profile.d/99-custom.sh
```

## Troubleshooting

### Scripts not loading

1. Check if the loader block exists in your rc file:
   ```bash
   grep -A5 "ANSIBLE MANAGED" ~/.bashrc
   ```

2. Verify scripts exist and are readable:
   ```bash
   ls -la ~/.profile.d/
   ```

3. Re-run the shell role:
   ```bash
   make shell
   ```

### SSH agent not starting

```bash
# Check if SSH agent script exists
cat ~/.profile.d/10-ssh-agent.sh

# Manually start agent
eval "$(ssh-agent -s)"

# Add keys
ssh-add ~/.ssh/id_ed25519_personal
```

### Existing rc file permissions

The role preserves existing file permissions. If you need to reset:

```bash
chmod 644 ~/.bashrc ~/.zshrc
```
