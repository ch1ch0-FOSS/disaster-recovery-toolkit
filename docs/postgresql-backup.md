# PostgreSQL Backup Strategy

## Overview

PostgreSQL backups run locally on the srv-m1m host using a combination of `pg_dumpall`, gzip compression, and systemd timers. Backups are stored on dedicated disk under `/backup/postgresql` with 30‑day retention.

## Backup Command

Cluster-wide backups use `pg_dumpall`:

pg_dumpall --verbose | gzip > /backup/postgresql/all_databases_<TIMESTAMP>.sql.gz

This captures all databases and global objects (roles, tablespaces) in a single compressed file.

## Storage and Retention

- **Directory**: `/backup/postgresql`
- **Ownership**: `postgres:postgres`
- **Permissions**: `750`
- **Retention**: 30 days (old backups deleted automatically)

## Automation

Backups are driven by:

- **Script**: `/usr/local/bin/pg-backup.sh`
- **Service**: `pg-backup.service`
- **Timer**: `pg-backup.timer`

Timer schedule:

[Timer]
OnCalendar=daily
Persistent=true

Backups run once per day shortly after midnight and will catch up on missed runs.



