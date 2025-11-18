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
$BASE_RAW/usr/lib/superwifi-opennds/superwifi_quota_tracking.sh|$DEST_DIR/superwifi_quota_tracking.sh
$BASE_RAW/etc/opennds/htdocs/splash.css|$UI_DIR/splash.css
"


# Download all files
for entry in $files; do
  url=$(echo "$entry" | cut -d'|' -f1)
  out=$(echo "$entry" | cut -d'|' -f2)
  mkdir -p "$(dirname "$out")"
  download "$url" "$out" || { echo "❌ Aborting."; exit 1; }
done
