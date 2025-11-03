# 🎯 SuperWIFI Captive Portal by Saeed Muhammed  

🔧 **Customized by:** Saeed Muhammed  
🧱 **Based on:** OpenNDS v10.3.0  
🎨 **Theme used:** ThemeSpec + Custimezed Voucher_Theme

### 📁 Installation Code v2
```markdown
wget -O - https://raw.githubusercontent.com/Gloory1/openndsv10.3v-vouchers-by-Saeed/refs/heads/main/installation_v2.sh | sh
```
### 📁 Update Code from v1 to v2
```markdown
wget -O - https://raw.githubusercontent.com/Gloory1/openndsv10.3v-vouchers-by-Saeed/refs/heads/main/update_v1_v2.sh | sh
```

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
 
---

# 📘 SuperWiFi Voucher Database Structure

This document describes the database structure used by **SuperWiFi** for voucher-based captive portal management on **OpenWRT + OpenNDS** systems.

---

## 🗂️ Database Overview

The system uses **SQLite** as its local storage, with several tables and views for managing vouchers, packages, authentication logs, and usage tracking.

---

## 🧾 Table: `vouchers_info`

This table stores all voucher records (tokens, limits, usage, and expiration).

**File format:**  
- Each line is `|`-separated (no header row).  
- Must contain **14 columns** in the exact order below.

| # | Column | Type | Description |
|---:|---|---|---|
| 1 | `token` | TEXT (PRIMARY KEY) | Unique voucher token |
| 2 | `user_mac` | TEXT | Connected device MAC address (`0` if unused) |
| 3 | `package_id` | INTEGER | Linked package ID (from `packages_log`) |
| 4 | `membership` | INTEGER | 0 = Voucher, 1 = VIP |
| 5 | `time_limit` | INTEGER | Time in minutes (0 = unlimited) |
| 6 | `rate_down` | INTEGER | Download speed limit in KB/s (0 = unlimited) |
| 7 | `rate_up` | INTEGER | Upload speed limit in KB/s (0 = unlimited) |
| 8 | `quota_down` | INTEGER | Download quota in KB (0 = unlimited) |
| 9 | `quota_up` | INTEGER | Upload quota in KB (0 = unlimited) |
|10 | `cumulative_usage_total` | INTEGER | Total downloaded data (KB) since creation |
|11 | `cumulative_usage_season` | INTEGER | Downloaded data (KB) during current session |
|12 | `first_punched` | INTEGER | UNIX timestamp of first login (0 = never used) |
|13 | `last_punched` | INTEGER | UNIX timestamp of last login |
|14 | `expiration_status` | INTEGER | 0 = Active, 1 = Expired |

**Example (used voucher):**
```

123456789|AA:BB:CC:DD:EE:FF|1|0|1440|1024|512|1048576|1048576|86015|45101|1719483600|1719487200|0

```

**Example (unused voucher):**
```

123456790|0|0|0|1440|1024|512|1048576|1048576|0|0|0|0|0

````


## 📦 Table: `packages_log`

---
Stores package templates or history for voucher generation.

| # | Column | Type | Description |
|---:|---|---|---|
| 1 | `id` | INTEGER PRIMARY KEY AUTOINCREMENT | Package ID |
| 2 | `created_at` | TEXT | Creation timestamp (`datetime('now')`) |
| 3 | `description` | TEXT | Description or label |
| 4 | `quantity` | INTEGER | Number of vouchers generated |
| 5 | `membership` | INTEGER | 0 = Voucher, 1 = VIP |
| 6 | `time_limit` | INTEGER | Duration in minutes (0 = unlimited) |
| 7 | `rate_up` | INTEGER | Upload limit (KB/s) |
| 8 | `rate_down` | INTEGER | Download limit (KB/s) |
| 9 | `quota_up` | INTEGER | Upload quota (KB) |
|10 | `quota_down` | INTEGER | Download quota (KB) |

---

## 🧠 Table: `vouchers_usage_log`

Tracks detailed usage data for each voucher (download, upload, etc.) per session.

| # | Column | Type | Description |
|---:|---|---|---|
| 1 | `id` | INTEGER PRIMARY KEY AUTOINCREMENT | Record ID |
| 2 | `voucher_token` | TEXT | Token linked to `vouchers_info.token` |
| 3 | `mac` | TEXT | Device MAC address |
| 4 | `ip` | TEXT | Client IP address |
| 5 | `download_this_session` | INTEGER | Data downloaded this session (KB) |
| 6 | `upload_this_session` | INTEGER | Data uploaded this session (KB) |
| 7 | `timestamp` | TEXT | Log timestamp |

---

## 📜 Table: `auth_attempts_log`

Stores authentication attempts (successful and failed).

| # | Column | Type | Description |
|---:|---|---|---|
| 1 | `id` | INTEGER PRIMARY KEY AUTOINCREMENT | Record ID |
| 2 | `token` | TEXT | Attempted voucher token |
| 3 | `mac` | TEXT | MAC address |
| 4 | `ip` | TEXT | IP address |
| 5 | `result` | TEXT | “success” or “fail” |
| 6 | `created_at` | TEXT | Timestamp of the attempt |

---

## 👁️ View: `vouchers_auth_details`

This view joins `vouchers_info` with computed fields for authentication and remaining quota display.

```sql
CREATE VIEW IF NOT EXISTS vouchers_auth_details AS
SELECT
    v.token AS voucher_token,
    v.package_id,
    v.time_limit,
    v.rate_down,
    v.rate_up,
    v.quota_down,
    v.quota_up,
    v.cumulative_usage_total,
    v.cumulative_usage_season,
    (CASE
        WHEN v.quota_down = 0 THEN -1
        ELSE (v.quota_down - v.cumulative_usage_total)
     END) AS remaining_quota,
    v.first_punched,
    v.last_punched,
    v.expiration_status
FROM vouchers_info v;
````

---

## ⚙️ Maintenance Notes

* The **voucher manager script** (`superwifi_database_manager.sh`) updates usage stats every minute:

  * Compares `download_this_session` with `cumulative_usage_season`
  * Adds the difference to `cumulative_usage_total`
  * Updates `cumulative_usage_season`
* When total quota is reached, the voucher is marked as **expired**.
* `expiration_status` can be used to manually deactivate vouchers.

---

## 🧩 System Hierarchy

1. **Suppliers** → Provide captive portal systems
2. **Producer (You)** → Manages the app, designs vouchers, and sells points
3. **Distributors** → Buy points in bulk and resell to cafes
4. **Customers (Cafes)** → Use vouchers to provide Wi-Fi access to users

---

## 🛠️ Example: Refreshing Data Every Minute

The cron job below ensures voucher usage is synced automatically:

```bash
* * * * * /usr/lib/superwifi/superwifi_database_manager.sh update_usage
```

---

## 🧾 Summary

* All tables are synchronized via scripts in `/usr/lib/superwifi/`
* Data is stored locally in `/usr/lib/superwifi/superwifi.db`
* Frontend app (Flutter) communicates via the **CloudWiFiZone API**

---
## 🤖 Finally
* **Author**: Saeed Muhammed
* **System**: SuperWiFi Captive Portal Manager
* **Platform**: OpenWRT + OpenNDS + SQLite + Mobile App


