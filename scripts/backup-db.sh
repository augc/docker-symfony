#!/bin/bash
# scripts/backup-db.sh

BACKUP_DIR="/var/backups/db"
DB_HOST="localhost"
DB_PORT="5432"
DB_NAME="augc_web_db"
DB_USER="augc_web_user"
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="$BACKUP_DIR/backup_${DB_NAME}_${DATE}.sql.gz"
RETENTION_DAYS=7

mkdir -p "$BACKUP_DIR"

echo "🗄️ Iniciando backup: $BACKUP_FILE"

# Extraer contraseña del .env.local
DB_PASS=$(grep DATABASE_URL ~/docker/web.augc.org/files/web.augc.org/.env.local | sed 's|.*://[^:]*:||' | cut -d@ -f1)

# Ejecutar backup
PGPASSWORD="$DB_PASS" pg_dump -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" "$DB_NAME" | gzip > "$BACKUP_FILE"

if [ $? -eq 0 ]; then
    echo "✅ Backup completado: $BACKUP_FILE ($(du -h $BACKUP_FILE | cut -f1))"
else
    echo "❌ Error en el backup"
    rm -f "$BACKUP_FILE"
    exit 1
fi

# Eliminar backups más antiguos de $RETENTION_DAYS días
find "$BACKUP_DIR" -name "*.sql.gz" -mtime +$RETENTION_DAYS -delete
echo "🧹 Backups antiguos eliminados (retención: $RETENTION_DAYS días)"
