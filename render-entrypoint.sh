#!/bin/sh
set -eu

export PGADMIN_LISTEN_ADDRESS="${PGADMIN_LISTEN_ADDRESS:-0.0.0.0}"
export PGADMIN_LISTEN_PORT="${PGADMIN_LISTEN_PORT:-${PORT:-10000}}"
export PGADMIN_CONFIG_MASTER_PASSWORD_REQUIRED="${PGADMIN_CONFIG_MASTER_PASSWORD_REQUIRED:-False}"

email="${PGADMIN_DEFAULT_EMAIL:-pgadmin@local}"
storage_user=$(printf '%s' "$email" | sed 's/@/_/g')
storage_dir="/var/lib/pgadmin/storage/${storage_user}"
pass_abs="${storage_dir}/.pgpass"

mkdir -p /var/lib/pgadmin "$storage_dir" /tmp/pgpass
if id pgadmin >/dev/null 2>&1; then
  chown -R pgadmin:root /var/lib/pgadmin || true
fi

if [ -f /etc/secrets/servers.json ]; then
  cp /etc/secrets/servers.json /pgadmin4/servers.json
  chmod 644 /pgadmin4/servers.json
  export PGADMIN_SERVER_JSON_FILE=/pgadmin4/servers.json
  export PGADMIN_REPLACE_SERVERS_ON_STARTUP="${PGADMIN_REPLACE_SERVERS_ON_STARTUP:-True}"
fi

src=""
if [ -f /etc/secrets/pgpassfile ]; then
  src=/etc/secrets/pgpassfile
elif [ -n "${FIRMA_PG_PASSWORD:-}" ]; then
  src=/tmp/pgpass-generated
  printf '*:*:*:%s:%s\n' "${FIRMA_PG_USER:-agente}" "$FIRMA_PG_PASSWORD" > "$src"
  chmod 600 "$src"
fi

if [ -n "$src" ]; then
  cp "$src" "$pass_abs"
  cp "$src" /tmp/pgpass/.pgpass
  cp "$src" /var/lib/pgadmin/.pgpass
  chmod 600 "$pass_abs" /tmp/pgpass/.pgpass /var/lib/pgadmin/.pgpass
  if id pgadmin >/dev/null 2>&1; then
    chown pgadmin:root "$pass_abs" /tmp/pgpass/.pgpass /var/lib/pgadmin/.pgpass || true
  fi
  export PGPASSFILE="$pass_abs"
  export PGPASS_FILE=/tmp/pgpass/.pgpass
  echo "pgpass installed for ${storage_user}"
else
  echo "WARNING: no pgpass source found"
fi

exec /entrypoint.sh
