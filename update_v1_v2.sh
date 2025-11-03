#!/bin/sh

# ----------------- CONFIG -----------------
BASE_RAW="https://raw.githubusercontent.com/Gloory1/openndsv10.3v-vouchers-by-Saeed/main"
REQUIRED_PKGS="opennds sqlite3-cli jq"
DEST_DIR="/usr/lib/superwifi"
UI_DIR="/etc/opennds/htdocs"
DEFAULT_PROVIDER="Super WIFI"
DB_PATH="/overlay/superwifi/superwifi_database_v2.db"
# -----------------------------------------

echo "🔍 Checking network..."
if ! ping -c 1 -W 2 8.8.8.8 >/dev/null 2>&1; then
  echo "❌ No network. Fix it and retry."
  exit 1
fi

echo "🔄 Updating package lists..."
opkg update

# Install required packages if missing
missing=""
for pkg in $REQUIRED_PKGS; do
  if ! opkg list-installed | awk '{print $1}' | grep -xq "$pkg"; then
    missing="$missing $pkg"
  fi
done

if [ -n "$missing" ]; then
  echo "⚙️ Installing:$missing"
  opkg install $missing
else
  echo "✅ All required packages installed."
fi

# Ensure directories exist
mkdir -p "$DEST_DIR"
mkdir -p "$UI_DIR/images"
mkdir -p "$(dirname "$DB_PATH")"
chmod 755 "$(dirname "$DB_PATH")"

# Verify sqlite3 exists
if ! command -v sqlite3 >/dev/null 2>&1; then
  echo "❌ sqlite3 not installed. Aborting."
  exit 1
fi

# Download helper
download() {
  url="$1"; out="$2"
  echo "⏳ Downloading $url -> $out"
  wget -T 20 -O "$out" "$url" || { echo "❌ Failed $url"; return 1; }
  chmod +x "$out" 2>/dev/null || true
  return 0
}

# Files to download
files="
$BASE_RAW/usr/lib/superwifi-opennds/superwifi_theme.sh|$DEST_DIR/superwifi_theme.sh
$BASE_RAW/usr/lib/superwifi-opennds/superwifi_binauth.sh|$DEST_DIR/superwifi_binauth.sh
$BASE_RAW/usr/lib/superwifi-opennds/superwifi_database_manager.sh|$DEST_DIR/superwifi_database_manager.sh
$BASE_RAW/usr/lib/superwifi-opennds/superwifi_migration_v1_to_v2.sh|$DEST_DIR/superwifi_migration_v1_to_v2.sh
$BASE_RAW/usr/lib/superwifi-opennds/superwifi_database_init.sh|$DEST_DIR/superwifi_database_init.sh
$BASE_RAW/usr/lib/superwifi-opennds/superwifi_quota_tracking.sh|$DEST_DIR/superwifi_quota_tracking.sh
$BASE_RAW/usr/lib/superwifi-opennds/superwifi|/etc/init.d/superwifi
$BASE_RAW/etc/opennds/htdocs/splash.css|$UI_DIR/splash.css
"

# Download all files
for entry in $files; do
  url=$(echo "$entry" | cut -d'|' -f1)
  out=$(echo "$entry" | cut -d'|' -f2)
  mkdir -p "$(dirname "$out")"
  download "$url" "$out" || { echo "❌ Aborting."; exit 1; }
done

# Enable init script
if [ -f /etc/init.d/superwifi ]; then
  chmod +x /etc/init.d/superwifi
  /etc/init.d/superwifi enable || true
fi


# Configure OpenNDS
if uci show opennds >/dev/null 2>&1; then
  uci set opennds.@opennds[0].enabled='1'
  uci set opennds.@opennds[0].login_option_enabled='3'
  uci set opennds.@opennds[0].fas_secure_enabled='3'
  uci set opennds.@opennds[0].themespec_path="$DEST_DIR/superwifi_theme.sh"
  uci set opennds.@opennds[0].binauth="$DEST_DIR/superwifi_binauth.sh"
  uci set opennds.@opennds[0].preauthidletimeout='10'
  uci set opennds.@opennds[0].authidletimeout='30'
  uci set opennds.@opennds[0].sessiontimeout='360'
  uci set opennds.@opennds[0].checkinterval='60'
  uci commit opennds
fi

# Initialize database safely
echo "⏳ Initializing Database..."

if [ -f "$DB_PATH" ]; then
  if [ -x "$DEST_DIR/superwifi_database_init.sh" ]; then
    echo "⚙️  Running database initialization..."
    "$DEST_DIR/superwifi_database_init.sh" && echo "✅ Database initialized."
  else
    echo "⚠️  Init script not found."
  fi

  if [ -x "$DEST_DIR/superwifi_migration_v1_to_v2.sh" ]; then
    echo "⚙️  Running migration (v1 → v2)..."
    "$DEST_DIR/superwifi_migration_v1_to_v2.sh" && echo "✅ Migration done."
  else
    echo "⚠️  Migration script not found."
  fi
else
  echo "⚠️  Database file not found at $DB_PATH — skipping init & migration."
fi

# Restart OpenNDS
[ -x /etc/init.d/opennds ] && /etc/init.d/opennds restart

echo "✅ Update complete. OpenNDS - SuperWIFI V2 by Saeed Muhammed updated successfully."

