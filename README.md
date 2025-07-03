# 🎯 SuperWIFI Captive Portal by Saeed Muhammed  

🔧 **Customized by:** Saeed Muhammed  
🧱 **Based on:** OpenNDS v10.3.0  
🎨 **Theme used:** ThemeSpec + Custimezed Voucher_Theme

### 📁 Files Locations
- Default `superwifi_theme.sh` file path: `/usr/lib/superwifi-opennds/superwifi_theme.sh`
- Default `superwifi_binauth.sh` file path: `/usr/lib/superwifi-opennds/superwifi_binauth.sh`  
- Default `superwifi_database_lib.sh` file path: `/usr/lib/superwifi-opennds/superwifi_database_lib.sh`  
- Default `superwifi_database.db file` path: `/overlay/superwifi-opennds/superwifi_database.db`

> ⚠️ You can change the paths - read `OpenNDS documentations`:

---

### ⚠️ Important Warning

In production environments, store the voucher file on external storage like:

- USB stick
- External hard drive
- Network shared drive

To prevent data loss during power outages or reboots.

---

### 📄 Voucher File Format (SQlite)

- No header row `|` separated 
- Must contain 10 columns:

- Examples:
  - `123456789|AA:BB:CC:DD:EE:FF|1024|512|1048576|1048576|1440|10245|1750955636|1750955636` `#used`
  - `123456789|0|1024|512|1048576|1048576|1440|0|0|0` `#unused`

| Column # | Description | Example |
|----------|-------------|---------|
| 1 | Voucher Code | `123456789` |
| 2 | Client MAC Address | `AA:BB:CC:DD:EE:FF` |
| 3 | Download Speed Limit (kb/s)(`0` if unlimited) | `1024` |
| 4 | Upload Speed Limit (kb/s)(`0` if unlimited) | `512` |
| 5 | Download Quota (kB)(`0` if unlimited) | `1048576` |
| 6 | Upload Quota (kB)(`0` if unlimited) | `1048576` |
| 7 | Validity (minutes)(`0` if unlimited) | `1440` |
| 8 | Accumulative Download Quota (kB) | `374574` |
| 9 | First Use Timestamp (`0` if unused) | `1719483600` |
| 10 | Last Use Timestamp (`0` if unused) | `1719483600` |

---
> **Note on Column 9,10:**  
> This column holds the **timestamp (in seconds)** of the firsta and last time the voucher was used.  
> - If the value is `0`, it means the voucher hasn't been used yet.  
> - Once punched, the script sets it to the current UNIX time and uses it to track session expiration.

### 🔐 Voucher Code Format

| Rule                        | Allowed | Example         |
|-----------------------------|---------|------------------|
| Numbers only               | ✅ Yes  | `123456789`     |
| Letters only               | ✅ Yes  | `abcdefghi`     |
| Mixed letters & numbers    | ✅ Yes  | `12345abcd`     |
| Dash in middle (numbers)   | ✅ Yes  | `1234-5678`     |
| Dash in middle (letters)   | ✅ Yes  | `abcd-efgh`     |
| Alphanumeric (no dash)     | ✅ Yes  | `12345abcd`     |
| Alphanumeric with dash     | ✅ Yes  | `1234-abcd`     |


