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
  sqlite3 "$DB_PATH" <<'SQL'
PRAGMA foreign_keys = ON;

-- customers table
CREATE TABLE IF NOT EXISTS customers (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  mac_address TEXT UNIQUE NOT NULL,
  name TEXT DEFAULT 'Guest',
  created_at TEXT DEFAULT (datetime('now')),
  last_seen TEXT,           -- last time the client was active (ISO timestamp)
  total_sessions INTEGER DEFAULT 0 -- number of successful sessions
);

-- packages table
CREATE TABLE IF NOT EXISTS packages (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  created_at TEXT DEFAULT (datetime('now')),
  description TEXT DEFAULT 'Vouchers package',
  quantity INTEGER DEFAULT 0,
  membership INTEGER DEFAULT 2, -- 0 = Owner, 1 = VIP, 2 = Voucher
  time_limit INTEGER DEFAULT 60,    -- time limit in minutes (0 = unlimited)
  rate_up INTEGER DEFAULT 0,
  rate_down INTEGER DEFAULT 0,
  quota_up INTEGER DEFAULT 0,       -- quota units for upload
  quota_down INTEGER DEFAULT 0      -- quota units for download
);

-- vouchers table
-- NOTE: accum_usage_* columns represent combined upload+download usage
CREATE TABLE IF NOT EXISTS vouchers (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  token TEXT UNIQUE NOT NULL,
  package_id INTEGER DEFAULT 0,
  user_mac TEXT DEFAULT '0',        -- store mac as '0' when unused
  first_punched INTEGER DEFAULT 0,  -- epoch seconds when first used (0 = never)
  last_punched INTEGER DEFAULT 0,   -- epoch seconds of last activity
  accum_usage_season INTEGER DEFAULT 0, -- usage counter for current session/season (bytes or units)
  accum_usage_total INTEGER DEFAULT 0,  -- cumulative usage total (bytes or units)
  quota_expired INTEGER DEFAULT 0,  -- 1 = expired, 0 = active
  FOREIGN KEY(package_id) REFERENCES packages(id)
);

-- auth_log table (ordered as requested)
-- result codes:
-- 0 = success
-- 1 = not exist
-- 2 = voucher expire (manually flagged)
-- 3 = quota expire
-- 4 = time expire
CREATE TABLE IF NOT EXISTS auth_log (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  customer_id INTEGER,
  token TEXT,
  user_mac TEXT NOT NULL,
  ip_address TEXT,
  attempt_time TEXT DEFAULT (datetime('now')),
  result INTEGER NOT NULL DEFAULT 0,
  FOREIGN KEY(customer_id) REFERENCES customers(id)
);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_vouchers_token ON vouchers(token);
CREATE INDEX IF NOT EXISTS idx_vouchers_user_mac ON vouchers(user_mac);
CREATE INDEX IF NOT EXISTS idx_vouchers_first_punched ON vouchers(first_punched);
CREATE INDEX IF NOT EXISTS idx_auth_log_time ON auth_log(attempt_time);

-- View: vouchers_full_details (all details)
CREATE VIEW IF NOT EXISTS vouchers_full_details AS
SELECT 
  v.id AS voucher_id,
  v.token,
  v.package_id,
  v.user_mac,
  c.name AS customer_name,
  p.description AS package_description,
  p.membership,
  p.time_limit,
  p.rate_down,
  p.rate_up,
  p.quota_down,
  p.quota_up,
  v.first_punched,
  v.last_punched,
  v.accum_usage_season,
  v.accum_usage_total,
  v.quota_expired
FROM vouchers v
JOIN packages p ON v.package_id = p.id
LEFT JOIN customers c ON v.user_mac = c.mac_address;

-- View: vouchers_auth_details (used for auth decisions)
-- quota_remaining: 0 = unlimited, -1 = expired, >0 = remaining units
-- time_remaining_seconds: 0 = unlimited, -1 = expired, >0 = seconds remaining
CREATE VIEW IF NOT EXISTS vouchers_auth_details AS
SELECT
  v.token,
  v.user_mac,
  p.membership,
  p.time_limit,
  p.rate_down,
  p.rate_up,
  p.quota_down,
  p.quota_up,
  v.quota_expired,
  -- compute total package quota (up + down). If both zero -> unlimited (0).
  CASE
    WHEN p.quota_up = 0 AND p.quota_down = 0 THEN 0
    WHEN (p.quota_up + p.quota_down) - (v.accum_usage_total + v.accum_usage_season) <= 0 THEN -1
    ELSE (p.quota_up + p.quota_down) - (v.accum_usage_total + v.accum_usage_season)
  END AS quota_remaining,
  -- time remaining in seconds; time_limit stored in minutes. if time_limit = 0 -> unlimited
  CASE
    WHEN p.time_limit = 0 THEN 0
    WHEN v.first_punched = 0 THEN p.time_limit * 60  -- not started yet -> full time (seconds)
    WHEN (strftime('%s','now') - v.first_punched) > (p.time_limit * 60) THEN -1
    ELSE (p.time_limit * 60) - (strftime('%s','now') - v.first_punched)
  END AS time_remaining_seconds
FROM vouchers v
JOIN packages p ON v.package_id = p.id;

SQL
}
