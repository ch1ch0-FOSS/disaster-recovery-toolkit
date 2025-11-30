# disaster-recovery

Tested backup and recovery procedures with documented RTO/RPO metrics. Every procedure validated against real backups.

**Not theoretical.** Production-tested procedures with validated recovery times and documented failure scenarios.

## What This Demonstrates

**For SRE Teams:**

Reliability mindset with disaster recovery designed from first principles. Tested procedures, not just backup scripts. Documented RTO/RPO objectives with quarterly validation. Operational continuity thinking under failure scenarios.

## Proven Recovery Metrics

| Service | RTO | RPO | Backup Frequency | Last Tested |
|---------|-----|-----|------------------|-------------|
| PostgreSQL (Vaultwarden) | <15min | <24hrs | Daily | 2025-11-28 |
| Forgejo Git Data | <30min | <24hrs | Daily | 2025-11-27 |
| System Configuration | <10min | <1hr | Daily | 2025-11-29 |
| Service Data (Syncthing) | <20min | <24hrs | Daily | 2025-11-26 |

**RTO (Recovery Time Objective):** Maximum acceptable downtime  
**RPO (Recovery Point Objective):** Maximum acceptable data loss

All metrics validated through actual restore tests, not estimates.

## Architecture

backup/
├── scripts/
│ ├── backup-postgres.sh # PostgreSQL database dumps
│ ├── backup-forgejo.sh # Git repository data
│ ├── backup-filesystem.sh # Service configuration files
│ └── backup-all.sh # Orchestrates all backup jobs
├── retention/
│ └── cleanup-old-backups.sh # 30-day retention enforcement
└── validation/
└── verify-backup-integrity.sh # Post-backup integrity checks

recovery/
├── runbooks/
│ ├── restore-postgres.md # Step-by-step PostgreSQL recovery
│ ├── restore-forgejo.md # Git data restoration procedure
│ └── restore-system.md # System configuration recovery
├── scripts/
│ ├── restore-postgres.sh # Automated PostgreSQL restore
│ ├── restore-forgejo.sh # Automated Forgejo restore
│ └── recovery-procedure.sh # Validation and integrity checks
└── failure-scenarios/
└── common-failures.md # Documented failure patterns

monitoring/
├── backup-health-check.sh # Daily backup validation
├── alerting/
│ └── systemd-email-on-failure.service # Email alerts on backup failure
└── logs/
└── backup-history.log # Historical backup records

templates/
├── backup-script.template.sh # Template for new backup scripts
├── restore-runbook.template.md # Template for recovery documentation
└── systemd-timer.template # Template for backup scheduling


## Key Scripts

### Automated Backups

**PostgreSQL Cluster Backup:**

/usr/local/bin/pg-backup.sh

- Output: `/backup/postgresql/pg_dumpall-YYYYMMDD-HHMMSS.sql.gz`
- Compression: gzip (typically 70-80% reduction)
- Retention: 30 days automatic cleanup
- Execution: Daily via `pg-backup.timer` (systemd)
- Validation: Integrity check post-backup

**Forgejo Git Repository Backup:**

/usr/local/bin/forgejo-backup.sh

- Output: `/backup/forgejo/forgejo-dump-YYYYMMDD-HHMMSS.zip`
- Includes: Git data, issues, wikis, configuration
- Retention: 30 days automatic cleanup
- Execution: Daily via `forgejo-backup.timer` (systemd)
- Validation: Archive integrity verification

**Filesystem Backup:**

./backup/scripts/backup-filesystem.sh

- Target: `/mnt/data/srv` service configurations
- Method: Incremental backups with rsync
- Output: `/backup/filesystem/YYYYMMDD/`
- Retention: 30 days automatic cleanup

### Recovery Procedures

**PostgreSQL Restore:**

./recovery/scripts/restore-postgres.sh /backup/postgresql/pg_dumpall-20251130-060000.sql.gz

**What this does:**
1. Stops dependent services (Vaultwarden)
2. Drops existing database
3. Restores from compressed dump
4. Validates restored data integrity
5. Restarts services
6. Confirms service health

**Estimated execution time:** 8-12 minutes  
**Validated RTO:** <15 minutes including validation

**Forgejo Restore:**

./recovery/scripts/restore-forgejo.sh /backup/forgejo/forgejo-dump-20251129-060000.zip

