#!/bin/sh
#Copyright (C) The openNDS Contributors 2004-2023
#Copyright (C) BlueWave Projects and Services 2015-2024
#Edited by Saeed Muhammed

#-----------------------------------------------------------------------#
# 1. Localization & Messages (Arabic)
#-----------------------------------------------------------------------#
MSG_WELCOME="أهلا وسهلا"
MSG_CHECK_BTN="تحقق من الرقم"
MSG_RETRY_BTN="إعادة المحاولة"
MSG_CONTINUE_BTN="متابعة"
MSG_PLACEHOLDER="اكتب الكود هنا"
MSG_COPYRIGHT="&copy; Saeed & BlueWave Projects and Services 2025"
MSG_INSERT_TITLE="بمجرد تفعيل الكارت<br> لن يعمل على أي جهاز آخر"
MSG_RESTORE_LINK="تابع آخر استخدام"

# Error Messages
MSG_INVALID_FORMAT="يجب أن يتكون الكارت على الأقل من <br> (ستة أحرف أو أرقام)"
MSG_NOT_FOUND="الكارت غير صحيح أو غير موجود"
MSG_VALIDITY_EXPIRED="انتهت صلاحية الكارت<br>فشل الإتصال"
MSG_QUOTA_EXHAUSTED="تم استهلاك بيانات الكارت بالكامل<br>لا توجد بيانات متبقية"
MSG_TIME_EXPIRED="انتهت صلاحية الكارت<br>الوقت انتهى"
MSG_MAC_BOUND="هذا الكارت مرتبط بجهاز آخر<br>لا يمكن استخدامه من هذا الجهاز"
MSG_SUCCESS_BUT_RETRY="الكارت صحيح ولكن....<br> رجاءا حاول مجددا."
MSG_ATTEMPTS_LIMITED="عدد المحاولات محدود"

#-----------------------------------------------------------------------#
# 2. Init variables
#-----------------------------------------------------------------------#
. /usr/lib/superwifi/superwifi_database_manager.sh
title="Super wifi vouchers"

# -----------------------------------------------------
# THE LOGIC CONTROLLER (Smart Auth)
# -----------------------------------------------------
IS_FIRST_CHECK_DONE=0
auto_auth_token=''
auto_auth_method=''

generate_splash_sequence() {
    # 1. Extract voucher from URL (Just to have it ready)
    if [ -z "$voucher" ]; then
        voucher=$(echo "$cpi_query" | awk -F "voucher%3d" '{printf "%s", $2}' | awk -F "%26" '{printf "%s", $1}')
    fi

    # 2. PRIORITY #1: Smart Fetch & DB Logic
    # We check DB status first as requested.
    if [ "$IS_FIRST_CHECK_DONE" -eq 0 ]; then
        IS_FIRST_CHECK_DONE=1
        
        local db_result=$(get_voucher_auth_method "$clientmac")
        auto_auth_token=$(echo "$db_result" | awk -F "|" '{print $1}')
        auto_auth_method=$(echo "$db_result" | awk -F "|" '{print $2}')
    fi

    # 3. Execute DB Logic (If data exists)
    if [ -n "$auto_auth_token" ]; then
        case "$auto_auth_method" in
            2)
                # --- [ Auto Login with Silent Check ] ---
                # Save manual voucher temporarily
                local manual_voucher="$voucher"
                
                # Set voucher to token for checking
                voucher="$auto_auth_token"
                
                # Silent Check (Redirect output to null)
                check_voucher > /dev/null 2>&1
                
                if [ $? -eq 0 ]; then
                    # Valid -> Login immediately (Priority over manual)
                    login_with_voucher
                    return
                else
                    # Expired -> Fallback
                    # Restore the manual voucher input (if any)
                    voucher="$manual_voucher"
                    
                    # If user typed a code manually, let it pass to next check
                    # If not, show the Restore Form to break the loop
                    if [ -z "$voucher" ]; then
                        voucher_form "$auto_auth_token"
                        return
                    fi
                fi
                ;;
                
            1)
                # Restore Mode
                # If manual code is present, skip to Priority #2
                if [ -z "$voucher" ]; then
                    voucher_form "$auto_auth_token"
                    return
                fi
                ;;
        esac
    fi

    # 4. PRIORITY #2: Manual Input Check
    if [ -n "$voucher" ]; then
        login_with_voucher
        return
    fi

    # 5. Default: Show Form
    voucher_form
}


#-----------------------------------------------------------------------#
# Functions (Views)
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
}

check_voucher() {
    status_details=""

    # Validation logic
    if ! echo -n "$voucher" | grep -qE "^[a-zA-Z0-9-]{1,12}$"; then
        status_details="$MSG_INVALID_FORMAT"
        return 1
    fi

    output=$(get_auth_voucher "$voucher")
    if [ -z "$output" ]; then
        status_details="$MSG_NOT_FOUND"
        return 1
    fi

    # Parsing Logic
    voucher_token=$(echo "$output" | cut -d'|' -f1)
    voucher_user_mac=$(echo "$output" | cut -d'|' -f2)
    voucher_expiration_status=$(echo "$output" | cut -d'|' -f3)
    voucher_rate_down=$(echo "$output" | cut -d'|' -f4)
    voucher_rate_up=$(echo "$output" | cut -d'|' -f5)
    voucher_time_remaining_min=$(echo "$output" | cut -d'|' -f6)
    voucher_quota_remaining_kb=$(echo "$output" | cut -d'|' -f7)
    voucher_remaining_message_html=$(echo "$output" | cut -d'|' -f8)

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

    # Success Setup
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
            update_punch "$voucher_token" "$clientmac"
            echo "<div class='status success'>
                    <p>$voucher_token</p> 
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
            <p>$voucher_token</p>
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
    # 1. Get restore code (if passed as argument)
    local restore_code="$1"

    # 2. Get voucher info from query for display only
    local display_voucher=$(echo "$cpi_query" | awk -F "voucher%3d" '{printf "%s", $2}' | awk -F "%26" '{printf "%s", $1}')

    echo "<div class=\"insert\">
        <h3>$MSG_INSERT_TITLE</h3>"

    # Show restore link if restore_code is available
    if [ -n "$restore_code" ]; then
        echo "
        <h3 class=\"restore-link\" onclick=\"useLastVoucher('$restore_code')\">
            $MSG_RESTORE_LINK
        </h3>
        "
    fi
    
    echo "</div>"
   
    echo "<form id=\"loginForm\" action=\"/opennds_preauth/\" method=\"get\" onsubmit=\"return handleVoucherSubmit()\">
        <input type=\"hidden\" name=\"fas\" value=\"$fas\"> 
        
        <input type=\"text\" id=\"voucher\" name=\"voucher\" value=\"$display_voucher\" placeholder=\"$MSG_PLACEHOLDER\" required>
        
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
    footer
}

#################################################
#### end of functions ####
#################################################

# Quotas and Data Rates
sessiontimeout="0"
upload_rate="0"
download_rate="0"
upload_quota="0"
download_quota="0"

quotas="$sessiontimeout $upload_rate $download_rate $upload_quota $download_quota"

# Define the list of Parameters
ndscustomparams=""
ndscustomimages=""
ndscustomfiles=""

ndsparamlist="$ndsparamlist $ndscustomparams $ndscustomimages $ndscustomfiles"

# The list of FAS Variables
additionalthemevars="tos voucher"
fasvarlist="$fasvarlist $additionalthemevars"
