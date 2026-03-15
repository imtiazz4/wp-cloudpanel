#!/bin/bash

DOMAIN=$1
BACKUP_FILE=$2
BASE_BACKUP="/root/wp-backups"

if [ ! -f "$BASE_BACKUP/$BACKUP_FILE" ]; then
  echo "Backup file not found: $BASE_BACKUP/$BACKUP_FILE"
  exit
fi

# Create temporary folder to extract
TMP_DIR=$(mktemp -d)
tar -xzf "$BASE_BACKUP/$BACKUP_FILE" -C "$TMP_DIR"

# Paths inside backup
DB_SQL="$TMP_DIR/database.sql"
FILES_DIR="$TMP_DIR/files"

# Detect site path in /home based on domain
SITE_PATH=$(find /home -type d -name "$DOMAIN" | head -n1)
if [ -z "$SITE_PATH" ]; then
  # If missing, create under first CloudPanel user folder
  USER_DIR=$(find /home -maxdepth 1 -type d | head -n1)
  SITE_PATH="$USER_DIR/htdocs/$DOMAIN"
  mkdir -p "$SITE_PATH"
  echo "Created site folder: $SITE_PATH"
else
  # Remove old files if folder exists
  rm -rf "$SITE_PATH"/*
fi

# Copy files
cp -r "$FILES_DIR/"* "$SITE_PATH"

# Restore database
if command -v wp >/dev/null 2>&1; then
  wp db import "$DB_SQL" --path="$SITE_PATH" --allow-root
else
  # Parse DB credentials from wp-config.php if exists, else ask
  if [ -f "$SITE_PATH/wp-config.php" ]; then
    DB_NAME=$(grep "DB_NAME" $SITE_PATH/wp-config.php | head -1 | awk -F"'" '{print $4}')
    DB_USER=$(grep "DB_USER" $SITE_PATH/wp-config.php | head -1 | awk -F"'" '{print $4}')
    DB_PASS=$(grep "DB_PASSWORD" $SITE_PATH/wp-config.php | head -1 | awk -F"'" '{print $4}')
  else
    read -p "Enter DB name: " DB_NAME
    read -p "Enter DB user: " DB_USER
    read -sp "Enter DB password: " DB_PASS
    echo ""
  fi
  mysql -u"$DB_USER" -p"$DB_PASS" "$DB_NAME" < "$DB_SQL"
fi

# Cleanup
rm -rf "$TMP_DIR"

echo "Restore completed: $DOMAIN"
