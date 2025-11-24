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

- `backup-postgres.sh`: PostgreSQL full backup with compression
- `backup-filesystem.sh`: Incremental filesystem backups
- `recovery-procedure.sh`: Automated recovery verification

## Usage

./backup/scripts/backup-postgres.sh

## License

MIT


