#!/bin/sh

# Check and install required packages
opkg update
# opkg install opennds sqlite3-cli jq

# Download theme voucher script from GitHub repository
wget -O /usr/lib/superwifi/superwifi_theme.sh "https://raw.githubusercontent.com/Gloory1/openndsv10.3v-vouchers-by-Saeed/main/usr/lib/superwifi-opennds/superwifi_theme.sh"
chmod +x /usr/lib/superwifi/superwifi_theme.sh
echo "⏳ Waiting for second..."
sleep 1
# Download authentication script from GitHub repository
wget -O /usr/lib/superwifi/superwifi_binauth.sh "https://raw.githubusercontent.com/Gloory1/openndsv10.3v-vouchers-by-Saeed/main/usr/lib/superwifi-opennds/superwifi_binauth.sh"
chmod +x /usr/lib/superwifi/superwifi_binauth.sh
echo "⏳ Waiting for second..."
sleep 1

# Download database script from GitHub repository
wget -O /usr/lib/superwifi/superwifi_database_manager.sh "https://raw.githubusercontent.com/Gloory1/openndsv10.3v-vouchers-by-Saeed/main/usr/lib/superwifi-opennds/superwifi_database_manager.sh"
chmod +x /usr/lib/superwifi/superwifi_database_manager.sh
echo "⏳ Waiting for second..."
sleep 1

# Download database script from GitHub repository
wget -q -O /usr/lib/superwifi/superwifi_database_init.sh "https://raw.githubusercontent.com/Gloory1/openndsv10.3v-vouchers-by-Saeed/main/usr/lib/superwifi-opennds/superwifi_database_init.sh"
chmod +x /usr/lib/superwifi/superwifi_database_init.sh
echo "⏳ Running script..."

# Download qouta tracking file from GitHub repository
wget -O /usr/lib/superwifi/superwifi_quota_tracking.sh "https://raw.githubusercontent.com/Gloory1/openndsv10.3v-vouchers-by-Saeed/main/usr/lib/superwifi-opennds/superwifi_quota_tracking.sh"
chmod +x /usr/lib/superwifi/superwifi_quota_tracking.sh
echo "⏳ Waiting for second..."
sleep 1

# Download cron file from GitHub repository
wget -O /etc/init.d/superwifi "https://raw.githubusercontent.com/Gloory1/openndsv10.3v-vouchers-by-Saeed/main/usr/lib/superwifi-opennds/superwifi"
chmod +x /etc/init.d/superwifi
/etc/init.d/superwifi enable
echo "⏳ Waiting for second..."
sleep 1

# Download css script from GitHub repository
mkdir -p /etc/opennds/htdocs
wget -O /etc/opennds/htdocs/splash.css "https://raw.githubusercontent.com/Gloory1/openndsv10.3v-vouchers-by-Saeed/main/etc/opennds/htdocs/splash.css"
echo "⏳ Waiting for second..."
sleep 1

# Download logo image to the correct location
mkdir -p /etc/opennds/htdocs/images
wget -O /etc/opennds/htdocs/images/splash.jpg "https://raw.githubusercontent.com/Gloory1/openndsv10.3v-vouchers-by-Saeed/main/etc/opennds/htdocs/splash.jpg"
echo "⏳ Waiting for second..."
sleep 1

echo "🛠️ Preparing openNDS in 10 seconds..."
echo -n "⏳ Progress: ["
for i in $(seq 1 10); do
    echo -n "#"
    sleep 1
done
echo "] ✅ Now It's ready..."

# Prompt / fallback لاسم البروڤايدر
DEFAULT_PROVIDER="Super WIFI"
if [ -n "$1" ]; then
  provider_name="$1"
elif [ -n "$PROVIDER_NAME" ]; then
  provider_name="$PROVIDER_NAME"
elif [ -t 0 ]; then
  echo -n "Enter provider name [${DEFAULT_PROVIDER}]: "
  read provider_name
  provider_name=${provider_name:-$DEFAULT_PROVIDER}
else
  provider_name="$DEFAULT_PROVIDER"
fi

echo "Using provider name: $provider_name"

# Get MAC address from br-lan interface
CURRENT_MAC=$(ip link show br-lan | awk '/ether/ {print $2}' || true)

# Configure openNDS
uci set opennds.@opennds[0].enabled='1'
uci set opennds.@opennds[0].login_option_enabled='3'
uci set opennds.@opennds[0].fas_secure_enabled='3'
uci set opennds.@opennds[0].themespec_path='/usr/lib/superwifi/superwifi_theme.sh'
uci set opennds.@opennds[0].binauth='/usr/lib/superwifi/superwifi_binauth.sh'
uci set opennds.@opennds[0].preauthidletimeout='10'
uci set opennds.@opennds[0].authidletimeout='30'
uci set opennds.@opennds[0].sessiontimeout='360'
uci set opennds.@opennds[0].checkinterval='60'
uci add_list opennds.@opennds[0].fas_custom_variables_list="provider_name=$provider_name"

if [ -n "$CURRENT_MAC" ]; then
  uci add_list opennds.@opennds[0].trustedmac="$CURRENT_MAC"
fi

uci commit opennds

# Initial database
/usr/lib/superwifi/superwifi_database_init.sh
echo "⏳ Initialing Database..."
sleep 2

/etc/init.d/opennds restart

echo "✅ Setup complete. OpenNDS -SuperWIFI Theme by Saeed Muhammed is installed successfully."
