#!/bin/sh
set -e
==========================================
إعدادات المسارات (تأكد من صحتها لديك)
==========================================
المصدر: القاعدة القديمة (التي تحتوي على الداتا الحالية)
SOURCE_DB="/overlay/superwifi/superwifi_database_v2.db"
الهدف: القاعدة الجديدة (التي سننقل إليها الداتا)
TARGET_DB="/overlay/superwifi/superwifi_database.db"
ملف مؤقت لتجنب مشاكل القفل (Database Locking)
TMP_COPY="/tmp/source_db_copy.db"
==========================================
1. النسخ الاحتياطي (الأمان أولاً)
==========================================
echo "Starting Backup..."
[ -f "$SOURCE_DB" ] && cp -v "$SOURCE_DB" "${SOURCE_DB}.bak_$(date +%s)"
[ -f "$TARGET_DB" ] && cp -v "$TARGET_DB" "${TARGET_DB}.bak_$(date +%s)"
==========================================
2. التجهيز
==========================================
نسخ القاعدة القديمة لمكان مؤقت للعمل عليها
echo "Copying source DB to temp..."
cp -f "$SOURCE_DB" "$TMP_COPY"
التأكد من إنشاء الجدول في القاعدة الجديدة (لو مش موجود)
نستخدم السكربت السابق init_db لإنشاء الهيكلية، أو ننشئها يدوياً هنا للأمان
echo "Ensuring target schema exists..."
sqlite3 "$TARGET_DB" <<EOF
CREATE TABLE IF NOT EXISTS vouchers_info (
    token_id INTEGER PRIMARY KEY AUTOINCREMENT,
    package_id INTEGER DEFAULT 0,
    token TEXT NOT NULL UNIQUE,
    user_mac TEXT DEFAULT '0',
    membership INTEGER DEFAULT 0,
    auth_method INTEGER DEFAULT 0,
    rate_up_kb INTEGER DEFAULT 0,
    rate_down_kb INTEGER DEFAULT 0,
    data_limit_kb INTEGER DEFAULT 0,
    time_limit_min INTEGER DEFAULT 0,
    cumulative_usage_total_kb INTEGER DEFAULT 0,
    cumulative_usage_season_kb INTEGER DEFAULT 0,
    first_punched_sec INTEGER DEFAULT 0,
    last_punched_sec INTEGER DEFAULT 0,
    expiration_status INTEGER DEFAULT 0,
    price_data_cost_cent INTEGER DEFAULT 0,
    price_service_cost_cent INTEGER DEFAULT 0,
    price_sell_cent INTEGER DEFAULT 0,
    created_at INTEGER DEFAULT (strftime('%s', 'now')),
    description TEXT DEFAULT ''
);
CREATE INDEX IF NOT EXISTS idx_vouchers_token ON vouchers_info(token);
CREATE INDEX IF NOT EXISTS idx_vouchers_mac ON vouchers_info(user_mac);
EOF
==========================================
3. عملية النقل (The Migration Logic)
==========================================
echo "Migrating data from Old Schema to New Schema..."
sqlite3 "$TARGET_DB" <<EOF
-- ربط القاعدة المؤقتة (القديمة)
ATTACH DATABASE '$TMP_COPY' AS source_db;
-- نقل البيانات مع تغيير أسماء الأعمدة (Mapping)
INSERT OR IGNORE INTO vouchers_info (
    token, 
    user_mac, 
    package_id, 
    membership, 
    auth_method, -- جديد
    time_limit_min, -- تغيير اسم
    rate_down_kb,   -- تغيير اسم
    rate_up_kb,     -- تغيير اسم
    data_limit_kb,  -- دمج/تغيير اسم
    cumulative_usage_total_kb,  -- تغيير اسم
    cumulative_usage_season_kb, -- تغيير اسم
    first_punched_sec, -- تغيير اسم
    last_punched_sec,  -- تغيير اسم
    expiration_status
)
SELECT 
    token,
    user_mac,
    package_id,
    membership,
    0 AS auth_method, -- الافتراضي للكروت القديمة (يدوي)
    time_limit AS time_limit_min,
    rate_down AS rate_down_kb,
    rate_up AS rate_up_kb,
    quota_down AS data_limit_kb, -- افترضنا أن الكوتا الرئيسية هي الـ Down
    cumulative_usage_total AS cumulative_usage_total_kb,
    cumulative_usage_season AS cumulative_usage_season_kb,
    first_punched AS first_punched_sec,
    last_punched AS last_punched_sec,
    expiration_status
FROM source_db.vouchers_info;
DETACH DATABASE source_db;
EOF
==========================================
4. التنظيف والتقرير
==========================================
rm -f "$TMP_COPY"
echo "------------------------------------------------"
echo "Migration Completed Successfully!"
echo "New Database Path: $TARGET_DB"
echo "Rows in New DB:"
sqlite3 "$TARGET_DB" "SELECT COUNT(*) FROM vouchers_info;"
echo "------------------------------------------------"
