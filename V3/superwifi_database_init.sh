 #!/bin/sh
# init_db.sh
# Database initialization with strict naming conventions (_kb, _min, _sec)

DB_PATH="/overlay/superwifi/superwifi_database_v2.db"

init_db() {
  sqlite3 "$DB_PATH" <<EOF

-- ============================================
-- 1) vouchers_info Table
-- ============================================
CREATE TABLE IF NOT EXISTS vouchers_info (
    -- 1. Identity
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    token TEXT NOT NULL UNIQUE,
    user_mac TEXT DEFAULT '0',
    package_id INTEGER DEFAULT 0,

    -- 2. Limits & Constraints
    membership INTEGER DEFAULT 0,
    rate_up_kb INTEGER DEFAULT 0,
    rate_down_kb INTEGER DEFAULT 0,
    data_limit_kb INTEGER DEFAULT 0,   -- Total Quota in KB
    time_limit_min INTEGER DEFAULT 0,  -- Total Time in Minutes

    -- 3. Live Usage Stats
    cumulative_usage_total_kb INTEGER DEFAULT 0, -- (تم التعديل) Total consumed in KB
    cumulative_usage_season_kb INTEGER DEFAULT 0, -- (تم التعديل بالمرة للتوحيد) Session usage
    first_punched_sec INTEGER DEFAULT 0,
    last_punched_sec INTEGER DEFAULT 0,
    expiration_status INTEGER DEFAULT 0,

    -- 4. Financials & Audit
    price_sell_cent INTEGER DEFAULT 0,
    price_cost_cent INTEGER DEFAULT 0,
    created_at INTEGER DEFAULT (strftime('%s', 'now')),
    description TEXT DEFAULT ''
);

CREATE INDEX IF NOT EXISTS idx_vouchers_token ON vouchers_info(token);
CREATE INDEX IF NOT EXISTS idx_vouchers_mac ON vouchers_info(user_mac);

-- ============================================
-- 2) vouchers_auth_details VIEW
-- ============================================
DROP VIEW IF EXISTS vouchers_auth_details;
CREATE VIEW vouchers_auth_details AS
SELECT
    token,
    user_mac,
    expiration_status,
    rate_down_kb,
    rate_up_kb,

    -----------------------------------------------------------------
    -- 1. حساب الوقت المتبقي (Time Remaining)
    CASE
      WHEN time_limit_min = 0 THEN 0
      WHEN COALESCE(first_punched_sec,0) = 0 THEN time_limit_min
      WHEN (strftime('%s','now') - COALESCE(first_punched_sec,0)) > (time_limit_min * 60) THEN -1
      ELSE CAST(((time_limit_min * 60) - (strftime('%s','now') - COALESCE(first_punched_sec,0))) / 60 AS INTEGER)
    END AS voucher_time_remaining_min,

    -- 2. حساب البيانات المتبقية (Data Remaining)
    -- المعادلة: (الحد الأقصى KB - المستخدم KB)
    CASE
      WHEN data_limit_kb = 0 THEN 0
      WHEN (data_limit_kb - COALESCE(cumulative_usage_total_kb,0)) <= 0 THEN -1
      ELSE (data_limit_kb - COALESCE(cumulative_usage_total_kb,0))
    END AS voucher_quota_remaining_kb,

    -----------------------------------------------------------------
    -- 3. رسالة العرض (HTML Display Message)
    (
      -- جزء الوقت
      CASE
        WHEN time_limit_min = 0 THEN '<br>الوقت المتبقي: غير محدود'
        WHEN COALESCE(first_punched_sec,0) = 0 THEN '<br>الوقت المتبقي: ' || CAST(time_limit_min AS TEXT) || ' دقيقة'
        WHEN ((time_limit_min * 60) - (strftime('%s','now') - COALESCE(first_punched_sec,0))) <= 0 THEN '<br>الوقت المتبقي: انتهى الوقت'
        ELSE
          CASE
            WHEN ((time_limit_min * 60) - (strftime('%s','now') - COALESCE(first_punched_sec,0))) < 60
              THEN '<br>الوقت المتبقي: أقل من دقيقة'
            WHEN ((time_limit_min * 60) - (strftime('%s','now') - COALESCE(first_punched_sec,0))) >= 3600
              THEN
                '<br>الوقت المتبقي: '
                || CAST(CAST(((time_limit_min * 60) - (strftime('%s','now') - COALESCE(first_punched_sec,0))) / 3600 AS INTEGER) AS TEXT)
                || ' ساعة و '
                || CAST(CAST((((time_limit_min * 60) - (strftime('%s','now') - COALESCE(first_punched_sec,0))) % 3600) / 60 AS INTEGER) AS TEXT)
                || ' دقيقة'
            ELSE
                '<br>الوقت المتبقي: '
                || CAST(CAST(((time_limit_min * 60) - (strftime('%s','now') - COALESCE(first_punched_sec,0))) / 60 AS INTEGER) AS TEXT)
                || ' دقيقة'
          END
      END
    )
    ||
    (
      -- جزء الداتا
      CASE
        WHEN data_limit_kb = 0 THEN '<br>البيانات المتبقية: غير محدود'
        WHEN (data_limit_kb - COALESCE(cumulative_usage_total_kb,0)) <= 0 THEN '<br>البيانات المتبقية: انتهى الرصيد'
        ELSE
          CASE
            -- أكبر من 1024 ميجا (يعني 1 جيجا) -> نعرض بالجيجا
            WHEN ((data_limit_kb - COALESCE(cumulative_usage_total_kb,0)) / 1024.0) >= 1024.0
              THEN
                '<br>البيانات المتبقية: '
                || CAST(((data_limit_kb - COALESCE(cumulative_usage_total_kb,0)) / 1024 / 1024) AS INTEGER)
                || ' جيجابايت'
            -- أقل من 1 جيجا -> نعرض بالميجا
            ELSE
                '<br>البيانات المتبقية: '
                || CAST(CAST(((data_limit_kb - COALESCE(cumulative_usage_total_kb,0)) / 1024.0) AS INTEGER) AS TEXT)
                || ' ميجابايت'
          END
      END
    ) AS remaining_message_html

FROM vouchers_info;
EOF
}

# If this file is executed directly, call init_db()
if [ "$(basename "$0")" = "$(basename "$0")" ]; then
# This file was run: initialize DB
init_db
fi
