#!/bin/sh
#Copyright (C) The openNDS Contributors 2004-2023
#Copyright (C) BlueWave Projects and Services 2015-2024
#Copyright (C) Francesco Servida 2023
#This software is released under the GNU GPL license.
#Edited by Saeed Muhammed

#-----------------------------------------------------------------------#
# init variables

# Including database lib
. /usr/lib/superwifi/superwifi_database_manager.sh

# Title of this theme:
title="Super wifi vouchers"
voucher=$(get_last_voucher_for_mac "$clientmac")
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

main_voucher_input() {
    # استخراج الكود من الرابط إذا كان موجوداً
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
}


restore_session_button() {
    echo "
        <div style='text-align:center; margin: 15px 0; font-size: 14px; color: #666;'>- أو -</div>
        
        <form action=\"/opennds_preauth/\" method=\"get\" onsubmit=\"return handleRestoreSubmit(this)\">
            <input type=\"hidden\" name=\"fas\" value=\"$fas\"> 
            <input type=\"hidden\" name=\"restore_session\" value=\"true\">
            
            <button type=\"submit\" class=\"btn\" id=\"restoreBtn\" style=\"background-color: #2196F3; margin-top: 0;\">
                <span class=\"spinner\" style=\"display: none;\"></span>
                <span class=\"btn-text\">🔄 تابع آخر استخدام</span>
            </button>
        </form>

        <script>
        function handleRestoreSubmit(form) {
            var button = document.getElementById('restoreBtn');
            button.classList.add('btn-loading');
            button.disabled = true;
            button.style.cursor = 'not-allowed';
            button.style.opacity = '0.6';
            
            var spinner = button.querySelector('.spinner');
            if(spinner) spinner.style.display = 'inline-block';
            
            return true;
        }
        </script>
    "
}


try_again_btn() {
	local status_details_msg="$1"
    echo "
	<div class='status error'>
            <p>$status_details_msg</p>
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


# SuperWiFi Voucher Management Script (Optimized)
check_voucher() {
	# local scope so messages/vars don't pollute global environment
	local MSG_INVALID_FORMAT="يجب أن يتكون الكارت على الأقل من <br> (ستة أحرف أو أرقام)"
	local MSG_NOT_FOUND="الكارت غير صحيح أو غير موجود"
	local MSG_INVALID_TOKEN="انتهت صلاحية الكارت<br>فشل الإتصال"
	local MSG_QUOTA_EXHAUSTED="تم استهلاك بيانات الكارت بالكامل<br>لا توجد بيانات متبقية"
	local MSG_TIME_EXPIRED="انتهت صلاحية الكارت<br>الوقت انتهى"
	local MSG_MAC_BOUND="هذا الكارت مرتبط بجهاز آخر<br>لا يمكن استخدامه من هذا الجهاز"
	local MSG_VALIDITY_EXPIRED="انتهت صلاحية الكارت<br>فشل الإتصال"
	local MSG_ACTIVATED="تم تفعيل الكارت بنجاح!"

	status_details=""

	# 1. Validate voucher format
	if ! echo -n "$voucher" | grep -qE "^[a-zA-Z0-9-]{1,12}$"; then
		status_details="$MSG_INVALID_FORMAT"
		return 1
	fi

	# 2. Retrieve voucher details
	output=$(get_auth_voucher "$voucher")
	if [ -z "$output" ]; then
		status_details="$MSG_NOT_FOUND"
		return 1
	fi

	# Parse fields produced by your VIEW (SQLite query)
	#   token, Text
	#   user_mac, Text
	#   expiration_status Int
	#   rate_down, Int
	#   rate_up, Int
	#   time_remaining_min, Int 
	#   quota_remaining_kb, Int 
	#   remaining_message_html, Text 

	# Parse fields (must match order of SELECT in the VIEW)
	voucher_token=$(echo "$output" | cut -d'|' -f1)
	voucher_user_mac=$(echo "$output" | cut -d'|' -f2)
	voucher_expiration_status=$(echo "$output" | cut -d'|' -f3)
	voucher_rate_down=$(echo "$output" | cut -d'|' -f4)
	voucher_rate_up=$(echo "$output" | cut -d'|' -f5)
	voucher_time_remaining_min=$(echo "$output" | cut -d'|' -f6)
	voucher_quota_remaining_kb=$(echo "$output" | cut -d'|' -f7)
	voucher_remaining_message_html=$(echo "$output" | cut -d'|' -f8)

	# 3. Check validity flag
	if [ "$voucher_expiration_status" -eq 1 ]; then
		status_details="$MSG_VALIDITY_EXPIRED"
		return 1
	fi

	# 4. Check quota
	if [ "$voucher_quota_remaining_kb" -eq -1 ]; then
		status_details="$MSG_QUOTA_EXHAUSTED"
		return 1
	fi

	# 5. Check time validity
	if [ "$voucher_time_remaining_min" -eq -1 ]; then
		status_details="$MSG_TIME_EXPIRED"
		return 1
	fi

	# 6. Check MAC binding
	if [ "$voucher_user_mac" != "0" ] && [ "$voucher_user_mac" != "$clientmac" ]; then
		status_details="$MSG_MAC_BOUND"
		return 1
	fi

	# 7. All validations passed -> Activate/Renew
	upload_rate=$voucher_rate_up
	download_rate=$voucher_rate_down

	upload_quota=$voucher_quota_remaining_kb
	download_quota=$voucher_quota_remaining_kb

	sessiontimeout=$voucher_time_remaining_min
	# Set success message
	status_details="$voucher_remaining_message_html"
	# Update punches
	update_punch "$voucher_token" "$clientmac"

	return 0
}


voucher_validation() {
    originurl=$(printf "${originurl//%/\\x}")

    check_voucher
    if [ $? -eq 0 ]; then

        quotas="$sessiontimeout $upload_rate $download_rate $upload_quota $download_quota"
        userinfo="SuperWifi"
        binauth_custom="$voucher"
        encode_custom
        auth_log

        if [ "$ndsstatus" = "authenticated" ]; then
            echo "<div class='status success'>
		                <p>$voucher_remaining_message_html</p> 
		            </div>
		            <form>
		                <input type=\"button\" class=\"btn\" value=\"متابعة\" onClick=\"location.href='$originurl'\">
		            </form>"
        else
			status_details="الكارت صحيح ولكن....<br> رجاءا حاول مجددا."
            try_again_btn "$status_details"
        fi
    else
        try_again_btn "$status_details"
    fi
    footer
}

voucher_form() {
    main_voucher_input
    restore_session_button
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
