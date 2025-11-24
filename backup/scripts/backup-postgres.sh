#!/bin/bash
set -euo pipefail

BACKUP_DIR="${BACKUP_DIR:-/backup/postgresql}"
RETENTION_DAYS="${RETENTION_DAYS:-30}"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="${BACKUP_DIR}/db_backup_${TIMESTAMP}.sql.gz"

mkdir -p "$BACKUP_DIR"

# Perform backup
pg_dump --format=custom --verbose "$@" | gzip > "$BACKUP_FILE"

echo "Backup complete: $BACKUP_FILE"

# Cleanup old backups
find "$BACKUP_DIR" -name "db_backup_*.sql.gz" -mtime +${RETENTION_DAYS} -delete

exit 0

