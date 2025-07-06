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
- Must contain 13 columns:

- Examples:
  - `123456789|AA:BB:CC:DD:EE:FF|1440|1024|512|1048576|1048576|10245|5245|1750955636|1750955636|0` `#used`
  - `123456789|0||1440|1024|512|1048576|1048576|0|0|0|0|0` `#unused`

| Column # | Description | Example |
|----------|-------------|---------|
| 1 | ID Primary auto increment | `123456789` |
| 2 | Voucher Token | `123456789` |
| 3 | Client MAC Address | `AA:BB:CC:DD:EE:FF` |
| 4 | Validity (minutes)(`0` if unlimited) | `1440` |
| 5 | Download Speed Limit (kb/s)(`0` if unlimited) | `1024` |
| 6 | Upload Speed Limit (kb/s)(`0` if unlimited) | `512` |
| 7 | Download Quota (kB)(`0` if unlimited) | `1048576` |
| 8 | Upload Quota (kB)(`0` if unlimited) | `1048576` |
| 9 | Total Accumulative Download (kb) | `86015` |
| 10 | Season Accumulative Download (kb) | `45101` |
| 11 | First Use Timestamp (`0` if unused) | `1719483600` |
| 12 | Last Use Timestamp (`0` if unused) | `1719483600` |
| 13 | Quota expired (`0` still active) | `0` |

---
> **Note on Column 11,12:**  
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


