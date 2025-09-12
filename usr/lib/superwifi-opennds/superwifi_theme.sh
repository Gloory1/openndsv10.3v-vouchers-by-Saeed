#!/bin/sh
#Copyright (C) The openNDS Contributors 2004-2023
#Copyright (C) BlueWave Projects and Services 2015-2024
#Copyright (C) Francesco Servida 2023
#This software is released under the GNU GPL license.
#Edited by Saeed Muhammed

#-----------------------------------------------------------------------#
# init variables

# Including database lib
. /usr/lib/superwifi/superwifi_database_lib.sh

# Title of this theme:
title="Super wifi vouchers"
#-----------------------------------------------------------------------#

# functions:

generate_splash_sequence() {
    if [ -n "$voucher" ]; then
        login_with_voucher
    else
        voucher_form
    fi
}

header() {
    gatewayurl=$(printf "${gatewayurl//%/\\x}")
    echo "<!DOCTYPE html>
    <html>
    <head>
    <meta http-equiv=\"Cache-Control\" content=\"no-cache, no-store, must-revalidate\">
    <meta http-equiv=\"Pragma\" content=\"no-cache\">
    <meta http-equiv=\"Expires\" content=\"0\">
    <meta charset=\"utf-8\">
    <meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">
    <link rel=\"shortcut icon\" href=\"$gatewayurl""$imagepath\" type=\"image/x-icon\">
	<link rel=\"stylesheet\" type=\"text/css\" href=\"$gatewayurl/splash.css\">
    <title>$title</title>
    </head>
    <body>
    <div class=\"card\">
    <div class=\"logo-container floating\">
    <img class=\"logo\" src=\"$gatewayurl""$imagepath\" alt=\"Splash Page: For access to the Internet.\">
    </div>
    <h1>"${provider_name//%20/ }"</h1>
    <h2>أهلا وسهلا </h2>
    
 
"
}
# باقي الكود يفضل كما هو بدون تغيير...

block_message() {
    local remaining=\"$1\"

    echo "
    <div class=\"card\">
      <h3>🚫 تم الحظر مؤقتًا</h3>
      <div class=\"countdown\">
        الرجاء الانتظار <span id=\"time\">$remaining</span> ثانية
      </div>
      <form>
        <input type=\"button\" class=\"btn\" id=\"retryBtn\" value=\"أعد المحاولة\" onclick=\"location.reload();\">
      </form>
    </div>

    <script>
      let remaining = $remaining;
      const timeSpan = document.getElementById('time');
      const retryBtn = document.getElementById('retryBtn');

      const interval = setInterval(() => {
        remaining--;
        timeSpan.textContent = remaining;
        if (remaining <= 0) {
          clearInterval(interval);
          retryBtn.style.display = 'block';
          document.querySelector('.countdown').textContent = 'يمكنك المحاولة الآن';
        }
      }, 1000);
    </script>
"
}

try_again_btn() {
    echo "
	<div class='status error'>
            <p>$status_details</p>
	</div>
	<label>عدد المحاولات محدود</label>

        <form>
            <button type=\"button\" class=\"btn\" id=\"retryBtn\" onclick=\"handleRetryClick()\">
                <span class=\"spinner\" style=\"display: none;\"></span>
                <span class=\"btn-text\">إعادة المحاولة</span>
            </button>
        </form>

        <script>
        function handleRetryClick() {
            var button = document.getElementById('retryBtn');
            button.classList.add('btn-loading');
            button.disabled = true;
            button.style.cursor = 'not-allowed';
            button.style.opacity = '0.6';
            location.href = '$originurl';
        }
        </script>"
}

footer() {
    echo "
        <div class=\"footer\">
            <hr>
            <div>
                &copy; Saeed & BlueWave Projects and Services 2025
                <div>$clientmac</div>
            </div>
        </div>
    </div>
    </body>
    </html>
    "
    exit 0
}

login_with_voucher() {
    voucher_validation
    footer
}

