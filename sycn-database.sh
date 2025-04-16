#!/bin/bash
/*
 * This script syncs data from a remote MySQL database to a local MySQL database.
 * It uses mysqldump to export data from the remote database and imports it into the local database.
 * The script only syncs rows that have been updated since the last sync time.
 * It also handles errors and logs the sync time.
 */

TABLES=("users" "orders" "products" "categories")

LAST_SYNC_FILE="/home/tool/last_sync.txt"
LAST_SYNC=$(cat "$LAST_SYNC_FILE")

//local.my.cnf content
# [client]
# user=local_user
# password=local_password
# host=localhost

//remote.my.cnf content
# [client]
# user=remote_user
# password=remote_password
# host=remote_host
# port=3306

LOCAL_INFO="/home/tool/local.my.cnf"
LOCAL_DB="fba_database"

REMOTE_INFO="/home/tool/remote.my.cnf"
REMOTE_DB="fba_data"

NOW=$(date +"%F %T")

ALL_SUCCESS=true

echo "Last sycn: $LAST_SYNC"

# Export and Import
for TABLE in "${TABLES[@]}"; do
  echo "Syncing $TABLE..."

  mysqldump --defaults-extra-file=${REMOTE_INFO} \
    --skip-lock-tables --no-create-info \
    --set-gtid-purged=OFF \
    --insert-ignore \
    --where="updated_at >= '$LAST_SYNC'" \
    ${REMOTE_DB} ${TABLE} > ${TABLE}_dump.sql

  if [[ -s ${TABLE}_dump.sql ]]; then
    echo "Importing new rows for $TABLE..."
    mysql --defaults-file=${LOCAL_INFO} ${LOCAL_DB} < ${TABLE}_dump.sql || ALL_SUCCESS=false
  else
    echo "No new rows in $TABLE"
  fi
done

# Save new sync time if all went well
if [ "$ALL_SUCCESS" = true ]; then
  echo "$NOW" > $LAST_SYCN_FILE
  echo "✅ Sync complete at $NOW"
else
  echo "⚠️ Sync failed. Keeping previous sync time."
fi
