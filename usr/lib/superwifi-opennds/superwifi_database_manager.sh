#!/bin/sh
# superwifi_manager.sh
# Main manager script. Source init_db.sh to get init_db() and DB_PATH


# Adjust the path below to where you placed init_db.sh
DATABASE_SCRIPT_DIR="/overlay/superwifi"
. "$DATABASE_SCRIPT_DIR/superwifi_database_init.sh" || { echo "Failed to source init_db.sh"; exit 1; }

# Now init_db(), sql_escape(), and DB_PATH are available

# ----------------------
# Get all vouchers
# ----------------------
get_all_vouchers() {
  init_db
  
  local response=$(sqlite3 "$DB_PATH" "SELECT * FROM vouchers_full_details")
  echo "$response"
}

# ----------------------
# Get voucher for authintication
# ----------------------
get_voucher_auth() {
  init_db
  local token_raw="$1"
  
  local token=$(sql_escape "$token_raw")
  local response=$(sqlite3 "$DB_PATH" "SELECT * FROM vouchers_auth_details WHERE token = '$token';")
  echo "$response"
}

# ----------------------
# Get the last voucher used by a mac (most recent last_punched)
# ----------------------
get_last_voucher_by_usermac() {
  init_db
  local mac_raw="$1"
  local mac=$(sql_escape "$mac_raw")
  sqlite3 "$DB_PATH" "
    SELECT * FROM vouchers
    WHERE user_mac = '$mac'
    ORDER BY last_punched DESC
    LIMIT 1;
  "
}

# ----------------------
# Update first punch (token first use) and set mac, timestamps
# - first_punched set only if not set before (i.e. first use)
# - last_punched always updated
# ----------------------
update_voucher_punch() {
  init_db
  local token_raw="$1"
  local mac_raw="$2"
  
  local token=$(sql_escape "$token_raw")
  local mac=$(sql_escape "$mac_raw")

  # If first_punched is 0, set to ts; always update last_punched and user_mac
  sqlite3 "$DB_PATH" <<EOF
UPDATE vouchers
SET 
  user_mac =  CASE WHEN user_mac = '0' THEN '$mac' ELSE user_mac END,
  first_punched = CASE WHEN first_punched = 0 THEN strftime('%s','now') ELSE first_punched END,
  last_punched = strftime('%s','now')

WHERE token = '$token';
EOF
}

# ----------------------
# Update accumulators: accepts upload_raw and download_raw (both integers)
# Behavior:
# - usage = upload_raw + download_raw
# - If usage > accum_usage_season then add (usage - accum_usage_season) to accum_usage_total
# - Set accum_usage_season = usage
# - usage should be integer (bytes or chosen unit)
# ----------------------
update_accumulated_usage_by_mac() {
  init_db
  local user_mac="$1"
  local season_upload_raw="${2:-0}"
  local season_download_raw="${3:-0}"
  local token=$(sql_escape "$token_raw")

  # sanitize numeric inputs (basic)
  season_upload_raw=${season_upload_raw##+}
  season_download_raw=${season_download_raw##+}
  season_upload_raw=${season_upload_raw:-0}
  season_download_raw=${season_download_raw:-0}

  # compute combined usage (shell arithmetic)
  season_usage=$(( season_upload_raw + season_download_raw ))

  sqlite3 "$DB_PATH" <<EOF
UPDATE vouchers
SET
  accum_usage_total = accum_usage_total +
    CASE
      WHEN $season_usage > accum_usage_season THEN ($season_usage - accum_usage_season)
      ELSE 0
    END,
  accum_usage_season = $season_usage
WHERE id = (
  SELECT id FROM vouchers
  WHERE user_mac = '$user_mac'
  ORDER BY last_punch DESC
  LIMIT 1
);
EOF
}

# ----------------------
# Log an auth attempt
# - result: integer code (0 success, 1 not exist, 2 voucher expire, 3 quota expire, 4 time expire)
# - ip optional
# This function will NOT create customers. If customer exists, customer_id is used; otherwise NULL.
# If result == 0 and customer exists, update last_seen and increment total_sessions.
# ----------------------
# TODO:
log_auth_attempt() {
  init_db
  local token_raw="$1"
  local mac_raw="$2"
  local result_code_raw="$3"  # integer result code as defined above
  local ip_raw="$4"

  local token=$(sql_escape "$token_raw")
  local mac=$(sql_escape "$mac_raw")
  local ip=$(sql_escape "$ip_raw")
  local result_code=${result_code_raw:-1}

  # find customer_id if exists (do NOT create)
  local cust_id
  cust_id=$(sqlite3 "$DB_PATH" "SELECT id FROM customers WHERE mac_address = '$mac' LIMIT 1;")

  # prepare customer placeholder
  if [ -z "$cust_id" ]; then
    cust_sql="NULL"
  else
    cust_sql="$cust_id"
  fi

  # insert auth_log row (attempt_time uses default datetime('now'))
  sqlite3 "$DB_PATH" "INSERT INTO auth_log (customer_id, token, user_mac, ip_address, result) VALUES ($cust_sql, '$token', '$mac', '$ip', $result_code);"

  # if success (0) and customer exists -> update last_seen and increment total_sessions
  if [ "$result_code" -eq 0 ] && [ -n "$cust_id" ]; then
    ts_iso=$(date '+%Y-%m-%d %H:%M:%S')
    sqlite3 "$DB_PATH" "UPDATE customers SET last_seen = '$ts_iso', total_sessions = total_sessions + 1 WHERE id = $cust_id;"
    # also update voucher timestamps (first/last)
    update_first_punch "$token" "$mac"
  fi
}


# ----------------------
# Usage examples (uncomment to run)
# ----------------------
# init_db
# get_all_vouchers
# check_quota_and_time "SAMPLE-TOKEN-001"
# update_first_punch "SAMPLE-TOKEN-001" "AA:BB:CC:DD:EE:FF"
# update_accum "SAMPLE-TOKEN-001" 1024 2048    # upload=1024, download=2048
# log_auth_attempt "SAMPLE-TOKEN-001" "AA:BB:CC:DD:EE:FF" 0 "192.168.1.10"
# get_last_voucher_for_mac "AA:BB:CC:DD:EE:FF"
