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
$BASE_RAW/usr/lib/superwifi-opennds/superwifi_database_init.sh|$DEST_DIR/superwifi_database_init.sh
$BASE_RAW/usr/lib/superwifi-opennds/superwifi_quota_tracking.sh|$DEST_DIR/superwifi_quota_tracking.sh
$BASE_RAW/usr/lib/superwifi-opennds/superwifi|/etc/init.d/superwifi
$BASE_RAW/etc/opennds/htdocs/splash.jpg|$UI_DIR/images/splash.jpg
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

# Set provider name safely
provider_name="${1:-${PROVIDER_NAME:-$DEFAULT_PROVIDER}}"
echo "Using provider name: $provider_name"

# Get MAC from br-lan or fallback
CURRENT_MAC="$(ip link show br-lan 2>/dev/null | awk '/ether/ {print $2}' || true)"
[ -z "$CURRENT_MAC" ] && CURRENT_MAC="$(ip link show br0 2>/dev/null | awk '/ether/ {print $2}' || true)"

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
  uci add_list opennds.@opennds[0].fas_custom_variables_list="provider_name=$provider_name"
  [ -n "$CURRENT_MAC" ] && uci add_list opennds.@opennds[0].trustedmac="$CURRENT_MAC"
  uci commit opennds
fi

# Initialize database safely
echo "⏳ Initializing Database..."
if [ ! -f "$DB_PATH" ]; then
  sqlite3 "$DB_PATH" "CREATE TABLE IF NOT EXISTS dummy(id INTEGER);" || { echo "❌ Cannot create DB at $DB_PATH"; exit 1; }
fi

[ -x "$DEST_DIR/superwifi_database_init.sh" ] && "$DEST_DIR/superwifi_database_init.sh"

# Restart OpenNDS
[ -x /etc/init.d/opennds ] && /etc/init.d/opennds restart

echo "✅ Setup complete. OpenNDS - SuperWIFI Theme by Saeed Muhammed installed."
