#!/bin/bash

set -e

BASE_BACKUP="/home/wpbackup"
TEMP_DIR="/home/wpbackup/temp"

show_help() {
cat <<EOF

wprestore - CloudPanel WordPress restore utility

USAGE
  wprestore <domain> [backup_name] [restore_files yes|no] [home_user]

PARAMETERS
  domain           Domain backup folder inside /home/wpbackup
  backup_name      Backup file name WITHOUT .tar.gz (optional)
  restore_files    yes | no   (default: no)
  home_user        user folder inside /home (required if restore_files=yes)

EXAMPLES

Restore latest database only
  wprestore ont.mavrey.com

Restore specific backup database
  wprestore ont.mavrey.com ont.mavrey.com_backup_20260316-1635

Restore database + files
  wprestore ont.mavrey.com "" yes mavrey-ont

This will:

1. Import all .sql.gz databases
2. Delete everything inside
   /home/mavrey-ont/htdocs/ont.mavrey.com
3. Extract website files from backup (excluding SQL)

EOF
}

if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    show_help
    exit 0
fi

DOMAIN="$1"
BACKUP_NAME="$2"
RESTORE_FILES="${3:-no}"
HOME_USER="$4"

if [ -z "$DOMAIN" ]; then
    show_help
    exit 1
fi

DOMAIN_DIR="$BASE_BACKUP/$DOMAIN"

if [ ! -d "$DOMAIN_DIR" ]; then
    echo "Backup folder not found: $DOMAIN_DIR"
    exit 1
fi

mkdir -p "$TEMP_DIR"

# Determine backup file
if [ -z "$BACKUP_NAME" ]; then
    BACKUP_FILE=$(ls -t "$DOMAIN_DIR"/*.tar.gz 2>/dev/null | head -n1)
else
    BACKUP_FILE="$DOMAIN_DIR/$BACKUP_NAME.tar.gz"
fi

if [ ! -f "$BACKUP_FILE" ]; then
    echo "Backup not found"
    exit 1
fi

echo "Using backup:"
echo "$BACKUP_FILE"

echo
echo "Cleaning temp folder..."
rm -rf "$TEMP_DIR"/*
mkdir -p "$TEMP_DIR"

echo "Extracting backup..."
tar -xzf "$BACKUP_FILE" -C "$TEMP_DIR"

echo
echo "Searching for SQL files..."

SQL_FILES=$(find "$TEMP_DIR" -name "*.sql.gz")

if [ -n "$SQL_FILES" ]; then

for SQL in $SQL_FILES
do

    DB_NAME=$(basename "$SQL" .sql.gz)

    echo
    echo "Importing database: $DB_NAME"

    clpctl db:import \
        --databaseName="$DB_NAME" \
        --file="$SQL"

done

else
    echo "No SQL files found"
fi

# FILE RESTORE
if [ "$RESTORE_FILES" = "yes" ]; then

    if [ -z "$HOME_USER" ]; then
        echo "Error: home_user required when restore_files=yes"
        exit 1
    fi

    SITE_PATH="/home/$HOME_USER/htdocs/$DOMAIN"

    if [ ! -d "$SITE_PATH" ]; then
        echo "Site path not found:"
        echo "$SITE_PATH"
        exit 1
    fi

    echo
    echo "Restoring site files..."

    echo "Deleting existing files in:"
    echo "$SITE_PATH"

    rm -rf "$SITE_PATH"/* "$SITE_PATH"/.[!.]* "$SITE_PATH"/..?* 2>/dev/null || true

    echo "Extracting files..."

    tar \
      --exclude='*.sql.gz' \
      -xzf "$BACKUP_FILE" \
      -C "$SITE_PATH"

    echo "Files restored."
fi

# Cleanup temp directory
echo
echo "Cleaning temporary files..."

rm -rf "$TEMP_DIR"

echo "Temporary files removed."

echo
echo "Restore completed successfully."
