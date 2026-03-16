#!/bin/bash
# CloudPanel WordPress full backup
# Backs up all site files + specified databases
# Everything preserved at root of archive

# Usage:
# wpbackup <domain> "<db1 db2 ...>" [backup_name]

DOMAIN=$1
DB_NAMES=$2         # Space-separated DBs in quotes
CUSTOM_NAME=$3

BASE_BACKUP="/home/wpbackup"

# --- Help option ---
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
cat << EOF
CloudPanel WordPress Backup Script (Full site + databases)

Usage:
  wpbackup <domain> "<db1 db2 ...>" [backup_name]

Arguments:
  domain       Domain name of the site
  "<db1 db2>"  Space-separated list of databases in quotes
  backup_name  Optional custom backup file name

Behavior:
  - Backs up all files in the site folder (WordPress + any custom files/folders)
  - Exports the specified databases as .sql.gz
  - All files and databases are stored at the root of the archive

Example:
  wpbackup example.com "db1 db2" fullbackup

Backups stored in:
  /home/wpbackup/<domain>/
EOF
    exit 0
fi

# --- Validate input ---
if [ -z "$DOMAIN" ] || [ -z "$DB_NAMES" ]; then
    echo "Error: domain and database(s) required"
    echo "Run 'wpbackup -h' for usage"
    exit 1
fi

# --- Detect site folder ---
SITE_PATH=$(find /home -type d -name "$DOMAIN" | head -n1)
if [ -z "$SITE_PATH" ]; then
    echo "Site folder not found for domain: $DOMAIN"
    exit 1
fi

DATE=$(date +%Y%m%d-%H%M)
TMP_BACKUP="/tmp/.wp-backup-$DATE"
mkdir -p "$TMP_BACKUP"

# --- Export databases ---
for DB_NAME in $DB_NAMES; do
    echo "Exporting database: $DB_NAME"
    clpctl db:export --databaseName="$DB_NAME" --file="$TMP_BACKUP/$DB_NAME.sql.gz"
done

# --- Copy all site files ---
echo "Copying all site files..."
rsync -a "$SITE_PATH"/ "$TMP_BACKUP"/

# --- Create backup folder ---
mkdir -p "$BASE_BACKUP/$DOMAIN"

# --- Archive name ---
if [ -n "$CUSTOM_NAME" ]; then
    ARCHIVE="$BASE_BACKUP/$DOMAIN/$CUSTOM_NAME.tar.gz"
else
    ARCHIVE="$BASE_BACKUP/$DOMAIN/${DOMAIN}_backup_$DATE.tar.gz"
fi

# --- Create final archive ---
tar -czf "$ARCHIVE" -C "$TMP_BACKUP" .

# --- Cleanup ---
rm -rf "$TMP_BACKUP"

echo "Backup completed: $ARCHIVE"
