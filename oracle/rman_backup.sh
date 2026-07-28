#!/usr/bin/env bash
# oracle/rman_backup.sh
# Sample RMAN backup automation script demonstrating a typical
# level-0/level-1 incremental backup strategy with archivelog cleanup.

set -euo pipefail

ORACLE_SID="${1:-ORCLPRD}"
BACKUP_LEVEL="${2:-1}"   # 0 = full, 1 = incremental
BACKUP_DIR="/backup/rman/${ORACLE_SID}"
LOG_FILE="${BACKUP_DIR}/rman_backup_$(date +%Y%m%d_%H%M%S).log"

mkdir -p "${BACKUP_DIR}"

echo "Starting RMAN level-${BACKUP_LEVEL} backup for ${ORACLE_SID}..."

rman target / log="${LOG_FILE}" <<EOF
RUN {
  ALLOCATE CHANNEL c1 DEVICE TYPE DISK FORMAT '${BACKUP_DIR}/%U';
  BACKUP INCREMENTAL LEVEL ${BACKUP_LEVEL} DATABASE PLUS ARCHIVELOG
    DELETE INPUT
    TAG 'LEVEL${BACKUP_LEVEL}_BACKUP';
  BACKUP CURRENT CONTROLFILE;
  RELEASE CHANNEL c1;
}

# Retention/cleanup: keep backups needed to satisfy a 7-day recovery window
CONFIGURE RETENTION POLICY TO RECOVERY WINDOW OF 7 DAYS;
DELETE NOPROMPT OBSOLETE;
EOF

echo "RMAN backup complete. Log: ${LOG_FILE}"

