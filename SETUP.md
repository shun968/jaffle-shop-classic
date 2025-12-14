# Setup Guide

This document explains how to set up the development environment for this project.

## Prerequisites

- Python 3.8 or higher installed
- Git installed
- Docker and Docker Compose installed (for local PostgreSQL database)
  - Or access to an existing database (PostgreSQL, Snowflake, BigQuery, etc.)

## Setup Steps

### 1. Clone the Repository

```bash
git clone <repository-url>
cd jaffle-shop-classic
```

### 2. Create and Activate Virtual Environment

```bash
# Create virtual environment
python3 -m venv env

# Activate virtual environment
# macOS/Linux
source env/bin/activate

# Windows
# env\Scripts\activate
```

### 3. Install Dependencies

```bash
# Upgrade pip to the latest version
pip install --upgrade pip

# Install required packages
pip install -r requirements.txt

# Install the database adapter for your database
# For PostgreSQL
pip install dbt-postgres

# For Snowflake
# pip install dbt-snowflake

# For BigQuery
# pip install dbt-bigquery

# For Redshift
# pip install dbt-redshift

# For DuckDB
# pip install dbt-duckdb
```

### 4. Set Up Local PostgreSQL Database (Docker)

This project includes a Docker Compose configuration for running a local PostgreSQL database.

#### Option A: Using Docker Compose (Recommended)

```bash
# Start PostgreSQL container
docker compose up -d postgres

# Check container status
docker compose ps postgres

# View logs
docker compose logs -f postgres
```

#### Option B: Using the Helper Script

```bash
# Start PostgreSQL
./scripts/docker-db.sh start

# Check status
./scripts/docker-db.sh status

# Stop PostgreSQL
./scripts/docker-db.sh stop

# Open PostgreSQL shell
./scripts/docker-db.sh shell
```

### 5. Configure dbt Profile

```bash
# Create dbt profile directory (if it doesn't exist)
mkdir -p ~/.dbt

# Copy the profile template
cp profiles.yml.example ~/.dbt/profiles.yml

# Edit the profile to set your actual database connection information
# Open ~/.dbt/profiles.yml in your editor and edit it
```

Alternatively, if using environment variables:

```bash
# Copy env.example to .env
cp env.example .env

# Edit .env file to set your actual values
# Open .env in your editor and edit it
```

### 6. Set Up direnv (Optional)

To enable automatic virtual environment activation:

```bash
# Install direnv (if not already installed)
# macOS
brew install direnv

# Integrate with shell (for zsh)
echo 'eval "$(direnv hook zsh)"' >> ~/.zshrc
source ~/.zshrc

# Allow direnv in this project
direnv allow
```

### 7. Verify dbt Connection

```bash
# Verify dbt configuration
dbt debug
```

If the connection is successful, you should see a message like:

```text
Connection test: [OK connection ok]
```

### 8. Load Data and Run Models

```bash
# Load seed data (CSV files)
dbt seed

# Run models
dbt run

# Run tests
dbt test

# Generate documentation
dbt docs generate

# View documentation
dbt docs serve
```

## Troubleshooting

### Virtual Environment Not Activating

- If the prompt doesn't change after running `source env/bin/activate`, restart your shell
- If using direnv, run `direnv allow`

### dbt Connection Errors

- Verify the settings in `~/.dbt/profiles.yml`
- Ensure the database is running
- Check firewall and network settings

### Package Installation Errors

- Verify that Python version is 3.8 or higher
- Run `pip install --upgrade pip` to upgrade pip to the latest version

## Reference Links

- [dbt Official Documentation](https://docs.getdbt.com/)
- [dbt Installation Guide](https://docs.getdbt.com/docs/installation)
- [dbt Profile Configuration](https://docs.getdbt.com/docs/configure-your-profile)
