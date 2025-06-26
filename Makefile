# Root Makefile for PGVector on CloudSQL
# Usage: make [target] [ENV=dev|preprod|prod] [SCRIPT=path/to/script.py] [DB_USER=username] [DB_PASSWORD=password]

# Default environment and parameters
ENV ?= dev
DB_USER ?= myuser
DB_PASSWORD ?= your-secure-password
SCRIPT ?= 

# Use automatic variables to get project directory
PROJECT_ROOT := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
TERRAFORM_ROOT := $(PROJECT_ROOT)/terraform-sql

# Colors for better readability
CYAN := \033[36m
GREEN := \033[32m
YELLOW := \033[33m
RED := \033[31m
RESET := \033[0m
BOLD := \033[1m

# Targets
.PHONY: help tf-init tf-plan tf-apply tf-destroy tf-clean env run-simple-demo connect-db install-deps setup-db add-sample-data check-db

help:
	@echo "$(BOLD)$(CYAN)PGVector RAG on CloudSQL Project$(RESET)"
	@echo ""
	@echo "$(BOLD)Usage:$(RESET)"
	@echo "  make [target] [ENV=dev|preprod|prod] [DB_USER=username] [DB_PASSWORD=password]"
	@echo ""
	@echo "$(BOLD)Environment:$(RESET)"
	@echo "  env         - Display current environment settings"
	@echo ""
	@echo "$(BOLD)Terraform Targets:$(RESET)"
	@echo "  tf-help     - Show Terraform help message"
	@echo "  tf-init     - Initialize Terraform in the selected environment"
	@echo "  tf-plan     - Show what Terraform will create/change"
	@echo "  tf-apply    - Create/update resources"
	@echo "  tf-destroy  - Remove all resources (requires confirmation)"
	@echo "  tf-clean    - Remove Terraform state files and temporary files"
	@echo ""
	@echo "$(BOLD)Database Operations:$(RESET)"
	@echo "  setup-db            - Set up database schema (create extension and tables)"
	@echo "  add-sample-data     - Add sample data to the database"
	@echo "  check-db            - Check database status and count products"
	@echo "  run-simple-demo     - Run a simple SQL query to show database contents"
	@echo "  connect-db          - Connect to the database with selected environment"
	@echo ""
	@echo "$(BOLD)Setup:$(RESET)"
	@echo "  install-deps        - Install Python dependencies"
	@echo ""
	@echo "$(BOLD)Current Environment:$(RESET) $(YELLOW)$(ENV)$(RESET)"

# Wrapper targets for terraform-sql
tf-help:
	@make -C terraform-sql help ENV=$(ENV)

tf-init:
	@make -C terraform-sql init ENV=$(ENV)

tf-plan:
	@make -C terraform-sql plan ENV=$(ENV)

tf-apply:
	@make -C terraform-sql apply ENV=$(ENV)

tf-destroy:
	@make -C terraform-sql destroy ENV=$(ENV)

tf-clean:
	@make -C terraform-sql clean ENV=$(ENV)

# Environment information
env:
	@echo "$(BOLD)Environment Settings:$(RESET)"
	@echo "  Environment: $(YELLOW)$(ENV)$(RESET)"
	@echo "  Database user: $(DB_USER)"
	@echo "  Database password: $(if $(filter your-secure-password,$(DB_PASSWORD)),$(RED)default - insecure$(RESET),$(GREEN)custom - set$(RESET))"
	@echo ""
	@echo "To change these settings, use:"
	@echo "  make [target] ENV=dev|preprod|prod DB_USER=username DB_PASSWORD=password"

# Demo applications (simplified without embeddings)
run-simple-demo:
	@echo "$(BOLD)Running simplified database demo with $(YELLOW)$(ENV)$(RESET) environment...$(RESET)"
	@cd $(TERRAFORM_ROOT)/environments/$(ENV) && \
	DB_HOST=$$(terraform output -raw public_ip_address 2>/dev/null || echo "Not available"); \
	DB_NAME=$$(terraform output -raw database_name 2>/dev/null || echo "mydatabase"); \
	if [ "$$DB_HOST" = "Not available" ]; then \
		echo "$(RED)Error: Database IP address not available. Run 'make tf-apply' first.$(RESET)"; \
		exit 1; \
	fi; \
	echo "$(GREEN)Database Information:$(RESET)"; \
	echo "  Host: $$DB_HOST"; \
	echo "  Name: $$DB_NAME"; \
	echo "  User: $(DB_USER)"; \
	echo "$(YELLOW)Fetching products from database...$(RESET)"; \
	PGPASSWORD=$(DB_PASSWORD) psql -h $$DB_HOST -U $(DB_USER) -d $$DB_NAME -p 5432 -c "SELECT id, name, description, price, category FROM products;" && \
	echo "$(GREEN)Database demo complete!$(RESET)"

# Database connection utility
connect-db:
	@if [ "$(ENV)" = "dev" ]; then \
		echo "$(BOLD)Connecting to $(YELLOW)$(ENV)$(RESET) database...$(RESET)"; \
		cd $(TERRAFORM_ROOT)/environments/$(ENV) && \
		DB_HOST=$$(terraform output -raw public_ip_address 2>/dev/null || echo "Not available"); \
		DB_NAME=$$(terraform output -raw database_name 2>/dev/null || echo "mydatabase"); \
		if [ "$$DB_HOST" = "Not available" ]; then \
			echo "$(RED)Error: Database IP address not available. Run 'make tf-apply' first.$(RESET)"; \
			exit 1; \
		fi; \
		echo "$(GREEN)Connecting to: $$DB_HOST$(RESET)"; \
		PGPASSWORD=$(DB_PASSWORD) psql -h $$DB_HOST -U $(DB_USER) -d $$DB_NAME -p 5432; \
	else \
		echo "$(RED)Direct database connection only available for dev environment.$(RESET)"; \
		echo "For $(YELLOW)$(ENV)$(RESET) environment, you need a bastion host or Cloud SQL Proxy."; \
	fi

# Install Python dependencies
install-deps:
	@echo "$(BOLD)Installing Python dependencies...$(RESET)"
	@uv sync
	@echo "$(GREEN)Dependencies installed successfully!$(RESET)"

# Database setup without Python scripts
setup-db:
	@echo "$(BOLD)Setting up database in $(YELLOW)$(ENV)$(RESET) environment...$(RESET)"
	@cd $(TERRAFORM_ROOT)/environments/$(ENV) && \
	DB_HOST=$$(terraform output -raw public_ip_address 2>/dev/null || echo "localhost"); \
	DB_NAME=$$(terraform output -raw database_name 2>/dev/null || echo "mydatabase"); \
	PROJECT_ID=$$(terraform output -raw project_id 2>/dev/null || echo "sandbox-pgvector-project7"); \
	echo "$(GREEN)Database host: $$DB_HOST$(RESET)"; \
	echo "$(GREEN)Database name: $$DB_NAME$(RESET)"; \
	echo "$(GREEN)Project ID: $$PROJECT_ID$(RESET)"; \
	echo "$(YELLOW)Executing SQL setup commands...$(RESET)"; \
	PGPASSWORD=$(DB_PASSWORD) psql -h $$DB_HOST -U $(DB_USER) -d $$DB_NAME -p 5432 -c "CREATE EXTENSION IF NOT EXISTS vector;" && \
	PGPASSWORD=$(DB_PASSWORD) psql -h $$DB_HOST -U $(DB_USER) -d $$DB_NAME -p 5432 -c "CREATE TABLE IF NOT EXISTS products (id SERIAL PRIMARY KEY, name VARCHAR(255) NOT NULL, description TEXT, price DECIMAL(10, 2), category VARCHAR(100), embedding VECTOR(768));" && \
	echo "$(GREEN)Database setup complete! Vector extension and products table created.$(RESET)"

# Add sample data to products
add-sample-data:
	@echo "$(BOLD)Adding sample data to database in $(YELLOW)$(ENV)$(RESET) environment...$(RESET)"
	@cd $(TERRAFORM_ROOT)/environments/$(ENV) && \
	DB_HOST=$$(terraform output -raw public_ip_address 2>/dev/null || echo "localhost"); \
	DB_NAME=$$(terraform output -raw database_name 2>/dev/null || echo "mydatabase"); \
	echo "$(YELLOW)Adding sample products...$(RESET)"; \
	PGPASSWORD=$(DB_PASSWORD) psql -h $$DB_HOST -U $(DB_USER) -d $$DB_NAME -p 5432 -c "INSERT INTO products (name, description, price, category) VALUES ('Smartphone XYZ', 'High-performance smartphone with 6.7-inch display and 5G connectivity', 999.99, 'Electronics') ON CONFLICT (id) DO NOTHING;" && \
	PGPASSWORD=$(DB_PASSWORD) psql -h $$DB_HOST -U $(DB_USER) -d $$DB_NAME -p 5432 -c "INSERT INTO products (name, description, price, category) VALUES ('Coffee Maker', 'Programmable coffee maker with built-in grinder', 149.99, 'Kitchen Appliances') ON CONFLICT (id) DO NOTHING;" && \
	PGPASSWORD=$(DB_PASSWORD) psql -h $$DB_HOST -U $(DB_USER) -d $$DB_NAME -p 5432 -c "INSERT INTO products (name, description, price, category) VALUES ('Hiking Boots', 'Waterproof hiking boots with excellent traction', 129.99, 'Outdoor') ON CONFLICT (id) DO NOTHING;" && \
	echo "$(GREEN)Sample data added successfully!$(RESET)"

# Check database status
check-db:
	@echo "$(BOLD)Checking database in $(YELLOW)$(ENV)$(RESET) environment...$(RESET)"
	@cd $(TERRAFORM_ROOT)/environments/$(ENV) && \
	DB_HOST=$$(terraform output -raw public_ip_address 2>/dev/null || echo "Not available"); \
	DB_NAME=$$(terraform output -raw database_name 2>/dev/null || echo "mydatabase"); \
	if [ "$$DB_HOST" = "Not available" ]; then \
		echo "$(RED)Error: Database IP address not available. Run 'make tf-apply' first.$(RESET)"; \
		exit 1; \
	fi; \
	echo "$(GREEN)Database host: $$DB_HOST$(RESET)"; \
	echo "$(GREEN)Database name: $$DB_NAME$(RESET)"; \
	echo "$(YELLOW)Checking products table...$(RESET)"; \
	PGPASSWORD=$(DB_PASSWORD) psql -h $$DB_HOST -U $(DB_USER) -d $$DB_NAME -p 5432 -c "SELECT COUNT(*) AS product_count FROM products;" && \
	echo "$(GREEN)Database check complete!$(RESET)"