track_attempts() {
    local success="$1"
    local now=$(date +%s)
    local client="$clientmac"
    local db="${logdir}attempts.txt"

    mkdir -p "$(dirname "$db")"
    touch "$db"

    if [ "$success" -eq 0 ]; then
        # Remove attempts log on success
        sed -i "/^${client},/d" "$db"
        return
    fi

    # Add/update failed attempt
    local count=0
    local ts=$now
    if grep -q "^${client}," "$db"; then
        # Get existing count and timestamp
        local line
        line=$(grep "^${client}," "$db" | head -n1)
        count=$(echo "$line" | cut -d, -f2)
        ts=$(echo "$line" | cut -d, -f3)
    fi

    count=$((count + 1))
    # Remove existing entry
    sed -i "/^${client},/d" "$db"
    # Add updated entry
    echo "$client,$count,$ts" >>"$db" # Keep original timestamp
}

check_attempts() {
    local now=$(date +%s)
    local client="$clientmac"
    local db="${logdir}attempts.txt"

    local max=3
    local window=300 # 5 minutes

    [ ! -f "$db" ] && echo 0 && return 0

    local count=0
    local ts=$now
    if grep -q "^${client}," "$db"; then
        # Get existing count and timestamp
        local line
        line=$(grep "^${client}," "$db" | head -n1)
        count=$(echo "$line" | cut -d, -f2)
        ts=$(echo "$line" | cut -d, -f3)
    fi

    local diff=$((now - ts))

    if [ "$diff" -gt "$window" ]; then
        sed -i "\|^${client},|d" "$db"
        echo 0
        return 0
    fi

    if [ "$count" -ge "$max" ]; then
        local remaining=$((window - diff))
        echo "$remaining"
        return 1
    fi

    echo 0
    return 0
}

calculate_remaining() {
    time_display="الوقت المتبقي"
    data_display="البيانات المتبقية"

    #-----------------------------------------------------
    # حساب الوقت المتبقي
    if [ "$voucher_time_limit" -eq 0 ]; then
        time_value="غير محدود"
    else
        time_value="${time_remaining} دقيقة"
    fi

    #-----------------------------------------------------
    # حساب البيانات المتبقية
    if [ "$voucher_quota_down" -eq 0 ]; then
        data_value="غير محدود"
    else
        remaining_mb=$((download_quota / 1024))
        if [ $remaining_mb -ge 1024 ]; then
            remaining_gb=$((remaining_mb / 1024))
            data_value="${remaining_gb} جيجابايت"
        else
            data_value="${remaining_mb} ميجابايت"
        fi
    fi

    #-----------------------------------------------------
    # عرض النتيجة
    echo "<br>${time_display}: ${time_value}<br>${data_display}: ${data_value}"
}

