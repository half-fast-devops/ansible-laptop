# Doctor

Health checks and diagnostics for your laptop configuration.

## What It Checks

| Check | Description |
|-------|-------------|
| **SSH directory** | Ensures `~/.ssh` exists with mode 0700 |
| **SSH connectivity** | Tests authentication to configured hosts |
| **Shell profile** | Verifies `~/.profile.d` directory exists |
| **Essential commands** | Checks for required CLI tools |

## Usage

```bash
# Run health checks (warnings only)
make doctor

# Run strict mode (fails on issues)
make doctor-strict

# Or with ansible-playbook directly
uv run ansible-playbook playbooks/doctor.yml
uv run ansible-playbook playbooks/doctor.yml -e doctor_strict=true
```

## Sample Output

```
TASK [doctor : Validate SSH directory permissions] ***
ok: [localhost] => {
    "msg": "SSH directory permissions OK"
}

TASK [doctor : Report SSH connectivity status] ***
ok: [localhost] => (item=...) => {
    "msg": "SSH to git@github.com: OK"
}

TASK [doctor : Report shell profile status] ***
ok: [localhost] => {
    "msg": "Shell profile directory /Users/user/.profile.d: EXISTS"
}

TASK [doctor : Report command availability] ***
ok: [localhost] => (item=...) => {
    "msg": "Command 'git': FOUND at /usr/bin/git"
}

TASK [doctor : Summary] ***
ok: [localhost] => {
    "msg": "=== Doctor Summary ===\n
           SSH Directory: OK\n
           Profile Directory: OK\n
           Commands: 3/3 available"
}
```

## Configuration

In `inventory/group_vars/all/main.yml`:

```yaml
# Doctor configuration
doctor_strict: false              # Set true to fail on issues

# SSH hosts to test connectivity
doctor_ssh_hosts:
  - git@github.com
  - git@gitlab.com

# Commands that should be available
doctor_essential_commands:
  - git
  - ssh
  - curl
```

In role defaults (`roles/doctor/defaults/main.yml`):

```yaml
doctor_strict: false

doctor_ssh_hosts:
  - git@github.com

doctor_essential_commands:
  - git
  - ssh
  - curl
```

## Strict Mode

| Mode | Behavior |
|------|----------|
| Normal (`doctor_strict: false`) | Reports issues as warnings, continues execution |
| Strict (`doctor_strict: true`) | Fails immediately on any issue |

Use strict mode for:
- CI/CD pipelines
- Ensuring clean state before deployment
- Automated health checks

```bash
# Strict mode via make
make doctor-strict

# Strict mode via command line
uv run ansible-playbook playbooks/doctor.yml -e doctor_strict=true
```

## SSH Connectivity Check

The SSH check tests authentication using:

```bash
ssh -o BatchMode=yes -o ConnectTimeout=5 -T <host>
```

**Success indicators**:
- Return code 0 or 1 (authenticated but no shell)
- Output contains "successfully authenticated" or "Welcome"

**Common results**:
- GitHub: Returns code 1 with "successfully authenticated" message
- GitLab: Returns code 1 with "Welcome" message
- Custom servers: Varies by configuration

## Customizing Checks

### Add more SSH hosts

```yaml
doctor_ssh_hosts:
  - git@github.com
  - git@gitlab.com
  - git@bitbucket.org
  - myuser@myserver.com
```

### Add essential commands

```yaml
doctor_essential_commands:
  - git
  - ssh
  - curl
  - python3
  - node
  - docker
```

## Troubleshooting

### SSH directory permissions wrong

```bash
# Fix manually
chmod 700 ~/.ssh
chmod 600 ~/.ssh/*

# Or re-run SSH role
make ssh
```

### SSH connectivity failing

1. Check if key is added to ssh-agent:
   ```bash
   ssh-add -l
   ```

2. Test manually:
   ```bash
   ssh -vT git@github.com
   ```

3. Verify public key is added to service (GitHub, GitLab, etc.)

### Command not found

Install the missing package:

```bash
# macOS
brew install <package>

# Debian/Ubuntu
sudo apt install <package>

# Fedora
sudo dnf install <package>

# Arch Linux
sudo pacman -S <package>

# OpenSUSE
sudo zypper install <package>
```

Or re-run package installation:

```bash
make run TAGS=packages
```

## Integration with CI

Example GitHub Actions workflow:

```yaml
- name: Run health checks
  run: |
    make deps
    make doctor-strict
```

The strict mode will fail the CI job if any checks don't pass.
