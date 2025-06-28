#!/bin/sh

# Check and install required packages
opkg update
opkg install opennds block-mount kmod-usb-storage kmod-fs-ext4 kmod-fs-vfat kmod-fs-ntfs usbutils coreutils-base64

# Make sure USB is mounted at /mnt/usb
mkdir -p /mnt/usb
mount -o rw /dev/sda1 /mnt/usb

# Create log directory and voucher file on USB
mkdir -p /mnt/usb/ndslog
touch /mnt/usb/ndslog/vouchers.txt
touch /mnt/usb/ndslog/debug.log

# Download theme_voucher.sh from GitHub repository
# TODO: add theme_voucer_by_SaeedMuhammed
wget -O /usr/lib/opennds/accum_theme_voucher.sh https://github.com/Gloory1/openndsv10.3v-vouchers-by-Saeed/blob/6ce887bf707a714e4fc824f443299c21022b60e7/usr/lib/opennds/accum_theme_voucher.sh
chmod +x /usr/lib/opennds/accum_theme_voucher.sh

wget -O /usr/lib/opennds/accum_binauth_script.sh https://github.com/Gloory1/openndsv10.3v-vouchers-by-Saeed/blob/6ce887bf707a714e4fc824f443299c21022b60e7/usr/lib/opennds/accum_binauth_script.sh
chmod +x /usr/lib/opennds/accum_binauth_script.sh
# Download logo image to correct location
mkdir -p /etc/opennds/htdocs/images
wget -O /etc/opennds/htdocs/images/logo.png "https://github.com/Gloory1/openndsv10.3v-vouchers-by-Saeed/blob/53b3fb9784500d923d38a1310948546df86e156d/logo.png"

# حذف الماك القديم وإضافة الماك الجديد تلقائياً
CURRENT_MAC=$(ip link show br-lan | awk '/ether/ {print $2}')
# Configure openNDS
uci set opennds.@opennds[0].enabled='1'
uci set opennds.@opennds[0].gatewayinterface='br-lan'
uci set opennds.@opennds[0].login_option_enabled='3'
uci set opennds.@opennds[0].themespec_path='/usr/lib/opennds/accum_theme_voucher.sh'
uci set opennds.@opennds[0].binauth='/usr/lib/opennds/accum_binauth_script.sh'
uci set opennds.@opennds[0].log_mountpoint='/mnt/usb'
uci set opennds.@opennds[0].allow_preemptive_authentication='0'
uci set opennds.@opennds[0].preauthidletimeout='10'
uci set opennds.@opennds[0].authidletimeout='60'
uci set opennds.@opennds[0].sessiontimeout='360'
uci set opennds.@opennds[0].checkinterval='30'
uci add_list opennds.@opennds[0].trustedmac="$CURRENT_MAC"
uci add_list opennds.@opennds[0].fas_custom_variables_list='multiple_devices=0'
uci add_list opennds.@opennds[0].fas_custom_images_list='logo_png=file:///etc/opennds/htdocs/images/logo.png'

uci commit opennds

# Done
echo "Setup complete. Reboot the router or restart opennds to apply changes."
