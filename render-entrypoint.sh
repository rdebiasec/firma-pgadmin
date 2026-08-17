#!/bin/sh
set -eu

export PGADMIN_LISTEN_ADDRESS="${PGADMIN_LISTEN_ADDRESS:-0.0.0.0}"
export PGADMIN_LISTEN_PORT="${PGADMIN_LISTEN_PORT:-${PORT:-10000}}"
export PGADMIN_CONFIG_MASTER_PASSWORD_REQUIRED="${PGADMIN_CONFIG_MASTER_PASSWORD_REQUIRED:-False}"

email="${PGADMIN_DEFAULT_EMAIL:-pgadmin@local}"
storage_user=$(printf '%s' "$email" | sed 's/@/_/g')
storage_dir="/var/lib/pgadmin/storage/${storage_user}"

mkdir -p /var/lib/pgadmin "$storage_dir"
if id pgadmin >/dev/null 2>&1; then
  chown -R pgadmin:root /var/lib/pgadmin || true
fi

if [ -f /etc/secrets/servers.json ]; then
  cp /etc/secrets/servers.json /pgadmin4/servers.json
  chmod 644 /pgadmin4/servers.json
  export PGADMIN_SERVER_JSON_FILE=/pgadmin4/servers.json
  export PGADMIN_REPLACE_SERVERS_ON_STARTUP="${PGADMIN_REPLACE_SERVERS_ON_STARTUP:-True}"
fi

if [ -f /etc/secrets/pgpassfile ]; then
  cp /etc/secrets/pgpassfile "${storage_dir}/pgpassfile"
  chmod 600 "${storage_dir}/pgpassfile"
  if id pgadmin >/dev/null 2>&1; then
    chown pgadmin:root "${storage_dir}/pgpassfile" || true
  fi
fi

exec /entrypoint.sh
