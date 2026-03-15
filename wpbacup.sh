#!/bin/bash
DOMAIN=$1
BASE_BACKUP="/root/wp-backups"

SITE_PATH=$(find /home -type f -name wp-config.php | grep "$DOMAIN" | head -n1 | sed 's|/wp-config.php||')

if [ -z "$SITE_PATH" ]; then
  echo "WordPress site not found"
  exit
fi

DATE=$(date +%Y%m%d-%H%M)
BACKUP_DIR="$BASE_BACKUP/$DOMAIN/$DATE"
mkdir -p "$BACKUP_DIR"

# Export DB using wp-cli if available
if command -v wp >/dev/null 2>&1; then
  wp db export "$BACKUP_DIR/database.sql" --path="$SITE_PATH" --allow-root
  DB_USER=$(grep DB_USER "$SITE_PATH/wp-config.php" | awk -F"'" '{print $4}')
  DB_PASS=$(grep DB_PASSWORD "$SITE_PATH/wp-config.php" | awk -F"'" '{print $4}')
  DB_NAME=$(grep DB_NAME "$SITE_PATH/wp-config.php" | awk -F"'" '{print $4}')
else
  DB_NAME=$(grep DB_NAME "$SITE_PATH/wp-config.php" | awk -F"'" '{print $4}')
  DB_USER=$(grep DB_USER "$SITE_PATH/wp-config.php" | awk -F"'" '{print $4}')
  DB_PASS=$(grep DB_PASSWORD "$SITE_PATH/wp-config.php" | awk -F"'" '{print $4}')
  mysqldump -u"$DB_USER" -p"$DB_PASS" "$DB_NAME" > "$BACKUP_DIR/database.sql"
fi

# Save DB info in a separate file
echo "DB_NAME=$DB_NAME" > "$BACKUP_DIR/db_info.txt"
echo "DB_USER=$DB_USER" >> "$BACKUP_DIR/db_info.txt"
echo "DB_PASS=$DB_PASS" >> "$BACKUP_DIR/db_info.txt"

# Copy files
cp -r "$SITE_PATH" "$BACKUP_DIR/files"

# Compress backup
tar -czf "$BASE_BACKUP/$DOMAIN-$DATE.tar.gz" -C "$BACKUP_DIR" .

# Cleanup
rm -rf "$BACKUP_DIR"

echo "Backup completed: $BASE_BACKUP/$DOMAIN-$DATE.tar.gz"
