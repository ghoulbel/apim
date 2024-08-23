#!/bin/bash

set -e
set -u

function create_user_and_database() {
    local database=$1
    local username=$2
    local password=$3

    echo "Creating user '$username' and database '$database'"
    psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" <<-EOSQL
      CREATE USER $username WITH PASSWORD '$password';
      CREATE DATABASE $database;
      GRANT ALL PRIVILEGES ON DATABASE $database TO $username;
EOSQL
}

function grant_permissions() {
    local database=$1
    local username=$2
    local schema=$3

    echo "Granting necessary permissions on database '$database' to user '$username'"
    psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$database" <<-EOSQL
      -- Grant permissions on all existing tables and sequences
      GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA $schema TO $username;
      GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA $schema TO $username;

      -- Grant permissions on any tables and sequences created in the future
      ALTER DEFAULT PRIVILEGES IN SCHEMA $schema GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO $username;
      ALTER DEFAULT PRIVILEGES IN SCHEMA $schema GRANT USAGE, SELECT ON SEQUENCES TO $username;
EOSQL
}

# Create 'apim_db' and 'shared_db' and their respective users
create_user_and_database "apim_db" "apimadmin" "apimadmin"
create_user_and_database "shared_db" "sharedadmin" "sharedadmin"

# Grant permissions to the users
# Adjust schema if necessary
grant_permissions "apim_db" "apimadmin" "public"
grant_permissions "shared_db" "sharedadmin" "public"

# Run the SQL script on both databases with their specific files
echo "Running postgresql.sql on database 'apim_db'"
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "apim_db" -f /docker-entrypoint-initdb.d/apimgt/postgresql.sql

echo "Running postgresql.sql on database 'shared_db'"
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "shared_db" -f /docker-entrypoint-initdb.d/postgresql.sql

echo "Databases, users, permissions, and SQL scripts executed"
