# Infrastructure Automation Overview

## Implemented Automation

### CI/CD: Vercel Auto-Deploy

GitHub Actions workflow automatically deploys `ch1ch0-FOSS.me` portfolio to Vercel on every push to main branch.

- **Workflow**: `.github/workflows/vercel-deploy.yml`
- **Trigger**: Push to main
- **Action**: Install Vercel CLI, pull environment, build, deploy
- **Status**: Active and integrated

### Backup Automation

Daily backups for data persistence and disaster recovery.

#### PostgreSQL Cluster Backup
- **Script**: `/usr/local/bin/pg-backup.sh`
- **Timer**: `pg-backup.timer` (daily)
- **Destination**: `/backup/postgresql/`
- **Retention**: 30 days

#### Forgejo Repository Backup
- **Script**: `/usr/local/bin/forgejo-backup.sh`
- **Timer**: `forgejo-backup.timer` (daily)
- **Destination**: `/backup/forgejo/`
- **Retention**: 30 days

#### System Configuration Backup
- **Script**: `/usr/local/bin/config-backup.sh`
- **Timer**: `config-backup.timer` (daily)
- **Destination**: `/backup/configs/`
- **Retention**: 30 days

### Status Monitoring

Hourly service health checks log operational state.

- **Script**: `/usr/local/bin/service-health-check.sh`
- **Timer**: `service-health.timer` (hourly)
- **Log**: `/var/log/service-health.log`
- **Services Monitored**: PostgreSQL, Forgejo, Vaultwarden, Ollama

## Verification

All timers are active and scheduled. Backups execute daily; health checks run hourly.

systemctl list-timers --all | grep backup
tail -20 /var/log/service-health.log
