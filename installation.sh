#!/bin/sh

# Check and install required packages
opkg update
opkg install opennds block-mount kmod-usb-storage kmod-fs-ext4 kmod-fs-vfat kmod-fs-ntfs usbutils

# Make sure USB is mounted at /mnt/usb
mkdir -p /mnt/usb
mount -o rw /dev/sda1 /mnt/usb

# Create log directory and voucher file on USB
mkdir -p /mnt/usb/ndslog
touch /mnt/usb/ndslog/vouchers.txt

# Download theme_voucher.sh from GitHub repository
# TODO: add theme_voucer_by_SaeedMuhammed
wget -O /usr/lib/opennds/theme_voucher.sh https://github.com/Gloory1/openndsv10.3v-vouchers-by-Saeed/blob/53b3fb9784500d923d38a1310948546df86e156d/theme_voucher.sh
chmod +x /usr/lib/opennds/theme_voucher.sh

# Download logo image to correct location
mkdir -p /etc/opennds/htdocs/images
wget -O /etc/opennds/htdocs/images/logo.png "https://github.com/Gloory1/openndsv10.3v-vouchers-by-Saeed/blob/53b3fb9784500d923d38a1310948546df86e156d/logo.png"

# Configure openNDS
uci set opennds.@opennds[0].enabled='1'
uci set opennds.@opennds[0].gatewayinterface='br-lan'
uci set opennds.@opennds[0].login_option_enabled='3'
uci set opennds.@opennds[0].themespec_path='/usr/lib/opennds/theme_voucher.sh'
uci set opennds.@opennds[0].log_mountpoint='/mnt/usb'
uci set opennds.@opennds[0].preauthidletimeout='10'
uci set opennds.@opennds[0].authidletimeout='60'
uci set opennds.@opennds[0].sessiontimeout='360'
uci set opennds.@opennds[0].checkinterval='15'
uci add_list opennds.@opennds[0].trustedmac='d8:43:ae:3d:1a:ee'
uci commit opennds

# Done
echo "Setup complete. Reboot the router or restart opennds to apply changes."
