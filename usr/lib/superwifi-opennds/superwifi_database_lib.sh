#!/bin/sh

DB_PATH="/overlay/superwifi/superwifi_database.db"

init_db() {
  if [ ! -f "$DB_PATH" ]; then
    exit 1
  fi
}

#TODO:
add_voucher() {
  init_db
  local token="$1"
  local time_limit="$2"
  local rate_down="$3"
  local rate_up="$4"
  local quota_down="$5"
  local quota_up="$6"

sqlite3 "$DB_PATH" <<EOF
INSERT OR REPLACE INTO vouchers (
  token, time_limit, rate_down, rate_up, quota_down, quota_up
) VALUES (
  '$token', $time_limit, $rate_down, $rate_up, $quota_down, $quota_up
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
  sqlite3 "$DB_PATH" "UPDATE vouchers SET mac = '$mac', first_punched = $timestamp, last_punched = $timestamp WHERE token = '$token';"
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

qouta_expired() {
  init_db
  local token="$1"
  sqlite3 "$DB_PATH" "UPDATE vouchers SET qouta_expired = 1 WHERE token = '$token';"
}


update_accum() {
  init_db
  local token="$1"
  local download="$2"

  sqlite3 "$DB_PATH" <<EOF
UPDATE vouchers 
SET
  accum_down_total = accum_down_total +
    CASE
      WHEN $download > accum_down_season
        THEN $download - accum_down_season
      ELSE
        0
    END,
  accum_down_season = $download
WHERE token = '$token';
EOF
}
