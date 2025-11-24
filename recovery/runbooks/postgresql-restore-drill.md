# PostgreSQL Restore Drill Runbook

## Objective

Verify that cluster-wide backups in `/backup/postgresql` can be restored into a clean PostgreSQL instance and that core application databases (`forgejo`, `vaultwarden`) are usable.

## Prerequisites

- Access to srv-m1m with sudo
- Recent backup file in `/backup/postgresql/all_databases_*.sql.gz`
- Disposable PostgreSQL instance (local or container) with no critical data

## Procedure

### 1. Select Backup

List available backups and pick the most recent:

ls -lh /backup/postgresql/all_databases_*.sql.gz
BACKUP=/backup/postgresql/all_databases_YYYYMMDD_HHMMSS.sql.gz

### 2. Prepare Target Instance

Start a clean PostgreSQL instance (example using a local test cluster or container):

Example: local test cluster on alternate data dir
sudo -u postgres initdb -D /var/lib/pgsql/test-data
sudo -u postgres pg_ctl -D /var/lib/pgsql/test-data -o "-p 55432" start

Ensure it is listening only on localhost.

### 3. Restore Backup

Restore all databases and globals:

gzip -dc "$BACKUP" | psql -h localhost -p 55432 -U postgres

Monitor output for errors.

### 4. Verify Databases

Confirm core databases exist:

Monitor output for errors.

### 4. Verify Databases

Confirm core databases exist:

psql -h localhost -p 55432 -U postgres -c "SELECT datname FROM pg_database WHERE datname IN ('forgejo', 'vaultwarden');"

Optionally run basic integrity checks (connect and list tables).

### 5. Cleanup

After verification:

sudo -u postgres pg_ctl -D /var/lib/pgsql/test-data stop
sudo rm -rf /var/lib/pgsql/test-data

## Success Criteria

- Restore completes without errors.
- `forgejo` and `vaultwarden` databases exist and are accessible.
- Drill steps are reproducible and updated if tooling or paths change.



