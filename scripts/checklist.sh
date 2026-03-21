#!/bin/bash

PASS=0
FAIL=0

check() {
    local msg=$1
    local cmd=$2
    if eval "$cmd" &>/dev/null; then
        echo "✅ $msg"
        ((PASS++))
    else
        echo "❌ FALLO: $msg"
        ((FAIL++))
    fi
}

COMPOSE_DIR=~/docker/web.augc.org
APP_DIR=/var/www/symfony/web.augc.org
CONTAINER=php3

echo "══════════════════════════════════════════"
echo "   CHECKLIST PRE-PRODUCCIÓN SYMFONY"
echo "══════════════════════════════════════════"

# ── SYMFONY (dentro del contenedor) ───────────────────────────────
exec_app() { docker compose -f $COMPOSE_DIR/docker-compose.yaml exec -T $CONTAINER bash -c "cd $APP_DIR && $1"; }

check "APP_ENV=prod"            "exec_app \"grep -q APP_ENV=prod .env.local\""
check "APP_DEBUG=0"             "exec_app \"grep -q APP_DEBUG=0 .env.local\""
check "Caché limpia y caliente" "exec_app \"test -d var/cache/prod\""
check "Assets compilados"       "exec_app \"test -f public/assets/manifest.json\""
check "No hay .env.local en git" "exec_app \"! git ls-files --error-unmatch .env.local 2>/dev/null\""
check "Migraciones aplicadas"   "exec_app \"php bin/console doctrine:migrations:status | grep -q 'Already at latest version'\""

# ── SERVIDOR (desde el host) ───────────────────────────────────────
check "HTTPS activo"                "curl -sI https://web.augc.org | grep -q '200\|301\|404'"
check "HTTP redirige a HTTPS"       "curl -sI http://web.augc.org | grep -q '301'"
check "Header HSTS presente"        "curl -sI https://web.augc.org | grep -qi 'strict-transport-security'"
check "Header X-Frame-Options"      "curl -sI https://web.augc.org | grep -qi 'x-frame-options'"
check "PHP no expuesto en headers"  "! curl -sI https://web.augc.org | grep -qi 'x-powered-by'"

# ── BACKUP (desde el host) ─────────────────────────────────────────
check "Backup reciente (24h)"       "find /var/backups/db -name '*.sql.gz' -mtime -1 | grep -q ."
check "Cron de backup activo"       "crontab -l | grep -q backup-db.sh"

echo "══════════════════════════════════════════"
echo "RESULTADO: $PASS ✅  |  $FAIL ❌"
if [ $FAIL -gt 0 ]; then
    echo "⛔ NO desplegar hasta resolver todos los fallos"
    exit 1
else
    echo "🚀 LISTO PARA PRODUCCIÓN"
fi
