#!/bin/sh
#Copyright (C) The openNDS Contributors 2004-2023
#Copyright (C) BlueWave Projects and Services 2015-2024
#Edited by Saeed Muhammed

#-----------------------------------------------------------------------#
# 1. Init variables & Includes
#-----------------------------------------------------------------------#
title="Super wifi vouchers"
. /usr/lib/superwifi/superwifi_database_manager.sh

#-----------------------------------------------------------------------#
# 2. Localization & Messages 
#-----------------------------------------------------------------------#
MSG_WELCOME="أهلا وسهلا"
MSG_CHECK_BTN="تحقق من الرقم"
MSG_RETRY_BTN="إعادة المحاولة"
MSG_CONTINUE_BTN="متابعة"
MSG_PLACEHOLDER="اكتب الكود هنا"
MSG_COPYRIGHT="&copy; Saeed & BlueWave Projects and Services 2025"

# Voucher status messages
MSG_INSERT_TITLE="بمجرد تفعيل الكارت<br> لن يعمل على أي جهاز آخر"
MSG_RESTORE_LINK="تابع آخر استخدام"
MSG_INVALID_FORMAT="يجب أن يتكون الكارت على الأقل من <br> (ستة أحرف أو أرقام)"
MSG_NOT_FOUND="الكارت غير صحيح أو غير موجود"
MSG_VALIDITY_EXPIRED="انتهت صلاحية الكارت<br>فشل الإتصال"
MSG_QUOTA_EXHAUSTED="تم استهلاك بيانات الكارت بالكامل<br>لا توجد بيانات متبقية"
MSG_TIME_EXPIRED="انتهت صلاحية الكارت<br>الوقت انتهى"
MSG_MAC_BOUND="هذا الكارت مرتبط بجهاز آخر<br>لا يمكن استخدامه من هذا الجهاز"
MSG_SUCCESS_BUT_RETRY="الكارت صحيح ولكن....<br> رجاءا حاول مجددا."
MSG_ATTEMPTS_LIMITED="عدد المحاولات محدود"

#-----------------------------------------------------------------------#
# 3. Logic & Decision Functions
#-----------------------------------------------------------------------#

check_preauth_status() {
    local mac="$1"
    
    # 1. جلب البيانات (الكود + الطريقة)
    local db_result=$(get_voucher_auth_method "$mac")

    # لو مفيش نتيجة، يبقى مستخدم جديد
    if [ -z "$db_result" ]; then
        echo "NEW_USER"
        return
    fi

    local code=$(echo "$db_result" | awk -F "|" '{print $1}')
    local method=$(echo "$db_result" | awk -F "|" '{print $2}')

    # 2. التوجيه المباشر بدون فحص صلاحية
    case $method in
        0) 
            echo "MANUAL_ONLY" 
            ;;
        1) 
            echo "SHOW_RESTORE|$code" 
            ;;
        2) 
            # الوضع التلقائي:
            # هنرجع أمر الدخول فوراً، والتحقق هيتم لاحقاً في دالة login_with_voucher
            echo "AUTO_LOGIN|$code"
            ;;
        *) 
            echo "NEW_USER" 
            ;;
    esac
}

generate_splash_sequence() {
    # 1. الأولوية للكود المكتوب يدوياً في الرابط
    if [ -n "$voucher" ]; then
        login_with_voucher
        return
    fi

    # 2. اسأل دالة المنطق (Smart Auth)
    local decision_string=$(check_preauth_status)
    local action=$(echo "$decision_string" | awk -F "|" '{print $1}')
    local saved_code=$(echo "$decision_string" | awk -F "|" '{print $2}')

    # 3. تنفيذ القرار
    case "$action" in
        AUTO_LOGIN)
            voucher="$saved_code"
            login_with_voucher
            ;;  
        SHOW_RESTORE)
            # مرر الكود للدالة عشان ترسم زر الاستعادة
            voucher_form "$saved_code"
            ;;   
        *)
            # (NEW_USER or MANUAL_ONLY) - فورم فاضي
            voucher_form ""
            ;;
    esac
}

#-----------------------------------------------------------------------#
# 4. View & HTML Functions
#-----------------------------------------------------------------------#

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
    <div class=\"offset\">
        <div class=\"arabic-style\">
            <div class=\"logo-container floating\">
                <img class=\"logo\" src=\"$gatewayurl""$imagepath\" alt=\"Splash Page\">
            </div>
            <h1>"${provider_name//%20/ }"</h1>
            <h2>$MSG_WELCOME</h2>
        </div>"
}

footer() {
    echo "
        <div class=\"footer\">
            <hr>
            <div>
                <copy-right>$MSG_COPYRIGHT</copy-right>
                <div style='font-size: 0.8rem; opacity: 0.7;'>$clientmac</div>
            </div>
        </div>
    </div>
    </body>
    </html>"
    exit 0
}

login_with_voucher() {
    voucher_validation
    footer
}

