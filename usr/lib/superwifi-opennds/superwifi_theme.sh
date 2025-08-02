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
    <title>$gatewayname</title>
    <style>
    * {
        margin: 0;
        padding: 0;
        box-sizing: border-box;
        font-family: arial, sans-serif;
    }

    body {
         background: linear-gradient(135deg, #e3fdfd, #cbf1f5, #a6e3e9);
        background-size: 400% 400%;
        animation: gradientBG 1s ease infinite;
        color: #01579b;
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
        background: #E7F6FC;
        border-radius: 25px;
        box-shadow: 0 10px 30px rgba(2, 119, 189, 0.25);
        width: 100%;
        max-width: 500px;
        padding: 10px 15px;
        position: relative;
        overflow: hidden;
        border: 1px solid rgba(255, 255, 255, 0.7);
    }

    .card:before {
        content: '';
        position: absolute;
        top: -50%;
        left: -50%;
        width: 200%;
        height: 200%;
        background: radial-gradient(circle, rgba(255, 255, 255, 0.6) 0%, transparent 70%);
        transform: rotate(30deg);
        z-index: 0;
        animation: rotateGradient 20s linear infinite;
    }


    .logo-container {
        position: relative;
        z-index: 2;
        margin-top: 20px;
        float: left; 
        margin-right: 15px;
    }

    .logo {
        width: 100px;
        height: 100px;
        margin: 0 auto;
        border-radius: 50%;
        object-fit: cover;
        border: 3px solid white;
        box-shadow: 0 5px 15px rgba(3, 169, 244, 0.2);
        transition: all 0.5s ease;
    }

    .logo:hover {
        transform: scale(1.03) rotate(5deg);
    }

    h1 {
        font-size: 2.2rem;
        text-align: right;
        direction: rtl;
        margin: 10px 0 5px;
        background: linear-gradient(175deg, #0288d1, #039be5, #03a9f4);
        -webkit-background-clip: text;
        -webkit-text-fill-color: transparent;
        position: relative;
        z-index: 2;
        text-shadow: 0 2px 8px rgba(2, 119, 189, 0.15);
        letter-spacing: -1px;
    }

    h2 {
        font-size: 1.3rem;
        text-align: right;
        direction: rtl;
        margin-bottom: 25px;
        font-weight: 600;
        color: #0288d1;
        position: relative;
        z-index: 2;
        text-shadow: 0 1px 2px rgba(255, 255, 255, 0.5);
    }

    h3 {
        font-size: 1.1rem;
        padding: 5px;
        font-weight: 500;
        color: #01579b;
        position: relative;
    }

    .info {
        background: #b3e5fc;
        margin-top: 50px;
        margin-bottom: 15px;

        padding: 10px;
        border-radius: 12px;
        text-align: center;
        position: relative;
        border: 1.5px solid #b3e5fc;
    }

    .info p {
        color: #0288d1;
        font-weight: 500;
        font-size: 1.2rem;
 
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
        color: #0277bd;
        font-size: 1.1rem;
        position: relative;
        z-index: 2;
    }

    input[type='text'] {
        width: 100%;
        padding: 18px 20px;
        border: none;
        border-radius: 12px;
        background: #fff;
        font-size: 1.4rem;
        font-weight: 700;
        text-align: center;
        box-shadow: 0 5px 15px rgba(2, 119, 189, 0.1);
        color: #01579b;
        border: 2px solid #b3e5fc;
        transition: all 0.3s ease;
        position: relative;
        z-index: 2;

    }

    input[type='text']:focus {
        outline: none;
        border-color: #03a9f4;
        box-shadow: 0 5px 20px rgba(3, 169, 244, 0.2);
    }

    .btn {
        background: linear-gradient(45deg, #0288d1, #03a9f4);
        color: white;
        border: none;
        padding: 15px;
        font-size: 1.2rem;
        border-radius: 12px;
        cursor: pointer;
        width: 100%;
        font-weight: 700;
        transition: all 0.3s ease;
        box-shadow: 0 7px 20px rgba(3, 169, 244, 0.3);
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
        box-shadow: 0 10px 25px rgba(3, 169, 244, 0.4);
    }
    .spinner {
        display: inline-block;
        width: 20px;
        height: 20px;
        border: 3px solid rgba(255,255,255,.3);
        border-radius: 50%;
        border-top-color: #fff;
        animation: spin 1s ease-in-out infinite;
        margin-right: 10px;
        vertical-align: middle;
    }

    @keyframes spin {
        to { transform: rotate(360deg); }
    }

    .btn-loading .btn-text {
        display: none;
    }

    .btn-loading .spinner {
        display: inline-block !important;
    }

    .status {
        padding: 20px;
        border-radius: 12px;
        margin: 20px 0;
        font-size: 1.1rem;
        position: relative;
        z-index: 2;
    }

    .success {
        background: rgba(46, 204, 113, 0.7);
        margin-top: 50px;
        border-left: 5px solid #27ae60;
        color: white;
    }

    .error {
        background: rgba(231, 76, 60, 0.7);
        margin-top: 50px;
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
        color: #01579b;
        border: 1px solid rgba(3, 169, 244, 0.2);
    }

    .terms-notice a {
        color: #0288d1;
        font-weight: 700;
        text-decoration: none;
    }

    .footer {
        margin-top: 20px;
        font-size: 0.85rem;
        color: #0288d1;
        position: relative;
        z-index: 2;
        font-weight: 600;
    }

    hr {
        border: 0;
        height: 2px;
        background: linear-gradient(to right, transparent, #81d4fa, transparent);
        margin: 20px 0;
    }

    .countdown {
        font-size: 1.6rem;
        color: #03a9f4;
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
            <p>$check_result_ar</p>
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
    year=$(date +'%Y')
    echo "
        <div class=\"footer\">
            <hr>
            <div>
                &copy; Saeed & BlueWave Projects and Services 2025
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
        pre_data_remaining=$(($download_quota / 1024)) # KB to MB
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


    # Set limits according to voucher
    current_time=$(date +%s)
    upload_rate=$voucher_rate_up
    download_rate=$voucher_rate_down
    upload_quota=$voucher_quota_up
    download_quota=$voucher_quota_down

    if [ "$voucher_quota_down" = 0 ]; then
        download_quota=$voucher_quota_down
    else
        download_quota=$(($voucher_quota_down - $voucher_accum_down_total))
    fi


    if [ "$voucher_first_punched" -eq 0 ]; then

	voucher_expiration=$(($current_time + $voucher_time_limit * 60))
        time_remaining=$voucher_time_limit
        sessiontimeout=$voucher_time_limit


        update_first_punch "$voucher_token" "$clientmac"

        check_result_en="Voucher activated successfully!$(calculate_remaining "en")"
        check_result_ar="تم تفعيل الكوبون بنجاح! $(calculate_remaining "ar")"
        return 0

    elif [ "$voucher_time_limit" != 0 ] && [ "$current_time" -ge "$voucher_expiration" ]; then
        check_result_en="Voucher expired. Time is over."
        check_result_ar="انتهت صلاحية الكود<br>الوقت انتهى"
        return 1

    elif [ "$voucher_quota_expired" = 1 ]; then
        check_result_en="Voucher expired. Data is over."
        check_result_ar="انتهت صلاحية الكود<br>البيانات انتهت"
        return 1

    elif [ "$voucher_quota_down" != 0 ] && [ "$voucher_accum_down_total" -ge "$voucher_quota_down" ]; then
        check_result_en="Voucher used up. No data remaining."
        check_result_ar="تم استهلاك بينات الكود بالكامل<br>لا توجد بيانات متبقية"
        return 1

    elif [ "$voucher_mac" != "0" ] && [ "$voucher_mac" != "$clientmac" ]; then
        check_result_en="Voucher is linked to another device"
        check_result_ar="هذا الكوبون مرتبط بجهاز آخر<br>لا يمكن استخدامه من أي جهاز آخر"
        return 1

    else

        voucher_expiration=$(($voucher_first_punched + $voucher_time_limit * 60))
        time_remaining=$(( ($voucher_expiration - $current_time) / 60 ))
        session_length=$time_remaining

        check_result_en="Session renewed! $(calculate_remaining "en")"
        check_result_ar="تم تجديد الجلسة! $(calculate_remaining "ar")"
        update_last_punch "$voucher_token"
        return 0
    fi

    check_result_en="Unknown error"
    check_result_ar="خطأ غير معلوم"
    return 1
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
		                <p>$check_result_ar</p>
		            </div>
		            <form>
		                <input type=\"button\" class=\"btn\" value=\"متابعة\" onClick=\"location.href='$originurl'\">
		            </form>"
		else

			check_result_ar="تم رض المصادقة"
			check_result_en="Denied access"
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
