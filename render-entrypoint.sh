#!/bin/sh
set -eu

export PGADMIN_LISTEN_ADDRESS="${PGADMIN_LISTEN_ADDRESS:-0.0.0.0}"
export PGADMIN_LISTEN_PORT="${PGADMIN_LISTEN_PORT:-${PORT:-10000}}"

if [ -f /etc/secrets/servers.json ]; then
  cp /etc/secrets/servers.json /pgadmin4/servers.json
  chmod 644 /pgadmin4/servers.json
  export PGADMIN_SERVER_JSON_FILE=/pgadmin4/servers.json
  export PGADMIN_REPLACE_SERVERS_ON_STARTUP="${PGADMIN_REPLACE_SERVERS_ON_STARTUP:-True}"
fi

exec /entrypoint.sh
