#!/bin/sh

# Check and install required packages
opkg update
opkg install opennds block-mount kmod-usb-storage kmod-fs-ext4 kmod-fs-vfat kmod-fs-ntfs usbutils coreutils-base64

# Make sure USB is mounted at /mnt/usb
mkdir -p /mnt/usb
mount -o rw /dev/sda1 /mnt/usb
if ! mount | grep -q '/mnt/usb'; then
    echo "USB mount failed. Please check if /dev/sda1 is correct."
    exit 1
fi

# Create log directory and voucher file on USB
mkdir -p /mnt/usb/ndslog
touch /mnt/usb/ndslog/vouchers.txt
touch /mnt/usb/ndslog/debug.log
touch /mnt/usb/ndslog/attempts.txt

# Download theme voucher script from GitHub repository
wget -O /usr/lib/opennds/accum_theme_voucher.sh "https://raw.githubusercontent.com/Gloory1/openndsv10.3v-vouchers-by-Saeed/main/usr/lib/opennds/accum_theme_voucher.sh"
chmod +x /usr/lib/opennds/accum_theme_voucher.sh
echo "⏳ Waiting for 3 seconds..."
sleep 1
# Download authentication script from GitHub repository
wget -O /usr/lib/opennds/accum_binauth_script.sh "https://raw.githubusercontent.com/Gloory1/openndsv10.3v-vouchers-by-Saeed/main/usr/lib/opennds/accum_binauth_script.sh"
chmod +x /usr/lib/opennds/accum_binauth_script.sh
echo "⏳ Waiting for 3 seconds..."
sleep 1

# Download css script from GitHub repository
mkdir -p /etc/opennds/htdocs
wget -O /etc/opennds/htdocs/splash.css "https://raw.githubusercontent.com/Gloory1/openndsv10.3v-vouchers-by-Saeed/99b3d4497617e5e087bda8cdd2ea17fbafef322a/etc/opennds/htdocs/splash.css"
echo "⏳ Waiting for 3 seconds..."
sleep 1

# Download logo image to the correct location
mkdir -p /etc/opennds/htdocs/images
wget -O /etc/opennds/htdocs/images/splash.jpg "https://raw.githubusercontent.com/Gloory1/openndsv10.3v-vouchers-by-Saeed/059ef23863922fee52f37de7dc13a29d2e4817f4/etc/opennds/htdocs/images/splash.jpg"
echo "⏳ Waiting for 3 seconds..."
sleep 1

echo "🛠️ Preparing openNDS in 15 seconds..."
echo -n "⏳ Progress: ["
for i in $(seq 1 15); do
    echo -n "#"
    sleep 1
done
echo "] ✅ Now It's ready..."


# Get MAC address from br-lan interface
CURRENT_MAC=$(ip link show br-lan | awk '/ether/ {print $2}')

# Configure openNDS
uci set opennds.@opennds[0].enabled='1'
uci set opennds.@opennds[0].login_option_enabled='3'
uci set opennds.@opennds[0].allow_preemptive_authentication='0'
uci set opennds.@opennds[0].gatewayinterface='br-lan'
uci set opennds.@opennds[0].themespec_path='/usr/lib/opennds/accum_theme_voucher.sh'
uci set opennds.@opennds[0].binauth='/usr/lib/opennds/accum_binauth_script.sh'
uci set opennds.@opennds[0].log_mountpoint='/mnt/usb'
uci set opennds.@opennds[0].preauthidletimeout='10'
uci set opennds.@opennds[0].authidletimeout='60'
uci set opennds.@opennds[0].sessiontimeout='360'
uci set opennds.@opennds[0].checkinterval='30'
uci add_list opennds.@opennds[0].trustedmac="$CURRENT_MAC"
uci add_list opennds.@opennds[0].fas_custom_variables_list='multiple_devices=0'

uci commit opennds

# Restart opennds service to apply changes
/etc/init.d/opennds restart

echo "✅ Setup complete. OpenNDS - Accum Theme Voucher by Saeed Muhammed is installed successfully."
# Done
echo "Reboot the router or restart opennds to apply changes."
reboot