**What this does:**
1. Stops Forgejo service
2. Backs up current data directory
3. Extracts dump to target location
4. Fixes ownership (git:git) and permissions
5. Starts Forgejo service
6. Validates via web UI health check

**Estimated execution time:** 15-25 minutes  
**Validated RTO:** <30 minutes including validation

### Monitoring and Validation

**Backup Health Check:**

./monitoring/backup-health-check.sh

**Checks performed:**
- Backup files exist with correct timestamps
- File sizes within expected ranges (detect corruption)
- Archive integrity (test extraction without full restore)
- Disk space available for next backup cycle
- Last backup completion time (detect missed runs)

**Output:** Logged to `/var/log/backup-health.log`  
**Execution:** Hourly via systemd timer  
**Alerting:** Email on any check failure

## Design Philosophy

### 1. Test Before You Need It

All recovery procedures tested quarterly minimum. Failures documented with root cause analysis. Known issues tracked with workarounds in `recovery/failure-scenarios/common-failures.md`.

**Testing schedule:**
- PostgreSQL restore: Monthly
- Forgejo restore: Quarterly
- Full system recovery: Quarterly
- Failure scenario drills: Bi-annually

### 2. Automate the Critical Path

Daily backups require zero human intervention. Health checks alert on backup failures (email via systemd). Recovery procedures scripted where possible, documented where manual intervention required.

**Automation coverage:**
- Backup execution: 100% automated
- Integrity validation: 100% automated
- Retention cleanup: 100% automated
- Recovery: 80% automated (validation steps manual)

### 3. Document Everything

RTO/RPO objectives defined and measured. Recovery runbooks include decision trees for failure scenarios. Trade-offs documented (backup frequency vs storage cost, automation vs validation rigor).

**Documentation maintained:**
- Step-by-step recovery runbooks
- Common failure patterns with resolutions
- Trade-off decisions with rationale
- Historical test results

## Backup Execution Details

### PostgreSQL Backup Process

#!/bin/bash

Simplified from /usr/local/bin/pg-backup.sh
DATE=$(date +%Y%m%d-%H%M%S)
BACKUP_DIR="/backup/postgresql"
BACKUP_FILE="$BACKUP_DIR/pg_dumpall-$DATE.sql.gz"

Execute cluster-wide backup
sudo -u postgres pg_dumpall | gzip > "$BACKUP_FILE"

Verify archive integrity
gunzip -t "$BACKUP_FILE"

Remove backups older than 30 days
find "$BACKUP_DIR" -name "pg_dumpall-*.sql.gz" -mtime +30 -delete

Log completion
echo "$(date): Backup completed - $BACKUP_FILE" >> /var/log/backup-history.log

**Triggered by:**

[Unit]
Description=PostgreSQL Daily Backup Timer

[Timer]
OnCalendar=daily
OnCalendar=06:00
Persistent=true

[Install]
WantedBy=timers.target

### Forgejo Backup Process

#!/bin/bash

Simplified from /usr/local/bin/forgejo-backup.sh
DATE=$(date +%Y%m%d-%H%M%S)
BACKUP_DIR="/backup/forgejo"
BACKUP_FILE="$BACKUP_DIR/forgejo-dump-$DATE.zip"

Stop Forgejo temporarily (optional, supports online backup)
systemctl stop forgejo
Execute Forgejo dump command
sudo -u git /mnt/data/srv/forgejo/forgejo-bin dump
-c /mnt/data/srv/forgejo/app.ini
-w /tmp
-f "$BACKUP_FILE"

Restart if stopped
systemctl start forgejo
Verify archive integrity
unzip -t "$BACKUP_FILE" > /dev/null

Remove backups older than 30 days
find "$BACKUP_DIR" -name "forgejo-dump-*.zip" -mtime +30 -delete

Log completion
echo "$(date): Backup completed - $BACKUP_FILE" >> /var/log/backup-history.log


## Recovery Runbook Samples

### PostgreSQL Recovery (Manual Steps)

**Scenario:** Database corruption or data loss

**Prerequisites:**
- Backup file: `/backup/postgresql/pg_dumpall-YYYYMMDD-HHMMSS.sql.gz`
- Root or sudo access
- Services dependent on PostgreSQL stopped

**Steps:**

