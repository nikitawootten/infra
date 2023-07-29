#!/usr/bin/env bash

set -e

KC_DB_NAME=keycloak

# Create the keycloak database
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
	CREATE USER $KC_DB_USERNAME WITH PASSWORD '$KC_DB_PASSWORD';
	CREATE DATABASE $KC_DB_NAME;
	GRANT ALL PRIVILEGES ON DATABASE $KC_DB_NAME TO $KC_DB_USERNAME;
EOSQL

# Grant schema public permissions
# For those in the future running into the following error:
# Failed to create lock table. Maybe other transaction created in the meantime. Retrying...: liquibase.exception.DatabaseException: ERROR: permission denied for schema public
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$KC_DB_NAME" <<-EOSQL
	GRANT ALL ON SCHEMA public TO $KC_DB_USERNAME;
EOSQL
