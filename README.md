# 🎯 Voucher Captive Portal by Saeed Muhammed  

🔧 **Customized by:** Saeed Muhammed  
🧱 **Based on:** OpenNDS v10.3.0  
🎨 **Theme used:** ThemeSpec + Custimezed Voucher_Theme

### 📁 Files Locations
- Default `theme_voucher.sh` file path: `/usr/lib/opennds/theme_voucher.sh`  
- Default `vouchers.txt file` path: `/mnt/usb/ndslog/vouchers.txt`

> ⚠️ You can change the paths - read `OpenNDS documentations`:

---

### ⚠️ Important Warning

In production environments, store the voucher file on external storage like:

- USB stick
- External hard drive
- Network shared drive

To prevent data loss during power outages or reboots.

---

### 📄 Voucher File Format (CSV)

- CSV format  
- No header row  
- Comma `,` separated  
- One line = One voucher  
- Must contain 9 columns:
- Each line in `vouchers.txt` follows this structure:
- Examples:
  - `123456789,1024,512,1048576,1048576,1440,1750955636,AA:BB:CC:DD:EE:FF,374574` `#used`
  - `112233445,1024,512,1048576,1048576,1440,0,0,0` `#unused`

| Column # | Description | Example |
|----------|-------------|---------|
| 1 | Voucher Code | `123456789` |
| 2 | Download Speed Limit (kb/s)(`0` if unlimited) | `1024` |
| 3 | Upload Speed Limit (kb/s)(`0` if unlimited) | `512` |
| 4 | Download Quota (kB)(`0` if unlimited) | `1048576` |
| 5 | Upload Quota (kB)(`0` if unlimited) | `1048576` |
| 6 | Validity (minutes)(`0` if unlimited) | `1440` |
| 7 | First Use Timestamp (`0` if unused) | `1719483600` |
| 8 | Client MAC Address | `AA:BB:CC:DD:EE:FF` |
| 9 | Accumulative Download Quota (kB) | `374574` |

---
> **Note on Column 7:**  
> This column holds the **timestamp (in seconds)** of the first time the voucher was used.  
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


