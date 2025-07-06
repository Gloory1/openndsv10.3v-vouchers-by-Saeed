#!/bin/sh

# Check and install required packages
opkg update
# opkg install opennds block-mount kmod-usb-storage kmod-fs-ext4 kmod-fs-vfat kmod-fs-ntfs usbutils coreutils-base64 sqlite3-cli
opkg install opennds coreutils-base64 sqlite3-cli sqlite3-cli jq

Create log directory and voucher file on USB
mkdir -p /usr/lib/superwifi
mkdir -p /overlay/superwifi


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
wget -O /usr/lib/superwifi/superwifi_database_lib.sh "https://raw.githubusercontent.com/Gloory1/openndsv10.3v-vouchers-by-Saeed/main/usr/lib/superwifi-opennds/superwifi_database_lib.sh"
chmod +x /usr/lib/superwifi/superwifi_database_lib.sh
echo "⏳ Waiting for second..."
sleep 1

# Download database file from GitHub repository
wget -O /overlay/superwifi/superwifi_database.db "https://raw.githubusercontent.com/Gloory1/openndsv10.3v-vouchers-by-Saeed/main/usr/lib/superwifi-opennds/superwifi_database.db"
chmod 644 /overlay/superwifi/superwifi_database.db
echo "⏳ Waiting for second..."
sleep 1

# Download qouta tracking file from GitHub repository
wget -O /usr/lib/superwifi/superwifi_quota_tracking.sh "https://raw.githubusercontent.com/Gloory1/openndsv10.3v-vouchers-by-Saeed/main/usr/lib/superwifi-opennds/superwifi_quota_tracking.sh"
chmod +x /usr/lib/superwifi/superwifi_quota_tracking.sh
echo "⏳ Waiting for second..."
sleep 1

# Download cron file from GitHub repository
wget -O /etc/init.d/superwifi "https://raw.githubusercontent.com/Gloory1/openndsv10.3v-vouchers-by-Saeed/main/usr/lib/superwifi-opennds/superwifi"
chmod +x /etc/init.d/superwifi
/etc/init.d/superwifi_quota enable
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


# Get MAC address from br-lan interface
CURRENT_MAC=$(ip link show br-lan | awk '/ether/ {print $2}')

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
uci add_list opennds.@opennds[0].trustedmac="$CURRENT_MAC"

# uci set opennds.@opennds[0].log_mountpoint='/mnt/usb'
uci commit opennds

# Restart opennds service to apply changes
/etc/init.d/opennds restart

echo "✅ Setup complete. OpenNDS -SuperWIFI Theme by Saeed Muhammed is installed successfully."
# Done
echo "Reboot the router to apply changes."
reboot
