#!/bin/sh
set -e

# Paths - adjust only if your paths differ
OLD_DB="/overlay/superwifi/superwifi_database.db"
NEW_DB="/overlay/superwifi/superwifi_database_v2.db"
TMP_COPY="/tmp/superwifi_db_copy.db"
OLD_TABLE="vouchers"
NEW_TABLE="vouchers_info"

# Backup originals (fast)
cp -v "$OLD_DB" "${OLD_DB}.bak" || true
cp -v "$NEW_DB" "${NEW_DB}.bak" || true

# Optional: stop services that may write to the DB (uncomment if you know the service names)
# echo "Stopping services that may access DB..."
# /etc/init.d/superwifi stop 2>/dev/null || true
# /etc/init.d/opennds stop 2>/dev/null || true

# Copy old DB to /tmp to avoid locking issues
echo "Copying old DB to $TMP_COPY ..."
cp -v "$OLD_DB" "$TMP_COPY" || { echo "ERROR: could not copy $OLD_DB to $TMP_COPY"; exit 1; }

# Quick sanity checks
if [ -z "$(sqlite3 "$TMP_COPY" "SELECT name FROM sqlite_master WHERE type='table' AND name='$OLD_TABLE';")" ]; then
  echo "ERROR: source table '$OLD_TABLE' not found in $TMP_COPY" >&2
  rm -f "$TMP_COPY"
  exit 1
fi
if [ -z "$(sqlite3 "$NEW_DB" "SELECT name FROM sqlite_master WHERE type='table' AND name='$NEW_TABLE';")" ]; then
  echo "ERROR: target table '$NEW_TABLE' not found in $NEW_DB" >&2
  rm -f "$TMP_COPY"
  exit 1
fi

# Perform migration from temp copy into existing new DB table.
# This mapping uses the column names you provided earlier.
# It WILL NOT create or alter schemas; it only inserts matching data.
sqlite3 "$NEW_DB" <<'EOF'
PRAGMA busy_timeout = 10000; -- wait up to 10s if DB is busy
BEGIN;
ATTACH DATABASE '/tmp/superwifi_db_copy.db' AS old;

-- Direct mapped insert. Adjust COALESCE(...) fields if your old DB uses different column names.
INSERT OR REPLACE INTO vouchers_info (
  token, user_mac, package_id, membership, time_limit, rate_down, rate_up,
  quota_down, quota_up, cumulative_usage_total, cumulative_usage_season,
  first_punched, last_punched, expiration_status
)
SELECT
  COALESCE(token,'') AS token,
  COALESCE(mac,'0') AS user_mac,
  0 AS package_id,
  0 AS membership,
  COALESCE(time_limit,0) AS time_limit,
  COALESCE(rate_down,0) AS rate_down,
  COALESCE(rate_up,0) AS rate_up,
  COALESCE(quota_down,0) AS quota_down,
  COALESCE(quota_up,0) AS quota_up,
  COALESCE(accum_down_total,0) AS cumulative_usage_total,
  COALESCE(accum_down_season,0) AS cumulative_usage_season,
  COALESCE(first_punched,0) AS first_punched,
  COALESCE(last_punched,0) AS last_punched,
  COALESCE(qouta_expired,0) AS expiration_status
FROM old.vouchers;

DETACH old;
COMMIT;
EOF

# Optional: restart services you stopped earlier (uncomment if used)
# /etc/init.d/superwifi start 2>/dev/null || true
# /etc/init.d/opennds start 2>/dev/null || true

# Report final counts and cleanup
echo -n "Target ($NEW_TABLE) row count: "
sqlite3 "$NEW_DB" "SELECT COUNT(*) FROM $NEW_TABLE;"
echo -n "Source (copy) ($OLD_TABLE) row count: "
sqlite3 "$TMP_COPY" "SELECT COUNT(*) FROM \"$OLD_TABLE\";"

# remove temporary copy
rm -f "$TMP_COPY" || true
echo "Temporary copy removed. Migration complete."
