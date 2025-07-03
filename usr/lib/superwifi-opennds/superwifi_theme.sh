#!/bin/sh
#Copyright (C) The openNDS Contributors 2004-2023
#Copyright (C) BlueWave Projects and Services 2015-2024
#Copyright (C) Francesco Servida 2023
#This software is released under the GNU GPL license.
#Edited by Saeed Muhammed


#-----------------------------------------------------------------------#
#
# init variables 
#

# Including database lib
. /usr/lib/superwifi-opennds/superwifi_database_lib.sh


# Title of this theme:
title="Super wifi vouchers"

# by enable this maybe it causes problems with accum tracking 
multiple_devices="0"

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
    <title>$gatewayname</title>
    <style>
    @import url('https://fonts.googleapis.com/css2?family=Cairo:wght@400;600;700&display=swap');

    * {
        margin: 0;
        padding: 0;
        box-sizing: border-box;
        font-family: 'Cairo', sans-serif;
    }

    body {
        background: linear-gradient(135deg, #ff9a9e, #fad0c4, #fbc2eb, #a6c1ee);
        background-size: 400% 400%;
        animation: gradientBG 1s ease infinite;
        color: #fff;
        min-height: 100vh;
        display: flex;
        justify-content: center;
        align-items: center;
        padding: 10px;
        text-align: center;
    }

    @keyframes gradientBG {
        0% {
            background-position: 0% 50%;
        }

        50% {
            background-position: 100% 50%;
        }

        100% {
            background-position: 0% 50%;
        }
    }

    .card {
        background: rgba(255, 255, 255, 0.4);
        border-radius: 25px;
        box-shadow: 0 20px 50px rgba(0, 0, 0, 0.15);
        width: 100%;
        max-width: 500px;
        padding: 35px 30px;
        position: relative;
        overflow: hidden;
        backdrop-filter: blur(8px);
        border: 1px solid rgba(255, 255, 255, 0.3);
    }

    .card:before {
        content: '';
        position: absolute;
        top: -50%;
        left: -50%;
        width: 200%;
        height: 200%;
        background: radial-gradient(circle, rgba(255, 255, 255, 0.4) 0%, transparent 70%);
        transform: rotate(30deg);
        z-index: 0;
        animation: rotateGradient 20s linear infinite;
    }


    .logo-container {
        position: relative;
        z-index: 2;
        margin-bottom: 15px;
    }

    .logo {
        width: 110px;
        height: 110px;
        margin: 0 auto;
        border-radius: 50%;
        object-fit: cover;
        border: 3px solid white;
        box-shadow: 0 5px 15px rgba(0, 0, 0, 0.08);
        transition: all 0.5s ease;
    }

    .logo:hover {
        transform: scale(1.05) rotate(5deg);
    }

    h1 {
        font-size: 2.8rem;
        margin: 10px 0 5px;
        background: linear-gradient(45deg, #ff6b6b, #ff8e53, #ffcc00);
        -webkit-background-clip: text;
        -webkit-text-fill-color: transparent;
        position: relative;
        z-index: 2;
        text-shadow: 0 2px 8px rgba(255, 107, 107, 0.15);
        letter-spacing: -1px;
    }

    h2 {
        font-size: 1.5rem;
        margin-bottom: 25px;
        font-weight: 600;
        color: #49B800;
        position: relative;
        z-index: 2;
        text-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
    }

    h3 {
        font-size: 1.4rem;
        margin-bottom: 25px;
        font-weight: 600;
        color: #5a2a0c;
        position: relative;
        z-index: 2;
    }

    .info {
        background: rgba(255, 255, 255, 0.75);
        padding: 15px;
        border-radius: 12px;
        margin: 20px 0;
        text-align: center;
        position: relative;
        z-index: 2;
        backdrop-filter: blur(5px);
        border: 1.5px solid #ffd8cb;
    }

    .info p {
        margin: 8px 0;
        line-height: 1.6;
        color: #5a2a0c;
        font-weight: 500;
    }

    .form-group {
        margin-bottom: 15px;
        text-align: center;
        position: relative;
        z-index: 2;
    }

    label {
        display: block;
        margin-top: 15px;
        margin-bottom: 10px;
        font-weight: 700;
        color: #e67e22;
        font-size: 1.1rem;
        position: relative;
        z-index: 2;
    }

    input[type='text'] {
        width: 100%;
        padding: 15px 20px;
        border: none;
        border-radius: 12px;
        background: rgba(255, 255, 255, 0.95);
        font-size: 1.4rem;
        font-weight: 700;
        text-align: center;
        box-shadow: 0 5px 15px rgba(0, 0, 0, 0.08);
        color: #5a2a0c;
        border: 2px solid #ffd8cb;
        transition: all 0.3s ease;
        position: relative;
        z-index: 2;

    }

    input[type='text']:focus {
        outline: none;
        border-color: #ff6b6b;
        box-shadow: 0 5px 20px rgba(255, 107, 107, 0.2);
    }

    .btn {
        background: linear-gradient(45deg, #ff6b6b, #ff8e53);
        color: white;
        border: none;
        padding: 18px;
        font-size: 1.2rem;
        border-radius: 12px;
        cursor: pointer;
        width: 100%;
        font-weight: 700;
        transition: all 0.3s ease;
        box-shadow: 0 7px 20px rgba(255, 107, 107, 0.3);
        margin-top: 5px;
        position: relative;
        z-index: 2;
        overflow: hidden;
    }

    .btn:before {
        content: '';
        position: absolute;
        top: 0;
        left: -100%;
        width: 100%;
        height: 100%;
        background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.3), transparent);
        transition: 0.5s;
    }

    .btn:hover {
        transform: translateY(-5px);
        box-shadow: 0 10px 25px rgba(255, 107, 107, 0.4);
        animation: pulse 3s infinite;
    }

    @keyframes pulse {
        0% {
            transform: translateY(-5px) scale(1);
            box-shadow: 0 10px 25px rgba(255, 107, 107, 0.4);
        }

        50% {
            transform: translateY(-5px) scale(1.02);
            box-shadow: 0 15px 30px rgba(255, 107, 107, 0.6);
        }

        100% {
            transform: translateY(-5px) scale(1);
            box-shadow: 0 10px 25px rgba(255, 107, 107, 0.4);
        }
    }

    .status {
        padding: 20px;
        border-radius: 12px;
        margin: 20px 0;
        font-size: 1.1rem;
        position: relative;
        z-index: 2;
        backdrop-filter: blur(5px);
    }

    .success {
        background: rgba(46, 204, 113, 0.7);
        border-left: 5px solid #27ae60;
        color: white;
    }

    .error {
        background: rgba(231, 76, 60, 0.7);
        border-left: 5px solid #c0392b;
        color: white;
    }

    .terms-notice {
        background: rgba(255, 255, 255, 0.75);
        padding: 12px;
        border-radius: 8px;
        margin: 15px 0;
        font-size: 0.9rem;
        text-align: center;
        position: relative;
        z-index: 2;
        backdrop-filter: blur(3px);
        color: #5a2a0c;
        border: 1px solid rgba(230, 126, 34, 0.2);
    }

    .terms-notice a {
        color: #e67e22;
        font-weight: 700;
        text-decoration: none;
    }

    .footer {
        margin-top: 20px;
        font-size: 0.85rem;
        color: #e67e22;
        position: relative;
        z-index: 2;
        font-weight: 600;
    }

    hr {
        border: 0;
        height: 2px;
        background: linear-gradient(to right, transparent, #ffd8cb, transparent);
        margin: 20px 0;
    }

    .countdown {
        font-size: 1.6rem;
        color: #ff6b6b;
        margin: 20px 0;
        position: relative;
        z-index: 2;
        font-weight: 700;
    }

    .floating {
        animation: float 3s ease-in-out infinite;
    }

    @keyframes float {
        0% {
            transform: translateY(0px);
        }

        50% {
            transform: translateY(-10px);
        }

        100% {
            transform: translateY(0px);
        }
    }
    </style>
    </head>
    <body>
    <div class=\"card\">
    <div class=\"logo-container floating\">
    <img class=\"logo\" src=\"$gatewayurl""$imagepath\" alt=\"Splash Page: For access to the Internet.\">
    </div>
    <h1>سوبر وايفاي</h1>
    <h2>🤍 أهلا وسهلا بكم في عالمنا </h2>"
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

footer() {
    year=$(date +'%Y')
    echo "
        <div class=\"footer\">
            <hr>
            <div>
                &copy; Saeed & BlueWave Projects and Services 2015 - $year
                <div>Portal Version: $version</div>
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
    echo "$client,$count,$ts" >> "$db"  # Keep original timestamp
}

check_attempts() {
    local now=$(date +%s)
    local client="$clientmac"
    local db="${logdir}attempts.txt"

    local max=3
    local window=300  # 5 minutes

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
    local cal_lang="$1"

    #-----------------------------------------------------
    # Calculate remaining time
    local pre_time_remaining
    if [ "$voucher_time_limit" -eq 0 ]; then
        pre_time_remaining="unlimited"
    else
        pre_time_remaining=$time_remaining
    fi

    #-----------------------------------------------------
    # Calculate remaining data
    local pre_data_remaining
    if [ "$voucher_quota_down" -eq 0 ]; then
        pre_data_remaining="unlimited"
    else
        pre_data_remaining=$(($voucher_quota_down / 1024)) # KB to MB
    fi

    #-----------------------------------------------------
    #
    # Prepare output based on language
    #

    local time_display data_display time_value data_value

    if [ "$cal_lang" = "ar" ]; then
        time_display="الوقت المتبقي"
                data_display="البيانات المتبقية"

        if [ "$pre_time_remaining" = "unlimited" ]; then
            time_value="غير محدود"
        else
            time_value="${pre_time_remaining} دقيقة"
        fi

        if [ "$pre_data_remaining" = "unlimited" ]; then
            data_value="غير محدود"
        else
            data_value="${pre_data_remaining} ميجابايت"
        fi
    else
        time_display="Time remaining"
        data_display="Data remaining"

        if [ "$pre_time_remaining" = "unlimited" ]; then
            time_value="unlimited"
        else
            time_value="${pre_time_remaining} minutes"
        fi

        if [ "$pre_data_remaining" = "unlimited" ]; then
            data_value="unlimited"
        else
            data_value="${pre_data_remaining} MB"
        fi
    fi

    echo "<br>${time_display}: ${time_value}<br>${data_display}: ${data_value}"
}

# SuperWiFi Voucher Management Scripts

check_voucher() {
    check_result_en=""
    check_result_ar=""

    # Validate token format (exactly 9 alphanumeric or dash characters)
    if ! echo -n "$voucher" | grep -qE "^[a-zA-Z0-9-]{9}$"; then
        check_result_en="Invalid voucher code <br> must be 9 alphanumeric characters"
        check_result_ar="كود الكوبون يجب أن يكون 9 أحرف<br> (أحرف أو أرقام أو شرطات)"
        return 1
    fi

    # Retrieve voucher from DB script
    output=$(get_voucher "$voucher")

    if [ -z "$output" ]; then
        track_attempts 1
        check_result_en="Voucher not found"
        check_result_ar="كود الكوبون غير صحيح أو غير موجود"
        return 1
    fi

    # Parse voucher fields from output
    voucher_token=$(echo "$output" | cut -d'|' -f1)
    voucher_mac=$(echo "$output" | cut -d'|' -f2)
    voucher_rate_down=$(echo "$output" | cut -d'|' -f3)
    voucher_rate_up=$(echo "$output" | cut -d'|' -f4)
    voucher_quota_down=$(echo "$output" | cut -d'|' -f5)
    voucher_quota_up=$(echo "$output" | cut -d'|' -f6)
    voucher_time_limit=$(echo "$output" | cut -d'|' -f7)
    voucher_accum=$(echo "$output" | cut -d'|' -f8)
    voucher_first_punched=$(echo "$output" | cut -d'|' -f9)
    current_time=$(date +%s)

    if [ "$voucher_first_punched" -eq 0 ]; then

	voucher_expiration=$(($current_time + $voucher_time_limit * 60))
        time_remaining=$voucher_time_limit
        sessiontimeout=$voucher_time_limit


        update_first_punch "$voucher_token" "$clientmac"

        check_result_en="Voucher activated successfully!$(calculate_remaining "en")"
        check_result_ar="تم تفعيل الكوبون بنجاح! $(calculate_remaining "ar")"
        return 0

    elif [ "$voucher_time_limit" != "0" ] && [ "$current_time" -ge "$voucher_expiration" ]; then
        check_result_en="Voucher expired. Time is over."
        check_result_ar="انتهت صلاحية الكود. الوقت انتهى."
        return 1

    elif [ "$voucher_quota_down" != "0" ] && [ "$voucher_accum" -ge "$voucher_quota_down" ]; then
        check_result_en="Voucher used up. No data remaining."
        check_result_ar="تم استهلاك بينات الكود بالكامل، لا توجد بيانات متبقية."
        return 1

    elif [ "$voucher_mac" != "0" ] && [ "$voucher_mac" != "$clientmac" ] && [ "$multiple_devices" != "1" ]; then
        check_result_en="Voucher is linked to another device"
        check_result_ar="هذا الكوبون مرتبط بجهاز آخر.<br> لا يمكن استخدامه من هذا الجهاز"
        return 1

    else
        update_last_punch "$voucher_token"
        if [ "$voucher_quota_down" != "0" ]; then
            voucher_quota_down=$(($voucher_quota_down - $voucher_accum))
        fi

        voucher_expiration=$(($voucher_first_punched + $voucher_time_limit * 60))
        time_remaining=$(( ($voucher_expiration - $current_time) / 60 ))
        session_length=$time_remaining

        check_result_en="Session renewed! $(calculate_remaining "en")"
        check_result_ar="تم تجديد الجلسة! $(calculate_remaining "ar")"
        return 0
    fi

    check_result_en="Unknown error"
    check_result_ar="خطأ غير معلوم"
    return 1
}


voucher_validation() {

    originurl=$(printf "${originurl//%/\\x}")

    #block_remaining=$(check_attempts)

    #if [ "$block_remaining" -gt 0 ]; then
        # Blocked case: show block message with remaining time
    #    block_message "$block_remaining"

    if check_voucher; then
        track_attempts 0
        quotas="$sessiontimeout $upload_rate $download_rate $upload_quota $download_quota"

        userinfo="Saeed - $voucher"
        binauth_custom="$voucher"
        encode_custom 

        auth_log

        if [ "$ndsstatus" = "authenticated" ]; then
            echo "<div class='status success'>
                <h3>عملية ناجحة</h3>
                <p>$check_result_ar</p>
            </div>
            <form>
                <input type=\"button\" class=\"btn\" value=\"متابعة\" onClick=\"location.href='$originurl'\">
            </form>"
        else

            check_result_ar="تم رض المصادقة"
                        check_result_en="Denied access"

            echo "<div class='status error'>
                <h3>عملية فاشلة</h3>
                 <p>$check_result_ar</p>
            </div>
            <p>Click Continue to try again</p>
            <form>
                <input type=\"button\" class=\"btn\" value=\"أعد المحاولة\" onClick=\"location.href='$originurl'\">
            </form>"
        fi
    else
        echo "<div class='status error'>
            <h3>عملية فاشلة</h3>
            <p>$check_result_ar</p>

        </div>
        <form>
            <input type=\"button\" class=\"btn\" value=\"إعادة الحاولة\" onClick=\"location.href='$originurl'\">
        </form>"
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
            <p><strong>Your IP:</strong> $clientip</p>
            <p><strong>Your MAC:</strong> $clientmac</p>
        </div>
        
        
        <form action=\"/opennds_preauth/\" method=\"get\">
            <input type=\"hidden\" name=\"fas\" value=\"$fas\"> 
            
            <div class=\"form-group\">
                <label for=\"voucher\">لن يعمل  الكارت إلا على جهاز واحد</label>
                <input type=\"text\" id=\"voucher\" name=\"voucher\" value=\"$voucher_code\" placeholder=\"اكتب هنا\" required>
            </div>
            
            <input type=\"submit\" class=\"btn\" value=\"تحقق من الرقم\">
        </form>
    "
    fi
    footer
}

read_terms() {
    echo "
        <form action=\"/opennds_preauth/\" method=\"get\">
            <input type=\"hidden\" name=\"fas\" value=\"$fas\">
            <input type=\"hidden\" name=\"terms\" value=\"yes\">
            <input type=\"submit\" class=\"btn\" value=\"Read Terms of Service\" style=\"background: linear-gradient(to right, #2193b0, #6dd5ed);\">
        </form>
    "
}

display_terms() {
    echo "
    <div class=\"card\">
        <div class=\"logo-container\">
            <img class=\"logo\" src=\"$gatewayurl""$logo\" alt=\"شعار $gatewayname\">
        </div>
        <h1>شروط الاستخدام</h1>
        
        <div class=\"info\">
            <!-- محتوى الشروط -->
        </div>
        
        <form>
            <input type=\"button\" class=\"btn\" value=\"عودة\" onClick=\"history.go(-1);return true;\">
        </form>
    "
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