# SuperWiFi Voucher Management Script (Optimized)
check_voucher() {
    # Initialize status variable
    status_details=""

    # 1. Validate voucher format (exactly 9 alphanumeric or dash characters)
    if ! echo -n "$voucher" | grep -qE "^[a-zA-Z0-9-]{9}$"; then
        track_attempts 1
        status_details="كود الكارت يجب أن يكون 9 أحرف<br> (أحرف أو أرقام أو شرطات)"
        return 1
    fi

    # 2. Retrieve voucher from DB
    output=$(get_voucher "$voucher")
    if [ -z "$output" ]; then
        track_attempts 1
        status_details="كود الكارت غير صحيح أو غير موجود"
        return 1
    fi

    # Parse voucher fields from output
    current_time=$(date +%s)
    voucher_id=$(echo "$output" | cut -d'|' -f1)
    voucher_token=$(echo "$output" | cut -d'|' -f2)
    voucher_mac=$(echo "$output" | cut -d'|' -f3)
    voucher_time_limit=$(echo "$output" | cut -d'|' -f4)
    voucher_rate_down=$(echo "$output" | cut -d'|' -f5)
    voucher_rate_up=$(echo "$output" | cut -d'|' -f6)
    voucher_quota_down=$(echo "$output" | cut -d'|' -f7)
    voucher_quota_up=$(echo "$output" | cut -d'|' -f8)
    voucher_accum_down_total=$(echo "$output" | cut -d'|' -f9)
    voucher_accum_down_season=$(echo "$output" | cut -d'|' -f10)
    voucher_first_punched=$(echo "$output" | cut -d'|' -f11)
    voucher_last_punched=$(echo "$output" | cut -d'|' -f12)
    voucher_quota_expired=$(echo "$output" | cut -d'|' -f13)

    # 3. Check quota expiration flag
    if [ "$voucher_quota_expired" -ne 0 ]; then
        status_details="انتهت صلاحية الكارت<br>فشل الإتصال"
        return 1
    fi

    # 4. Check data usage
    if [ "$voucher_quota_down" -ne 0 ] &&
        [ "$voucher_accum_down_total" -ge "$voucher_quota_down" ]; then
        status_details="تم استهلاك بيانات الكارت بالكامل<br>لا توجد بيانات متبقية"
        return 1
    fi

    # 5. Check MAC binding
    if [ "$voucher_mac" != "0" ] && [ "$voucher_mac" != "$clientmac" ]; then
        status_details="هذا الكارت مرتبط بجهاز آخر<br>لا يمكن استخدامه من هذا الجهاز"
        return 1
    fi

    # 6. Check time validity
    if [ "$voucher_first_punched" -ne 0 ]; then
        voucher_expiration=$((voucher_first_punched + voucher_time_limit * 60))

        if [ "$voucher_time_limit" -ne 0 ] &&
            [ "$current_time" -ge "$voucher_expiration" ]; then
            status_details="انتهت صلاحية الكارت<br>الوقت انتهى"
            return 1
        fi
    fi
    #-------------------------------------------------------------------------
    # All validations passed - activate/renew voucher
    #-------------------------------------------------------------------------
    #
    # Set connection parameters
    #

    upload_rate=$voucher_rate_up
    download_rate=$voucher_rate_down
    upload_quota=$voucher_quota_up
    download_quota=$voucher_quota_down

    if [ "$voucher_quota_down" -ne 0 ]; then
        download_quota=$((voucher_quota_down - voucher_accum_down_total))
    fi


    if [ "$voucher_first_punched" -eq 0 ]; then
        # Set last punch
        update_first_punch "$voucher_token" "$clientmac"
        # First-time activation
        time_remaining=$voucher_time_limit
        sessiontimeout=$voucher_time_limit
        status_details="تم تفعيل الكارت بنجاح! $(calculate_remaining)"
    else
        # Update last punch
        update_last_punch "$voucher_token"
        # Session renewal
        voucher_expiration=$((voucher_first_punched + voucher_time_limit * 60))
        time_remaining=$(((voucher_expiration - current_time) / 60))
        [ "$time_remaining" -lt 0 ] && time_remaining=0
        sessiontimeout=$time_remaining
        status_details="تم تجديد الجلسة! $(calculate_remaining)"
    fi

    return 0
}

voucher_validation() {
    originurl=$(printf "${originurl//%/\\x}")

    check_voucher
    if [ $? -eq 0 ]; then
        quotas="$sessiontimeout $upload_rate $download_rate $upload_quota $download_quota"
        userinfo="Saeed - $voucher"
        binauth_custom="$voucher"
        encode_custom
        auth_log

        if [ "$ndsstatus" = "authenticated" ]; then
            track_attempts 0
            echo "<div class='status success'>
		                <p>$status_details</p>
		            </div>
		            <form>
		                <input type=\"button\" class=\"btn\" value=\"متابعة\" onClick=\"location.href='$originurl'\">
		            </form>"
        else

            status_details="تم رض المصادقة"
            try_again_btn
        fi
    else
        try_again_btn
    fi
    footer
}

