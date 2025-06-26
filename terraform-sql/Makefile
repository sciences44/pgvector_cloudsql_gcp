# Terraform deployment Makefile
# Usage: make [target] [ENV=dev|preprod|prod]

# Default environment is dev
ENV ?= dev

# Verify environment is valid
ifeq ($(filter $(ENV),dev preprod prod),)
$(error ENV must be one of: dev, preprod, prod)
endif

# Define paths
ENV_DIR = environments/$(ENV)
TFVARS_FILE = $(ENV_DIR)/terraform.tfvars
TFVARS_EXAMPLE = $(ENV_DIR)/terraform.tfvars.example

# Main targets
.PHONY: help init plan apply destroy clean set-env check-env run-python

help:
	@echo "GCP PGVector Database Infrastructure Management"
	@echo ""
	@echo "Usage:"
	@echo "  make [target] [ENV=dev|preprod|prod]"
	@echo ""
	@echo "Targets:"
	@echo "  help     - Show this help message"
	@echo "  init     - Initialize Terraform in the selected environment"
	@echo "  plan     - Show what Terraform will create/change"
	@echo "  apply    - Create/update resources"
	@echo "  destroy  - Remove all resources (requires confirmation)"
	@echo "  clean    - Remove Terraform state files and temporary files"
	@echo "  set-env  - Only setup environment variables for scripts"
	@echo "  run-python SCRIPT=path/to/script.py - Run a Python script with the selected environment"
	@echo ""
	@echo "Current environment: $(ENV)"

check-env:
	@if [ ! -d "$(ENV_DIR)" ]; then \
		echo "Error: Environment directory $(ENV_DIR) does not exist"; \
		exit 1; \
	fi

# Check if tfvars exists, if not create from example
setup-tfvars: check-env
	@if [ ! -f "$(TFVARS_FILE)" ]; then \
		if [ -f "$(TFVARS_EXAMPLE)" ]; then \
			echo "Creating $(TFVARS_FILE) from example..."; \
			cp "$(TFVARS_EXAMPLE)" "$(TFVARS_FILE)"; \
			echo "Please edit $(TFVARS_FILE) with your actual values before deploying"; \
			exit 1; \
		else \
			echo "Error: $(TFVARS_EXAMPLE) not found"; \
			exit 1; \
		fi; \
	fi

# Initialize Terraform
init: setup-tfvars
	@echo "Initializing Terraform in $(ENV) environment..."
	@cd $(ENV_DIR) && terraform init

# Show plan
plan: init
	@echo "Planning Terraform changes for $(ENV) environment..."
	@cd $(ENV_DIR) && terraform plan

# Apply changes
apply: init
	@echo "Applying Terraform changes for $(ENV) environment..."
	@cd $(ENV_DIR) && terraform apply

# Destroy resources with confirmation
destroy: init
	@echo "WARNING: This will destroy all resources in the $(ENV) environment."
	@read -p "Are you sure? Type 'yes' to confirm: " confirm; \
	if [ "$$confirm" = "yes" ]; then \
		echo "Destroying all resources in $(ENV) environment..."; \
		cd $(ENV_DIR) && terraform destroy; \
	else \
		echo "Destroy operation cancelled."; \
	fi

# Destroy resources but keep the project with confirmation
destroy-keep-project: init
	@echo "WARNING: This will destroy all resources EXCEPT the project itself in the $(ENV) environment."
	@read -p "Are you sure? Type 'yes' to confirm: " confirm; \
	if [ "$$confirm" = "yes" ]; then \
		echo "Destroying resources in $(ENV) environment..."; \
		cd $(ENV_DIR) && terraform destroy -target="module.sql.google_sql_database_instance.postgres_instance" \
			-target="module.sql.google_sql_database.default" \
			-target="module.sql.google_sql_user.default" \
			-target="module.vpc.google_compute_network.vector_database[0]" \
			-target="module.vpc.google_compute_global_address.private_ip_range[0]" \
			-target="module.vpc.google_service_networking_connection.private_vpc_connection[0]" \
			-target="module.vpc.google_compute_firewall.vector_allow_internal[0]" \
			-target="module.vpc.google_compute_firewall.vector_allow_ssh[0]" \
			-target="module.project.google_project_service.services"; \
	else \
		echo "Destroy operation cancelled."; \
	fi

# Clean Terraform files
clean: check-env
	@echo "Cleaning Terraform files in $(ENV) environment..."
	@cd $(ENV_DIR) && rm -rf .terraform .terraform.lock.hcl terraform.tfstate terraform.tfstate.backup
	@echo "Cleanup complete."

# Set environment for Python scripts
set-env: check-env
	@echo "Setting environment variables for $(ENV)..."
	@echo "Run this command to set the environment variable:"
	@echo "export ENV=$(ENV)"

# Run a Python script with the correct environment
run-python: check-env
	@if [ -z "$(SCRIPT)" ]; then \
		echo "Error: No script specified"; \
		echo "Usage: make run-python ENV=$(ENV) SCRIPT=path/to/script.py"; \
		exit 1; \
	fi
	@if [ ! -f "$(SCRIPT)" ]; then \
		echo "Error: Script $(SCRIPT) not found"; \
		exit 1; \
	fi
	@echo "Running $(SCRIPT) with environment $(ENV)..."
	@ENV=$(ENV) DB_USER=$(DB_USER) DB_PASSWORD=$(DB_PASSWORD) python $(SCRIPT)