check_voucher() {
    status_details=""

    # 1. Format Validation
    if ! echo -n "$voucher" | grep -qE "^[a-zA-Z0-9-]{1,12}$"; then
        status_details="$MSG_INVALID_FORMAT"
        return 1
    fi

    # 2. Database Lookup
    output=$(get_auth_voucher "$voucher")
    if [ -z "$output" ]; then
        status_details="$MSG_NOT_FOUND"
        return 1
    fi

    # 3. Parse Data
    voucher_token=$(echo "$output" | cut -d'|' -f1)
    voucher_user_mac=$(echo "$output" | cut -d'|' -f2)
    voucher_expiration_status=$(echo "$output" | cut -d'|' -f3)
    voucher_rate_down=$(echo "$output" | cut -d'|' -f4)
    voucher_rate_up=$(echo "$output" | cut -d'|' -f5)
    voucher_time_remaining_min=$(echo "$output" | cut -d'|' -f6)
    voucher_quota_remaining_kb=$(echo "$output" | cut -d'|' -f7)
    voucher_remaining_message_html=$(echo "$output" | cut -d'|' -f8)

    # 4. Status Checks
    if [ "$voucher_expiration_status" -eq 1 ]; then
        status_details="$MSG_VALIDITY_EXPIRED"
        return 1
    fi

    if [ "$voucher_quota_remaining_kb" -eq -1 ]; then
        status_details="$MSG_QUOTA_EXHAUSTED"
        return 1
    fi

    if [ "$voucher_time_remaining_min" -eq -1 ]; then
        status_details="$MSG_TIME_EXPIRED"
        return 1
    fi

    if [ "$voucher_user_mac" != "0" ] && [ "$voucher_user_mac" != "$clientmac" ]; then
        status_details="$MSG_MAC_BOUND"
        return 1
    fi

    # 5. Success Setup
    upload_rate=$voucher_rate_up
    download_rate=$voucher_rate_down
    upload_quota=$voucher_quota_remaining_kb
    download_quota=$voucher_quota_remaining_kb
    sessiontimeout=$voucher_time_remaining_min
    status_details="$voucher_remaining_message_html"
    
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
                    <input type=\"button\" class=\"btn\" value=\"$MSG_CONTINUE_BTN\" onClick=\"location.href='$originurl'\">
                  </form>"
        else
            status_details="$MSG_SUCCESS_BUT_RETRY"
            try_again_btn "$status_details"
        fi
    else
        try_again_btn "$status_details"
    fi
    footer
}

try_again_btn() {
    local status_details_msg="$1"
    echo "
        <div class='status error'>
            <p>$status_details_msg</p>
        </div>
        <label style='color: white;'>$MSG_ATTEMPTS_LIMITED</label>

        <form>
            <button type=\"button\" class=\"btn\" id=\"retryBtn\" onclick=\"handleRetryClick()\">
                <span class=\"spinner\" style=\"display: none;\"></span>
                <span class=\"btn-text\">$MSG_RETRY_BTN</span>
            </button>
        </form>

        <script>
        function handleRetryClick() {
            var button = document.getElementById('retryBtn');
            button.classList.add('btn-loading');
            button.disabled = true;
            button.style.opacity = '0.6';
            location.href = '$originurl';
        }
        </script>"
}

voucher_form() {
    # استقبال كود الاستعادة (إن وجد) من المتغير الأول
    local restore_code="$1"
    
    # 1. Get info from query (for new inputs)
    voucher_code=$(echo "$cpi_query" | awk -F "voucher%3d" '{printf "%s", $2}' | awk -F "%26" '{printf "%s", $1}')
    
    # Header logic is handled before calling this, usually by binauth script, 
    # but here we rely on standard sequence. Need to ensure header() is called if needed.
    # Note: In openNDS theme specs, header is usually called by the main loop. 
    # We will assume header() was called at start of execution or we call it here.
    header

    echo "<div class=\"insert\">
        <h3>$MSG_INSERT_TITLE</h3>"

    # زر الاستعادة يظهر فقط لو تم تمرير كود للدالة
    if [ -n "$restore_code" ]; then
        echo "
        <h3 class=\"restore-link\" onclick=\"useLastVoucher('$restore_code')\">
            $MSG_RESTORE_LINK
        </h3>"
    fi
    
    echo "</div>"

    echo "<form id=\"loginForm\" action=\"/opennds_preauth/\" method=\"get\" onsubmit=\"return handleVoucherSubmit()\">
        <input type=\"hidden\" name=\"fas\" value=\"$fas\"> 
        
        <input type=\"text\" id=\"voucher\" name=\"voucher\" value=\"$voucher_code\" placeholder=\"$MSG_PLACEHOLDER\" required>
        
        <button type=\"submit\" class=\"btn\" id=\"voucherBtn\">
            <span class=\"spinner\" style=\"display: none;\"></span>
            <span class=\"btn-text\">$MSG_CHECK_BTN</span>
        </button>
    </form>"

    echo "
    <script>
    function handleVoucherSubmit() {
        var button = document.getElementById('voucherBtn');
        button.classList.add('btn-loading');
        button.disabled = true;
        button.style.cursor = 'not-allowed';
        button.style.opacity = '0.6';
        return true;
    }

    function useLastVoucher(code) {
        console.log('Restoring voucher: ' + code);
        var input = document.getElementById('voucher');
        if (input) {
            input.value = code;
            var btn = document.getElementById('voucherBtn');
            if (btn) btn.click();
        }
    }
    </script>
    "
    # Footer is called at the end of function in previous code, 
    # but good practice is to return and let main loop handle it, 
    # or keep it as is.
    footer
}

#################################################
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