1. **Stop dependent services:**

systemctl stop vaultwarden

2. **Drop existing database (if corrupted):**

sudo -u postgres psql -c "DROP DATABASE vaultwarden;"
sudo -u postgres psql -c "DROP USER vaultwarden;"

3. **Restore from backup:**

gunzip -c /backup/postgresql/pg_dumpall-20251130-060000.sql.gz | sudo -u postgres psql

4. **Validate restored data:**

sudo -u postgres psql -d vaultwarden -c "SELECT COUNT(*) FROM users;"

5. **Restart services:**

systemctl start vaultwarden

6. **Confirm service health:**

curl -I http://localhost:8222
systemctl status vaultwarden


**Estimated time:** 10-15 minutes  
**Validated RTO:** <15 minutes

### Forgejo Recovery (Manual Steps)

**Scenario:** Git repository data loss or corruption

**Prerequisites:**
- Backup file: `/backup/forgejo/forgejo-dump-YYYYMMDD-HHMMSS.zip`
- Forgejo service stopped
- Root or sudo access

**Steps:**

1. **Stop Forgejo service:**

systemctl stop forgejo

2. **Backup current data (safety measure):**

mv /mnt/data/srv/forgejo/data /mnt/data/srv/forgejo/data.old

3. **Extract backup:**

cd /tmp
unzip /backup/forgejo/forgejo-dump-20251129-060000.zip

4. **Restore data directory:**

mv /tmp/data /mnt/data/srv/forgejo/
chown -R git:git /mnt/data/srv/forgejo/data
chmod -R 750 /mnt/data/srv/forgejo/data

5. **Start Forgejo service:**

systemctl start forgejo

6. **Validate via web UI:**

curl -I http://localhost:3000

Manually verify repository access via browser


**Estimated time:** 20-30 minutes  
**Validated RTO:** <30 minutes

## Known Issues and Workarounds

### Issue: Backup Timer Fails Silently

**Symptoms:** Systemd timer shows success but backup file not created

**Root cause:** Insufficient disk space or permission issues

**Workaround:**

Check disk space
df -h /backup

Verify permissions
ls -la /backup/postgresql
ls -la /backup/forgejo

Check systemd logs
journalctl -u pg-backup.service -n 50
journalctl -u forgejo-backup.service -n 50

**Resolution:** Documented in `recovery/failure-scenarios/common-failures.md`

### Issue: PostgreSQL Restore Hangs

**Symptoms:** `psql` restore command appears frozen

**Root cause:** Large database with slow I/O

**Workaround:** Patient monitoring, typically completes in 5-10 minutes for 500MB compressed dump

**Resolution:** Expected behavior, not a failure

## Related Infrastructure

**Production Services:** [fedora-asahi-srv-m1m](https://github.com/ch1ch0-FOSS/fedora-asahi-srv-m1m) - Infrastructure these backups protect

**Automation Deployment:** [ansible-playbooks](https://github.com/ch1ch0-FOSS/ansible-playbooks) - Playbooks deploying backup automation

**Design Rationale:** [infra-case-studies](https://github.com/ch1ch0-FOSS/infra-case-studies) - Case Study #3 explains DR strategy and trade-offs

## Requirements

**Backup Execution:**
- Bash 4.0+
- PostgreSQL client tools (pg_dump, pg_dumpall)
- Forgejo binary with dump command support
- Sufficient disk space (3x largest backup recommended)

**Recovery Execution:**
- Same as backup requirements
- Root or sudo access
- Service management permissions (systemctl)

## Getting Started

**Validate backup configuration:**

Check systemd timers
systemctl list-timers | grep backup

Verify backup directories exist
ls -la /backup/postgresql
ls -la /backup/forgejo

Test backup script manually
sudo /usr/local/bin/pg-backup.sh
sudo /usr/local/bin/forgejo-backup.sh

**Test recovery procedure (safe):**

Dry-run restore (no actual changes)
./recovery/scripts/restore-postgres.sh --dry-run /backup/postgresql/latest.sql.gz

Full recovery test (requires downtime)
./recovery/scripts/restore-postgres.sh /backup/postgresql/latest.sql.gz

**Monitor backup health:**

View recent backup history
tail -f /var/log/backup-history.log

Run health check manually
./monitoring/backup-health-check.sh


## License

MIT

---

