#!/bin/sh
set -eu
umask 077

: "${HOTEL_DB_PASSWORD:?HOTEL_DB_PASSWORD não definido}"

# Polaris switches to environment-only configuration if DB_HOSTNAME is set.
unset DB_HOSTNAME

APP_DIR="${APP_DIR:-/app}"
DATA_DIR="${DATA_DIR:-/data}"
CFG="$APP_DIR/config.ini"
cp "$APP_DIR/config.ini.example" "$CFG"
mkdir -p "$DATA_DIR/generated/badgeparts"

set_kv() {
    K="$1" V="$2" awk '
        BEGIN { k = ENVIRON["K"]; v = ENVIRON["V"] }
        { i = index($0, "="); if (i > 0 && substr($0, 1, i - 1) == k) { print k "=" v; found = 1 } else print }
        END { if (!found) print k "=" v }
    ' "$CFG" > "$CFG.tmp" && mv "$CFG.tmp" "$CFG"
}

# Keep the existing secrets file format so volumes from hotel-stack work unchanged.
SECRETS="$DATA_DIR/secrets.env"
if [ ! -s "$SECRETS" ]; then
    temporary_secrets=$(mktemp "$DATA_DIR/secrets.env.XXXXXX")
    trap 'rm -f "$temporary_secrets"' EXIT
    gen() { head -c 32 /dev/urandom | od -An -tx1 | tr -d ' \n'; }
    {
        printf 'MASTER_KEY=%s\n' "$(gen)"
        printf 'JWT_SECRET=%s\n' "$(gen)"
    } > "$temporary_secrets"
    mv "$temporary_secrets" "$SECRETS"
    trap - EXIT
fi
# shellcheck disable=SC1090
. "$SECRETS"

set_kv db.hostname "${HOTEL_DB_HOST:-db}"
set_kv db.port "${HOTEL_DB_PORT:-3306}"
set_kv db.database "${HOTEL_DB_NAME:-habbo}"
set_kv db.username "${HOTEL_DB_USER:-polaris}"
set_kv db.password "$HOTEL_DB_PASSWORD"
set_kv db.params "?characterEncoding=utf8&useSSL=false&serverTimezone=${TZ:-UTC}"

# Take the pre-migration backup in the DB container, which provides mariadb-dump.
set_kv db.migrations.backup.enabled false
set_kv game.host 0.0.0.0
set_kv nitro.secure.master_key "$MASTER_KEY"
set_kv login.remember.jwt.secret "$JWT_SECRET"

case "${HOTEL_PUBLIC_URL:-}" in
    https://*) ;;
    *) set_kv login.remember.cookie.secure false ;;
esac

# shellcheck disable=SC2086 # JAVA_OPTS is a list of flags.
exec java -Dfile.encoding=UTF8 ${JAVA_OPTS:--Xmx2g} -jar "$APP_DIR/polaris.jar" "$@"
