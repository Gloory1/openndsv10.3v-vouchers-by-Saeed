#!/bin/sh

DB_PATH="/overlay/superwifi-opennds/superwifi_database.db"

init_db() {
  if [ ! -f "$DB_PATH" ]; then
    exit 1
  fi
}

add_voucher() {
  init_db
  local token="$1"
  local mac="$2"
  local rate_down="$3"
  local rate_up="$4"
  local quota_down="$5"
  local quota_up="$6"
  local time_limit="$7"
  local accum_down="$8"
  local first_punched="$9"
  local last_punched="${10}"

  sqlite3 "$DB_PATH" <<EOF
INSERT OR REPLACE INTO vouchers VALUES (
  '$token', '$mac', $rate_down, $rate_up, $quota_down, $quota_up,
  $time_limit, $accum_down, $first_punched, $last_punched
);
EOF
}

delete_voucher() {
  init_db
  local token="$1"
  sqlite3 "$DB_PATH" "DELETE FROM vouchers WHERE token = '$token';"
}

get_voucher() {
  init_db
  local token="$1"
  local response=$(sqlite3 "$DB_PATH" "SELECT * FROM vouchers WHERE token = '$token';")
  echo "$response"
}

get_all_vouchers() {
  init_db
  local response=$(sqlite3 "$DB_PATH" "SELECT * FROM vouchers;")
  echo "$response"
}

update_first_punch() {
  init_db
  local token="$1"
  local mac="$2"
  local timestamp=$(date +%s)
  sqlite3 "$DB_PATH" "UPDATE vouchers SET mac = '$mac', first_punched = $timestamp WHERE token = '$token';"
}

update_last_punch() {
  init_db
  local token="$1"
  local timestamp=$(date +%s)
  sqlite3 "$DB_PATH" "UPDATE vouchers SET last_punched = $timestamp WHERE token = '$token';"
}

get_last_voucher_for_mac() {
  init_db
  local mac="$1"
  sqlite3 "$DB_PATH" "
    SELECT * FROM vouchers 
    WHERE mac = '$mac' 
    ORDER BY last_punched DESC 
    LIMIT 1;
  "
}

update_accum_by_token() {
  init_db
  local token="$1"
  local added_value="$2"
  sqlite3 "$DB_PATH" "UPDATE vouchers SET accum_down = accum_down + $added_value WHERE token = '$token';"
}

update_accum_by_mac() {
  init_db
  local mac="$1"
  local added_value="$2"
  local token=$(sqlite3 "$DB_PATH" "
    SELECT token FROM vouchers 
    WHERE mac = '$mac' 
    ORDER BY last_punched DESC 
    LIMIT 1;
  ")

  if [ -z "$token" ]; then
    return
  fi
  sqlite3 "$DB_PATH" "UPDATE vouchers SET accum_down = accum_down + $added_value WHERE token = '$token';"
}
