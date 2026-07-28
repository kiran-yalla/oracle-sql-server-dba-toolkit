# oracle-sql-server-dba-toolkit

SQL scripts and automation for Oracle & SQL Server database administration: performance tuning, index analysis, and backup/recovery.

## What this demonstrates

- 🔍 **Oracle index health** — `oracle/index_health_check.sql` surfaces high clustering-factor, unused, and unusable indexes for performance/index-tuning review.
- 💾 **Oracle backup automation** — `oracle/rman_backup.sh` runs RMAN level-0/level-1 incremental backups plus archivelog cleanup with a 7-day recovery-window retention policy.
- 📊 **SQL Server health queries** — `sqlserver/dba_dash_health_queries.sql` includes top-CPU query analysis, index fragmentation reporting, blocking-session detection, and file space usage — in the style used alongside DBA Dash for proactive monitoring.

## Structure

```
.
├── oracle/
│   ├── index_health_check.sql   # Index clustering factor, unused & unusable index checks
│   └── rman_backup.sh            # RMAN incremental backup automation
└── sqlserver/
    └── dba_dash_health_queries.sql  # CPU, fragmentation, blocking, and space usage queries
```

## Usage

```bash
# Oracle
sqlplus / as sysdba @oracle/index_health_check.sql
./oracle/rman_backup.sh ORCLPRD 1

# SQL Server
sqlcmd -S myserver -i sqlserver/dba_dash_health_queries.sql
```

> This is a portfolio/demonstration repository illustrating common Oracle and SQL Server DBA support patterns. Review and adapt file paths, retention windows, and thresholds to your actual environment before real-world use.

## Author

Kiran Yalla — Senior Platform Engineer with hands-on Oracle 12c and SQL Server DBA experience, including performance tuning, backup/recovery, and proactive monitoring.
