.PHONY: deps sync run setup maint doctor doctor-strict \
        ssh ssh-create-keys shell brew dirs git lint help

# Default to running everything
TAGS ?= all

ifeq ($(TAGS),all)
    TAG_FLAG =
else
    TAG_FLAG = --tags $(TAGS)
endif

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

# Setup & Dependencies
deps: ## Install Ansible Galaxy collections
	uv run ansible-galaxy collection install -r requirements.yml

sync: ## Sync Python dependencies with uv
	uv sync

# Main Commands
run: ## Run site.yml (full configuration)
	@echo "Running site.yml"
	uv run ansible-playbook site.yml $(TAG_FLAG)

setup: ## Initial setup (creates SSH keys)
	@echo "Running initial setup"
	uv run ansible-playbook playbooks/setup.yml

maint: ## Run maintenance (updates packages & repos)
	@echo "Running maintenance"
	uv run ansible-playbook playbooks/maintenance.yml

# Health Checks
doctor: ## Run health checks
	@echo "Running doctor checks"
	uv run ansible-playbook playbooks/doctor.yml

doctor-strict: ## Run strict health checks (fails on issues)
	@echo "Running strict doctor checks"
	uv run ansible-playbook playbooks/doctor.yml -e doctor_strict=true

# Individual Components
ssh: ## Configure SSH only
	uv run ansible-playbook playbooks/ssh.yml

ssh-create-keys: ## Configure SSH and create missing keys
	uv run ansible-playbook playbooks/ssh.yml -e ssh_create_keys=true

shell: ## Configure shell profile only
	uv run ansible-playbook playbooks/shell.yml

brew: ## Run Homebrew role only (macOS)
	$(MAKE) run TAGS=brew

dirs: ## Create directories only
	$(MAKE) run TAGS=dirs

git: ## Clone/update git repos only
	$(MAKE) run TAGS=git

# Development
lint: ## Run ansible-lint
	@echo "Running Ansible Lint"
	uv run ansible-lint site.yml playbooks/*.yml roles/*/tasks/*.yml
