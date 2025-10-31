#!/bin/sh
opkg update 

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

#---------------------------------------- DBMS ---------------------------------------
# Download database script from GitHub repository
wget -q -O /usr/lib/superwifi/superwifi_database_init.sh "https://raw.githubusercontent.com/Gloory1/openndsv10.3v-vouchers-by-Saeed/main/usr/lib/superwifi-opennds/superwifi_database_init.sh"
chmod +x /usr/lib/superwifi/superwifi_database_init.sh
echo "⏳ Running script..."
# Initial database
/usr/lib/superwifi/superwifi_database_init.sh
echo "⏳ Initialing Database..."
sleep 2

wget -q -O /usr/lib/superwifi/superwifi_migration_v1_to_v2.sh "https://raw.githubusercontent.com/Gloory1/openndsv10.3v-vouchers-by-Saeed/main/usr/lib/superwifi-opennds/superwifi_migration_v1_to_v2.sh"
chmod +x /usr/lib/superwifi/superwifi_migration_v1_to_v2.sh
echo "⏳ Running script..."
# Initial database
/usr/lib/superwifi/superwifi_migration_v1_to_v2.sh
echo "⏳ Database migration..."
sleep 2

/etc/init.d/opennds restart

echo "✅ update complete. OpenNDS - SuperWIFI V2 by Saeed Muhammed is updated successfully."
