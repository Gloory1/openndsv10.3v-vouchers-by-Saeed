#!/bin/sh
# init_db.sh
# Database initialization helper for superwifi_manager.
# Place this file next to the main script and source it from the manager.


DB_PATH="/overlay/superwifi/superwifi_database_v2.db"


# Simple SQL escaping helper (used by manager; kept here for convenience if needed)
sql_escape() {
printf "%s" "$1" | sed "s/'/''/g"
}


# init_db: create schema, indexes, views (idempotent)
init_db() {
  # Ensure DB exists and create schema, pragmas, indexes, views
  # Called at the start of all operations to be safe (idempotent)
  sqlite3 "$DB_PATH" <<EOF

-- ============================================
-- 1) packages_log  (history / templates of packages)
-- ============================================
CREATE TABLE IF NOT EXISTS packages_log (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    membership INTEGER DEFAULT 0,   -- 0=Voucher, 1=VIP 
    time_limit INTEGER DEFAULT 60,  -- minutes (0 = unlimited)
    rate_down INTEGER DEFAULT 0,    -- KBs (0 = unlimited)
    rate_up INTEGER DEFAULT 0,      -- KBs (0 = unlimited)
    quota_down INTEGER DEFAULT 0,    -- KBs (0 = unlimited)
    quota_up INTEGER DEFAULT 0,     -- KBs (0 = unlimited)
    quantity INTEGER DEFAULT 0,
    digit INTEGER DEFAULT 0,
    price INTEGER DEFAULT 0,
    description TEXT DEFAULT '',
    created_at TEXT DEFAULT (datetime('now'))
);

-- ============================================
-- 2) vouchers_info  (main vouchers)
-- ============================================
CREATE TABLE IF NOT EXISTS vouchers_info (
    token TEXT PRIMARY KEY NOT NULL,
    user_mac TEXT DEFAULT '0',
    package_id INTEGER DEFAULT 0,
    membership INTEGER DEFAULT 0,   -- 0=Voucher, 1=VIP
    time_limit INTEGER DEFAULT 0,
    rate_down INTEGER DEFAULT 0,
    rate_up INTEGER DEFAULT 0,
    quota_down INTEGER DEFAULT 0,
    quota_up INTEGER DEFAULT 0,

    -- voucher usage
    cumulative_usage_total INTEGER DEFAULT 0,
    cumulative_usage_season INTEGER DEFAULT 0,
    first_punched INTEGER DEFAULT 0,  -- epoch seconds (0 = not used yet)
    last_punched INTEGER DEFAULT 0,   -- epoch seconds
    expiration_status INTEGER DEFAULT 0
);

-- ============================================
-- 3) attempts_log  (authentication attempts)
-- ============================================
CREATE TABLE IF NOT EXISTS attempts_log (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    punch_date TEXT DEFAULT (datetime('now')),
    user_mac TEXT NOT NULL,
    user_ip TEXT NOT NULL,
    token TEXT,
    result TEXT
);

-- ============================================
-- 4) vouchers_auth_details VIEW
-- ============================================
CREATE VIEW IF NOT EXISTS vouchers_auth_details AS
SELECT
    token,
    user_mac,
    expiration_status,
    rate_down,
    rate_up,

    -----------------------------------------------------------------
  CASE
    WHEN time_limit = 0 THEN 0
    WHEN COALESCE(first_punched,0) = 0 THEN time_limit
    WHEN (strftime('%s','now') - COALESCE(first_punched,0)) > (time_limit * 60) THEN -1
    ELSE CAST(((time_limit * 60) - (strftime('%s','now') - COALESCE(first_punched,0))) / 60 AS INTEGER)
  END AS voucher_time_remaining_min,

  -- البيانات المتبقية (بالكيلوبايت الرقمية)
  CASE
    WHEN quota_down = 0 THEN 0
    WHEN (quota_down - COALESCE(cumulative_usage_total,0)) <= 0 THEN -1
    ELSE (quota_down - COALESCE(cumulative_usage_total,0))
  END AS voucher_quota_remaining_kb,

    ----------------------------------------------------------------- 
    (
      CASE
        WHEN time_limit = 0 THEN '<br>الوقت المتبقي: غير محدود'
        WHEN COALESCE(first_punched,0) = 0 THEN '<br>الوقت المتبقي: ' || CAST(time_limit AS TEXT) || ' دقيقة'
        WHEN ((time_limit * 60) - (strftime('%s','now') - COALESCE(first_punched,0))) <= 0 THEN '<br>الوقت المتبقي: انتهى الوقت'
        ELSE
          CASE
            WHEN ((time_limit * 60) - (strftime('%s','now') - COALESCE(first_punched,0))) < 60
              THEN '<br>الوقت المتبقي: أقل من دقيقة'
            WHEN ((time_limit * 60) - (strftime('%s','now') - COALESCE(first_punched,0))) >= 3600
              THEN
                '<br>الوقت المتبقي: '
                || CAST(CAST(((time_limit * 60) - (strftime('%s','now') - COALESCE(first_punched,0))) / 3600 AS INTEGER) AS TEXT)
                || ' ساعة و '
                || CAST(CAST((((time_limit * 60) - (strftime('%s','now') - COALESCE(first_punched,0))) % 3600) / 60 AS INTEGER) AS TEXT)
                || ' دقيقة'
            ELSE
                '<br>الوقت المتبقي: '
                || CAST(CAST(((time_limit * 60) - (strftime('%s','now') - COALESCE(first_punched,0))) / 60 AS INTEGER) AS TEXT)
                || ' دقيقة'
          END
      END
    )
    ||
    (
      CASE
        WHEN quota_down = 0 THEN '<br>البيانات المتبقية: غير محدود'
        WHEN (quota_down - COALESCE(cumulative_usage_total,0)) <= 0 THEN '<br>البيانات المتبقية: انتهى الرصيد'
        ELSE
          CASE
            WHEN ((quota_down - COALESCE(cumulative_usage_total,0)) / 1024.0) >= 1024.0
              THEN
                '<br>البيانات المتبقية: '
                || CAST(((quota_down - COALESCE(cumulative_usage_total,0)) / 1024 / 1024) AS INTEGER)
                || ' جيجابايت'
            ELSE
                '<br>البيانات المتبقية: '
                || CAST(CAST(((quota_down - COALESCE(cumulative_usage_total,0)) / 1024.0) AS INTEGER) AS TEXT)
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
