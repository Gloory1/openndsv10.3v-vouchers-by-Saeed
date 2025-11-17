#!/bin/sh
DB_PATH="/overlay/superwifi/superwifi_database_v2.db"
sql_escape() {
printf "%s" "$1" | sed "s/'/''/g"
}
# ----------------------
# Get all vouchers
# ----------------------
get_auth_voucher() {
  local token_raw="$1"
  local token=$(sql_escape "$token_raw")
  sqlite3 "$DB_PATH" "SELECT * FROM vouchers_auth_details WHERE token = '$token' LIMIT 1;"
}
get_all_vouchers() {
  sqlite3 "$DB_PATH" "SELECT * FROM vouchers_info;"
}
# ----------------------
# Update first punch (token first use) and set mac, timestamps
# - first_punched set only if not set before (i.e. first use)
# - last_punched always updated
# ----------------------
# ................. ..................... ......................... first_punched / last_punched / user_mac
update_punch() {
  local token_raw="$1"
  local mac_raw="${2:-}"
  local token=$(sql_escape "$token_raw")
  local mac=$(sql_escape "$mac_raw")
  sqlite3 "$DB_PATH" <<EOF
UPDATE vouchers_info
SET
  user_mac = CASE WHEN user_mac = '0' THEN '$mac' ELSE user_mac END,
  first_punched = CASE WHEN first_punched = 0 THEN strftime('%s','now') ELSE first_punched END,
  last_punched = strftime('%s','now')
WHERE token = '$token';
EOF
}
# ----------------------
# Update accumulators: accepts upload_raw and download_raw (both integers)
# Behavior:
# - usage = upload_raw + download_raw
# - If usage > cumulative_usage_season then add (usage - cumulative_usage_season) to cumulative_usage_total
# - Set cumulative_usage_season = usage
# - usage should be integer (bytes or chosen unit)
# ----------------------
update_accumulated_usage_by_mac() {
  local user_mac="$1"
  local season_upload_raw="${2:-0}"
  local season_download_raw="${3:-0}"
  local season_usage_kb=$(( season_upload_raw + season_download_raw ))
  local token=$(sqlite3 "$DB_PATH" "SELECT token FROM vouchers_info WHERE user_mac = '$user_mac' ORDER BY last_punched DESC LIMIT 1;")
  [ -z "$token" ] && return 0
  local quota_finished=$(
    sqlite3 "$DB_PATH" <<EOF
UPDATE vouchers_info
SET
  cumulative_usage_total = cumulative_usage_total +
    CASE
      WHEN $season_usage_kb > cumulative_usage_season THEN $season_usage_kb - cumulative_usage_season
      ELSE 0
    END,
  cumulative_usage_season = $season_usage_kb
WHERE token = '$token';
SELECT
  CASE
    WHEN quota_down = 0 THEN 0
    WHEN cumulative_usage_total >= quota_down THEN 1
    ELSE 0
  END
FROM vouchers_info
WHERE token = '$token'
LIMIT 1;
EOF
  )
  echo "$quota_finished"
}
# ----------------------
# Log an auth attempt
# - result: integer code (0 success, 1 not exist, 2 voucher expire, 3 quota expire, 4 time expire)
# - ip optional
# This function will NOT create customers. If customer exists, customer_id is used; otherwise NULL.
# If result == 0 and customer exists, update last_seen and increment total_sessions.
# ----------------------
log_auth_attempt() {
  local token_raw="$1"
  local mac_raw="${2:-}"
  local ip_raw="${3:-}"
  local result_raw="${4:-}"
  local token=$(sql_escape "$token_raw")
  local mac=$(sql_escape "$mac_raw")
  local ip=$(sql_escape "$ip_raw")
  local result=$(sql_escape "$result_raw")
  sqlite3 "$DB_PATH" <<EOF
INSERT INTO auth_log (token, user_mac, user_ip, result)
VALUES ('$token', '$mac', '$ip', '$result');
EOF
}
# ----------------------
# Get LAST voucher ONLY if membership = 1 (VIP Auto-Login)
# ----------------------
get_last_vip_voucher_for_mac() {
  local mac_raw="$1"
  local mac=$(sql_escape "$mac_raw")
  # ............ .......... ........ .......... .......... + .............. = 1
  sqlite3 "$DB_PATH" "
    SELECT token FROM vouchers_info
    WHERE user_mac = '$mac' AND membership = '1'
    ORDER BY last_punched DESC
    LIMIT 1;
  "
}
# ----------------------
# Get the last voucher used by a mac (most recent last_punched)
# ----------------------
get_last_voucher_for_mac() {
  local mac_raw="$1"
  local mac=$(sql_escape "$mac_raw")
  sqlite3 "$DB_PATH" "
    SELECT token FROM vouchers_info
    WHERE user_mac = '$mac'
    ORDER BY last_punched DESC
    LIMIT 1;
  "
}

