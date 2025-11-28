#!/bin/sh
DB_PATH="/overlay/superwifi/superwifi_database.db"

sql_escape() {
  printf "%s" "$1" | sed "s/'/''/g"
}

# ----------------------
# Get all vouchers
# ----------------------
get_auth_voucher() {
  local token_raw="$1"
  local token=$(sql_escape "$token_raw")
  # الفيو (View) تم تحديثه مسبقاً ليعيد الأسماء الجديدة، فلا توجد مشكلة هنا
  sqlite3 "$DB_PATH" "SELECT * FROM vouchers_auth_details WHERE token = '$token' LIMIT 1;"
}

get_all_vouchers() {
  sqlite3 "$DB_PATH" "SELECT * FROM vouchers_info;"
}

# ----------------------
# Update first punch (token first use) and set mac, timestamps
# - first_punched_sec set only if not set before (i.e. first use)
# - last_punched_sec always updated
# ----------------------
update_punch() {
  local token_raw="$1"
  local mac_raw="${2:-}"
  local token=$(sql_escape "$token_raw")
  local mac=$(sql_escape "$mac_raw")

  # تم تعديل أسماء الأعمدة لتنتهي بـ _sec
  sqlite3 "$DB_PATH" <<EOF
UPDATE vouchers_info
SET
  user_mac = CASE WHEN user_mac = '0' THEN '$mac' ELSE user_mac END,
  first_punched_sec = CASE WHEN first_punched_sec = 0 THEN strftime('%s','now') ELSE first_punched_sec END,
  last_punched_sec = strftime('%s','now')
WHERE token = '$token';
EOF
}

# ----------------------
# Update accumulators
# Inputs: season_upload_kb, season_download_kb (Both are KB as requested)
# Behavior:
# - usage = upload + download
# - If usage > cumulative_usage_season_kb then add difference to total
# - Set cumulative_usage_season_kb = usage
# ----------------------
update_accumulated_usage_by_mac() {
  local user_mac="$1"
  local season_upload_kb="${2:-0}"
  local season_download_kb="${3:-0}"
  
  # جمع الاستهلاك (رفع + تحميل) بالكيلوبايت
  local season_usage_kb=$(( season_upload_kb + season_download_kb ))

  # البحث عن الكارت باستخدام الاسم الجديد للعمود (last_punched_sec)
  local token=$(sqlite3 "$DB_PATH" "SELECT token FROM vouchers_info WHERE user_mac = '$user_mac' ORDER BY last_punched_sec DESC LIMIT 1;")

  [ -z "$token" ] && return 0

  local quota_finished=$(
    sqlite3 "$DB_PATH" <<EOF
-- 1. تحديث العدادات (KB)
UPDATE vouchers_info
SET
  cumulative_usage_total_kb = cumulative_usage_total_kb +
    CASE
      WHEN $season_usage_kb > cumulative_usage_season_kb THEN ($season_usage_kb - cumulative_usage_season_kb)
      ELSE 0
    END,
  cumulative_usage_season_kb = $season_usage_kb,
  last_punched_sec = strftime('%s','now')
WHERE token = '$token';

-- 2. التحقق هل انتهت الباقة؟ (مقارنة data_limit_kb مع cumulative_usage_total_kb)
SELECT
  CASE
    WHEN data_limit_kb = 0 THEN 0  -- 0 يعني غير محدود
    WHEN cumulative_usage_total_kb >= data_limit_kb THEN 1
    ELSE 0
  END
FROM vouchers_info
WHERE token = '$token'
LIMIT 1;
EOF
  )
  
  # إرجاع 1 لو خلصت، 0 لو لسه
  echo "$quota_finished"
}
 
# ----------------------
# Get LAST voucher auth method by mac
# ----------------------
get_voucher_auth_method() {
    local mac_raw="$1"
    local mac=$(sql_escape "$mac_raw")
    
    sqlite3 "$DB_PATH" "
      SELECT voucher_code, auth_method 
      FROM vouchers_auth_method 
      WHERE mac_address='$mac' LIMIT 1;
    "
}

# ----------------------
# Get the last voucher used by a mac
# ----------------------
get_last_voucher_for_mac() {
  local mac_raw="$1"
  local mac=$(sql_escape "$mac_raw")
  
  sqlite3 "$DB_PATH" "
    SELECT token FROM vouchers_info
    WHERE user_mac = '$mac'
    ORDER BY last_punched_sec DESC
    LIMIT 1;
  "
}
