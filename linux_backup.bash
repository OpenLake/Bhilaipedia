#!/bin/bash
BACKUP_DIR="./backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
DB_CONTAINER="bhilaipedia-database-1"

# Create backup directory
mkdir -p "$BACKUP_DIR"

# 1. Database Backup
docker exec $DB_CONTAINER mysqldump -u root -pbhilaipedia bhilaipedia > "$BACKUP_DIR/db_$TIMESTAMP.sql"

# 2. Files Backup
TEMP_DIR=$(mktemp -d)
trap 'rm -rf "$TEMP_DIR"' EXIT

cp -r mediawiki_data extensions database_backup.sql LocalSettings.php "$TEMP_DIR"

# Create tar.gz with retry
zip_path="$BACKUP_DIR/wiki_files_$TIMESTAMP.tar.gz"
retry_count=3
retry_delay=2

while [ $retry_count -gt 0 ]; do
    if tar -czf "$zip_path" -C "$TEMP_DIR" .; then
        break
    fi
    retry_count=$((retry_count-1))
    if [ $retry_count -eq 0 ]; then
        echo "Failed to create archive after retries"
        exit 1
    fi
    sleep $retry_delay
done

# Cleanup old backups (7 days)
find "$BACKUP_DIR" -name "*.tar.gz" -mtime +7 -delete
find "$BACKUP_DIR" -name "*.sql" -mtime +7 -delete