voucher_form() {

    block_remaining=$(check_attempts)

    if [ "$block_remaining" -gt 0 ]; then
        # Blocked case: show block message with remaining time
        block_message "$block_remaining"
    else
        voucher_code=$(echo "$cpi_query" | awk -F "voucher%3d" '{printf "%s", $2}' | awk -F "%26" '{printf "%s", $1}')

        echo "

        <div class=\"info\">
            <h3>بمجرد تفعيل الكارت<br> لن يعمل على أي جهاز آخر</h3>
            </div>
   
        <form action=\"/opennds_preauth/\" method=\"get\" onsubmit=\"return handleVoucherSubmit(this)\">
            <input type=\"hidden\" name=\"fas\" value=\"$fas\"> 
            
            <div class=\"form-group\">
                <input type=\"text\" id=\"voucher\" name=\"voucher\" value=\"$voucher_code\" placeholder=\"اكتب هنا\" required>
            </div>
            
            <button type=\"submit\" class=\"btn\" id=\"voucherBtn\">
                <span class=\"spinner\" style=\"display: none;\"></span>
                <span class=\"btn-text\">تحقق من الرقم</span>
            </button>
        </form>

        <script>
        function handleVoucherSubmit(form) {
            var button = document.getElementById('voucherBtn');
            button.classList.add('btn-loading');
            button.disabled = true;
            button.style.cursor = 'not-allowed';
            button.style.opacity = '0.6';
            return true;
        }
        </script>
      
    "
    fi
    footer
}

#### end of functions ####
#################################################
#						#
#  Start - Main entry point for this Theme	#
#						#
#  Parameters set here overide those		#
#  set in libopennds.sh			#
#						#
#################################################

# Quotas and Data Rates
#########################################
# Set length of session in minutes (eg 24 hours is 1440 minutes - if set to 0 then defaults to global sessiontimeout value):
# eg for 100 mins:
# sessiontimeout="100"
#
# eg for 20 hours:
# sessiontimeout=$((20*60))
#
# eg for 20 hours and 30 minutes:
# sessiontimeout=$((20*60+30))
sessiontimeout="0"

# Set Rate and Quota values for the client
# The session length, rate and quota values could be determined by this script, on a per client basis.
# rates are in kb/s, quotas are in kB. - if set to 0 then defaults to global value).
upload_rate="0"
download_rate="0"
upload_quota="0"
download_quota="0"

quotas="$sessiontimeout $upload_rate $download_rate $upload_quota $download_quota"

# Define the list of Parameters we expect to be sent sent from openNDS ($ndsparamlist):
# Note you can add custom parameters to the config file and to read them you must also add them here.
# Custom parameters are "Portal" information and are the same for all clients eg "admin_email" and "location"
ndscustomparams=""
ndscustomimages=""
ndscustomfiles=""

ndsparamlist="$ndsparamlist $ndscustomparams $ndscustomimages $ndscustomfiles"

# The list of FAS Variables used in the Login Dialogue generated by this script is $fasvarlist and defined in libopennds.sh
#
# Additional custom FAS variables defined in this theme should be added to $fasvarlist here.
additionalthemevars="tos voucher"

fasvarlist="$fasvarlist $additionalthemevars"

# You can choose to define a custom string. This will be b64 encoded and sent to openNDS.
# There it will be made available to be displayed in the output of ndsctl json as well as being sent
#	to the BinAuth post authentication processing script if enabled.

# Set the variable $binauth_custom to the desired value.
# Values set here can be overridden by the themespec file
# binauth_custom="voucher=$voucher_token"

# Encode and activate the custom string
# encode_custom

# Set the user info string for logs (this can contain any useful information)
#userinfo="$voucher_token"

##############################################################################################################################
# Customise the Logfile location.
##############################################################################################################################
#Note: the default uses the tmpfs "temporary" directory to prevent flash wear.
# Override the defaults to a custom location eg a mounted USB stick.
#mountpoint="/mylogdrivemountpoint"
#logdir="$mountpoint/ndslog/"
#logname="ndslog.log"
