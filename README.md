# disaster-recovery-toolkit

Backup and disaster recovery tools and frameworks.

## Components

- **backup/**: Automated backup scripts
  - PostgreSQL, MySQL, filesystem backups
  - Retention and cleanup policies
- **recovery/**: Runbooks and recovery procedures
- **monitoring/**: Backup health checks
- **templates/**: Configuration templates

## Key Scripts

- `backup-postgres.sh`: PostgreSQL single-database backup with compression
- `/usr/local/bin/pg-backup.sh`: Cluster-wide PostgreSQL backup using `pg_dumpall` to `/backup/postgresql` with 30‑day retention, triggered daily by `pg-backup.timer`
- `backup-filesystem.sh`: Incremental filesystem backups for critical service data
- `recovery-procedure.sh`: Automated recovery verification and integrity checks for restored data

## Usage

./backup/scripts/backup-postgres.sh

## License

MIT


# Test sync
