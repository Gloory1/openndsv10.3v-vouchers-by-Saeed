#!/bin/sh
# init_db.sh
# Database initialization with strict naming conventions (_kb, _min, _sec)
# Copyright (C) Saeed & BlueWave Projects 2025

DB_PATH="/overlay/superwifi/superwifi_database_v2.db"

init_db() {
  sqlite3 "$DB_PATH" <<EOF

-- ============================================
-- 1) vouchers_info Table
-- ============================================
CREATE TABLE IF NOT EXISTS vouchers_info (
    -- 1. Identity
    token_id INTEGER PRIMARY KEY AUTOINCREMENT,
    package_id INTEGER DEFAULT 0,
    token TEXT NOT NULL UNIQUE,
    user_mac TEXT DEFAULT '0',
    membership INTEGER DEFAULT 0,
    auth_method INTEGER DEFAULT 0, -- 0=Manual, 1=Click-Restore, 2=Auto-Login

    -- 2. Limits & Constraints
    rate_up_kb INTEGER DEFAULT 0,
    rate_down_kb INTEGER DEFAULT 0,
    data_limit_kb INTEGER DEFAULT 0,   -- Total Quota in KB
    time_limit_min INTEGER DEFAULT 0,  -- Total Time in Minutes

    -- 3. Live Usage Stats
    cumulative_usage_total_kb INTEGER DEFAULT 0, -- Total consumed in KB
    cumulative_usage_season_kb INTEGER DEFAULT 0, -- Session usage
    first_punched_sec INTEGER DEFAULT 0,
    last_punched_sec INTEGER DEFAULT 0,
    expiration_status INTEGER DEFAULT 0, -- 0=Valid, 1=Expired

    -- 4. Financials & Audit
    price_data_cost_cent INTEGER DEFAULT 0,
    price_service_cost_cent INTEGER DEFAULT 0,
    price_sell_cent INTEGER DEFAULT 0,
    created_at INTEGER DEFAULT (strftime('%s', 'now')),
    description TEXT DEFAULT ''
);

-- Create Indexes for performance
CREATE INDEX IF NOT EXISTS idx_vouchers_token ON vouchers_info(token);
CREATE INDEX IF NOT EXISTS idx_vouchers_mac ON vouchers_info(user_mac);


-- ============================================
-- 2) vouchers_auth_details VIEW
-- ============================================
-- This View calculates remaining time/data and generates HTML messages
DROP VIEW IF EXISTS vouchers_auth_details;
CREATE VIEW vouchers_auth_details AS
SELECT
    token,
    user_mac,
    expiration_status,
    rate_down_kb,
    rate_up_kb,

    -----------------------------------------------------------------
    -- 1. Calculate Time Remaining
    CASE
      WHEN time_limit_min = 0 THEN 0
      WHEN COALESCE(first_punched_sec,0) = 0 THEN time_limit_min
      WHEN (strftime('%s','now') - COALESCE(first_punched_sec,0)) > (time_limit_min * 60) THEN -1
      ELSE CAST(((time_limit_min * 60) - (strftime('%s','now') - COALESCE(first_punched_sec,0))) / 60 AS INTEGER)
    END AS voucher_time_remaining_min,

    -- 2. Calculate Data Remaining
    -- Formula: (Max KB - Used KB)
    CASE
      WHEN data_limit_kb = 0 THEN 0
      WHEN (data_limit_kb - COALESCE(cumulative_usage_total_kb,0)) <= 0 THEN -1
      ELSE (data_limit_kb - COALESCE(cumulative_usage_total_kb,0))
    END AS voucher_quota_remaining_kb,

    -----------------------------------------------------------------
    -- 3. Display Message (HTML)
    (
      -- A) Time Part
      CASE
        WHEN time_limit_min = 0 THEN '<br>Time Remaining: Unlimited'
        WHEN COALESCE(first_punched_sec,0) = 0 THEN '<br>Time Remaining: ' || CAST(time_limit_min AS TEXT) || ' Minutes'
        WHEN ((time_limit_min * 60) - (strftime('%s','now') - COALESCE(first_punched_sec,0))) <= 0 THEN '<br>Time Remaining: Expired'
        ELSE
          CASE
            WHEN ((time_limit_min * 60) - (strftime('%s','now') - COALESCE(first_punched_sec,0))) < 60
              THEN '<br>Time Remaining: Less than a minute'
            WHEN ((time_limit_min * 60) - (strftime('%s','now') - COALESCE(first_punched_sec,0))) >= 3600
              THEN
                '<br>Time Remaining: '
                || CAST(CAST(((time_limit_min * 60) - (strftime('%s','now') - COALESCE(first_punched_sec,0))) / 3600 AS INTEGER) AS TEXT)
                || ' Hours and '
                || CAST(CAST((((time_limit_min * 60) - (strftime('%s','now') - COALESCE(first_punched_sec,0))) % 3600) / 60 AS INTEGER) AS TEXT)
                || ' Minutes'
            ELSE
                '<br>Time Remaining: '
                || CAST(CAST(((time_limit_min * 60) - (strftime('%s','now') - COALESCE(first_punched_sec,0))) / 60 AS INTEGER) AS TEXT)
                || ' Minutes'
          END
      END
    )
    ||
    (
      -- B) Data Part
      CASE
        WHEN data_limit_kb = 0 THEN '<br>Data Remaining: Unlimited'
        WHEN (data_limit_kb - COALESCE(cumulative_usage_total_kb,0)) <= 0 THEN '<br>Data Remaining: Depleted'
        ELSE
          CASE
            -- Greater than 1024 MB (i.e., 1 GB) -> Display in GB
            WHEN ((data_limit_kb - COALESCE(cumulative_usage_total_kb,0)) / 1024.0) >= 1024.0
              THEN
                '<br>Data Remaining: '
                || CAST(((data_limit_kb - COALESCE(cumulative_usage_total_kb,0)) / 1024 / 1024) AS INTEGER)
                || ' GB'
            -- Less than 1 GB -> Display in MB
            ELSE
                '<br>Data Remaining: '
                || CAST(CAST(((data_limit_kb - COALESCE(cumulative_usage_total_kb,0)) / 1024.0) AS INTEGER) AS TEXT)
                || ' MB'
          END
      END
    ) AS remaining_message_html

FROM vouchers_info;

-- ============================================
-- 3) view_client_auth_status VIEW (NEW)
-- ============================================
-- This View is used by the Pre-Auth script to determine
-- if a MAC address has a valid voucher and how to handle it.
DROP VIEW IF EXISTS vouchers_auth_method;
CREATE VIEW vouchers_auth_method AS
SELECT 
    user_mac AS mac_address,
    token AS voucher_code,
    auth_method
FROM vouchers_info
WHERE user_mac IS NOT NULL AND user_mac != '0'
ORDER BY last_punched_sec DESC;

EOF
}

# If this file is executed directly, call init_db()
if [ "$(basename "$0")" = "$(basename "$0")" ]; then
    # This file was run directly: initialize DB
    init_db
    echo "Database initialized successfully at $DB_PATH"
fi
