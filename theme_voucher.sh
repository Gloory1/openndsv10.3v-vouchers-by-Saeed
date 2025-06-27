#!/bin/sh
#Copyright (C) The openNDS Contributors 2004-2023
#Copyright (C) BlueWave Projects and Services 2015-2024
#Copyright (C) Francesco Servida 2023
#This software is released under the GNU GPL license.
#Edited by Saeed Muhammed
# Title of this theme:

#-----------------------------------------------------------------------#
#
# init variables 
#

title="theme_voucher"
multiple_devices=${multiple_devices:-0}

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
          *{          
            margin: 0;
            padding: 0;
            font-family: 'Cairo', sans-serif;
         }        
         body {
            font-family: 'Cairo', sans-serif; 
            background: linear-gradient(135deg, #1a2a6c, #b21f1f, #fdbb2d);
            color: #fff;
            min-height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
            padding: 15px; 
        }
        .card {
            background: rgba(0, 0, 0, 0.7);
            border-radius: 15px;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.5);
            width: 100%;
            max-width: 500px;
            padding: 20px;
            text-align: center;
        }
        .logo {
            width: 100px;
            height: 100px;
            float: left;
            margin: 0 auto 10px;
            border-radius: 50%;
            object-fit: contain; /* Ensures image maintains aspect ratio */
        }
        h1 {
            font-size: 2.2rem;
            margin-bottom: 5px;
            color: #ffcc00;
            text-shadow: 0 2px 5px rgba(0,0,0,0.5);
        }
        h2 {
            font-size: 1.4rem;
            margin-bottom: 25px;
            font-weight: 400;
            color: #4dffb8;
            direction: rtl;
            text-align: center;

        }
        .form-group {
            margin-bottom: 20px;
            text-align: center;
        }
        label {
            display: block;
            margin-top: 25px;
            margin-bottom: 8px;
            font-weight: 500;
            color: #ff9966;
        }
        input[type='text'] {
            width: 90%;
            padding: 15px;
            border: none;
            border-radius: 10px;
            background: rgba(255, 255, 255, 0.9);
            font-size: 1.5rem;
            font-weight: 700;
            text-align: center;

        }
        .btn {
            background: linear-gradient(to right, #ff416c, #ff4b2b);
            color: white;
            border: none;
            padding: 12px 28px;
            font-size: 1.1rem;
            border-radius: 10px;
            cursor: pointer;
            width: 100%;
            font-weight: 600;
            transition: all 0.3s ease;
            box-shadow: 0 4px 10px rgba(0,0,0,0.3);
        }
        .btn:hover {
            transform: translateY(-3px);
            box-shadow: 0 6px 15px rgba(0,0,0,0.4);
        }
        .info {
            background: rgba(0, 0, 0, 0.4);
            padding: 10px 15px;
            border-radius: 8px;
            margin: 20px 0;
            text-align: left;
            border-left: 4px solid #ffcc00;
        }
        .info p {
            margin: 8px 0;
            line-height: 1.6;
        }
        .footer {
            margin-top: 10px;
            font-size: 0.85rem;
            color: rgba(255, 255, 255, 0.7);
        }
        .big-red {
            color: #ff3333;
            font-size: 1.7rem;
            font-weight: 700;
            display: block;
            margin: 20px 0;
        }
        .status {
            padding: 20px;
            border-radius: 8px;
            margin: 20px 0;
            font-size: 1.1rem;
            border: 2px solid rgba(255,255,255,0.2);
        }
        .success {
            background: rgba(0, 100, 0, 0.5);
            border-left: 5px solid #4dff4d;
        }
        .error {
            background: rgba(100, 0, 0, 0.5);
            border-left: 5px solid #ff4d4d;
        }
        .terms-notice {
            background: rgba(255, 255, 255, 0.1);
            padding: 12px;
            border-radius: 8px;
            margin: 10px 0;
            font-size: 0.9rem;
            text-align: center;
        }
        hr {
            border: 0;
            height: 1px;
            background: linear-gradient(to right, transparent, #ffcc00, transparent);
            margin: 20px 0;
        }
    </style>
    </head>
    <body>
    <div class=\"card\">
    <img class=\"logo\" src=\"$gatewayurl""$imagepath\" alt=\"Splash Page: For access to the Internet.\">
    <h1>الشحات كافيه</h1>
    <h2>أهلا وسهلا بكم 🤍</h2>
    "
}

footer() {
    year=$(date +'%Y')
    echo "
        <div class=\"footer\">
            <hr>
            <div>
                &copy; BlueWave Projects and Services 2015 - $year
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

check_voucher() {
    # To show result in HTML (EN - AR)
    check_result_ar=""
    check_result_en=""

    # Strict Voucher Validation for shell escape prevention - Only alphanumeric (and dash character) allowed.
    if validation=$(echo -n $voucher | grep -E "^[a-zA-Z0-9-]{9}$"); then
        #echo "Voucher Validation successful, proceeding"
        : #no-op
    else
        #echo "Invalid Voucher - Voucher must be alphanumeric (and dash) of 9 chars."
        check_result_en="Invalid voucher code <br> must be 9 alphanumeric characters"
        check_result_ar="كود الكوبون يجب أن يكون 9 أحرف<br> (أحرف أو أرقام أو شرطات)"
                return 1
    fi

    ##############################################################################################################################
    # WARNING
    # The voucher roll is written to on every login
    # If its location is on router flash, this **WILL** result in non-repairable failure of the flash memory
    # and therefore the router itself. This will happen, most likely within several months depending on the number of logins.
    #------------------------------------
    # MAC check Added by Saeed Muhammed
    # This section ensures that each voucher is only used by one device (one MAC address).
    # When a voucher is used for the first time, the script saves the MAC address of that device
    # at 9th column in vouchers file.
    # On the next login attempt with the same voucher, the script checks if the MAC matches the saved one.
    # If it's a different MAC address, access is denied to prevent sharing the same voucher across devices.
    #------------------------------------

    # The location is set here to be the same location as the openNDS log (logdir)
    # By default this will be on the tmpfs (ramdisk) of the operating system.
    # Files stored here will not survive a reboot.

    voucher_roll="$logdir""vouchers.txt"
    [ -f "$voucher_roll" ] || touch "$voucher_roll"

    #
    # In a production system, the mountpoint for logdir should be changed to the mount point of some external storage
    # eg a usb stick, an external drive, a network shared drive etc.
    #
    # See "Customise the Logfile location" at the end of this file
    #
    ##############################################################################################################################

    output=$(grep $voucher $voucher_roll | head -n 1) # Store first occurence of voucher as variable
    #echo "$output <br>" #Matched line
    if [ $(echo -n $output | wc -w) -ge 1 ]; then 
        #echo "Voucher Found - Checking Validity <br>"
        current_time=$(date +%s)
        voucher_token=$(echo -n "$output" | cut -d, -f1)
        voucher_rate_down=$(echo -n "$output" | cut -d, -f2)
        voucher_rate_up=$(echo -n "$output" | cut -d, -f3)
        voucher_quota_down=$(echo -n "$output" | cut -d, -f4)
        voucher_quota_up=$(echo -n "$output" | cut -d, -f5)
        voucher_time_limit=$(echo -n "$output" | cut -d, -f6)
        voucher_first_punched=$(echo -n "$output" | cut -d, -f7)
        voucher_mac=$(echo -n "$output" | cut -d, -f8)

        # Set limits according to voucher
        upload_rate=$voucher_rate_up
        download_rate=$voucher_rate_down
        upload_quota=$voucher_quota_up
        download_quota=$voucher_quota_down
        
        if [ $voucher_first_punched -eq 0 ]; then
            # First Voucher Use
            # "Punch" the voucher by setting the timestamp to now
            # Override session length according to voucher

            voucher_expiration=$(($current_time + $voucher_time_limit * 60))
            sessiontimeout=$voucher_time_limit

            new_line="$voucher_token,$voucher_rate_down,$voucher_rate_up,$voucher_quota_down,$voucher_quota_up,$voucher_time_limit,$current_time,$clientmac"
            sed -i "s/^$voucher,.*/$new_line/" "$voucher_roll"


            check_result_en="Voucher activated successfully! <br>Session duration: ${voucher_time_limit} minutes"
            check_result_ar="تم تفعيل الكوبون بنجاح!<br> مدة الجلسة: ${voucher_time_limit} دقيقة"
                        return 0
        else
            # Current timestamp <= than Punch Timestamp + Validity (minutes) * 60 secs/minute
            voucher_expiration=$(($voucher_first_punched + $voucher_time_limit * 60))

            if [ $current_time -le $voucher_expiration ]; then
                # Before connention
                # This section ensures that each voucher is only used by one device (one MAC address).
                # This [ "$voucher_mac" != "0" ] condition to avoid errors

                time_remaining=$(( ($voucher_expiration - $current_time) / 60 ))
                # Override session length according to voucher
                sessiontimeout=$time_remaining
                # Nothing to change in the roll

                if [ "$voucher_mac" != "0" ] && [ "$voucher_mac" != "$clientmac" ] && [ "$multiple_devices" != "1" ]; then
                    check_result_en="Voucher is linked to another device"
                    check_result_ar="هذا الكوبون مرتبط بجهاز آخر.<br> لا يمكن استخدامه من هذا الجهاز"
                                        return 1
                fi

                check_result_en="Session renewed! <br>Time remaining: ${time_remaining} minutes"
                check_result_ar="تم تجديد الجلسة!<br> الوقت المتبقي: ${time_remaining} دقيقة"
                                return 0
            else
                #echo "Voucher has expired, please try another one <br>"
                # Delete expired voucher from roll
                sed -i "/$voucher/"d $voucher_roll
                check_result_en="Voucher expired"
                check_result_ar="انتهت صلاحية الكوبون<br>في المرة القادمة سيخبرك أن الكوبون غير موجود"
                                return 1
            fi
        fi
    else
        check_result_en="Voucher not found"
        check_result_ar="كود الكوبون غير صحيح أو غير موجود"
                return 1
    fi
    
    # Should not get here
    check_result_en="Unknown error"
    check_result_ar="خطأ غير معلوم"
    return 1

}

voucher_validation() {
    originurl=$(printf "${originurl//%/\\x}")

    if check_voucher; then
        quotas="$sessiontimeout $upload_rate $download_rate $upload_quota $download_quota"
        userinfo="$title - $voucher"
        auth_log

        if [ "$ndsstatus" = "authenticated" ]; then
            echo "<div class='status success'>
                <h2>عملية ناجحة</h2>
                <p>$check_result_ar</p>
            </div>
            <form>
                <input type=\"button\" class=\"btn\" value=\"تم\" onClick=\"location.href='$originurl'\">
            </form>"
        else
            echo "<div class='status error'>
                <h2>عملية فاشلة</h2>
                 <p>$check_result_ar</p>
            </div>
            <p>Click Continue to try again</p>
            <form>
                <input type=\"button\" class=\"btn\" value=\"Continue\" onClick=\"location.href='$originurl'\">
            </form>"
        fi
    else
        echo "<div class='status error'>
            <h2>عملية فاشلة</h2>
            <p>$check_result_ar</p>

        </div>
        <form>
            <input type=\"button\" class=\"btn\" value=\"إعادة الحاولة\" onClick=\"location.href='$originurl'\">
        </form>"
    fi
}

voucher_form() {
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
        <div class=\"terms-notice\">
            By connecting, you agree to our <a href=\"/opennds_preauth/?fas=$fas&terms=yes\" style=\"color:#ffcc00;\">Terms of Service</a>
        </div>

    "

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
        <div class=\"info\" style=\"max-height:400px;overflow:auto;\">
            <b style=\"color:#ff9966;\">Privacy.</b><br>
            <b>
                By logging in to the system, you grant your permission for this system to store any data you provide for
                the purposes of logging in, along with the networking parameters of your device that the system requires to function.<br>
                All information is stored for your convenience and for the protection of both yourself and us.<br>
                All information collected by this system is stored in a secure manner and is not accessible by third parties.<br>
            </b><hr>

            <b style=\"color:#ff9966;\">Terms of Service for this Hotspot.</b> <br>
            <b>Access is granted on a basis of trust that you will NOT misuse or abuse that access in any way.</b><hr>
            <b>Proper Use</b>
            <p>
                This Hotspot provides a wireless network that allows you to connect to the Internet. <br>
                <b>Use of this Internet connection is provided in return for your FULL acceptance of these Terms Of Service.</b>
            </p>
            <p>
                <b>You agree</b> that you are responsible for providing security measures that are suited for your intended use of the Service.
                For example, you shall take full responsibility for taking adequate measures to safeguard your data from loss.
            </p>
            <p>
                While the Hotspot uses commercially reasonable efforts to provide a secure service,
                the effectiveness of those efforts cannot be guaranteed.
            </p>
            <p>
                <b>You may</b> use the technology provided to you by this Hotspot for the sole purpose
                of using the Service as described here.
                You must immediately notify the Owner of any unauthorized use of the Service or any other security breach.<br><br>
                We will give you an IP address each time you access the Hotspot, and it may change.
                <br>
                <b>You shall not</b> program any other IP or MAC address into your device that accesses the Hotspot.
                You may not use the Service for any other reason, including reselling any aspect of the Service.
                Other examples of improper activities include, without limitation:
            </p>
                <ol>
                    <li>
                        downloading or uploading such large volumes of data that the performance of the Service becomes
                        noticeably degraded for other users for a significant period;
                    </li>
                    <li>
                        attempting to break security, access, tamper with or use any unauthorized areas of the Service;
                    </li>
                    <li>
                        removing any copyright, trademark or other proprietary rights notices contained in or on the Service;
                    </li>
                    <li>
                        attempting to collect or maintain any information about other users of the Service
                        (including usernames and/or email addresses) or other third parties for unauthorized purposes;
                    </li>
                    <li>
                        logging onto the Service under false or fraudulent pretenses;
                    </li>
                    <li>
                        creating or transmitting unwanted electronic communications such as SPAM or chain letters to other users
                        or otherwise interfering with other user's enjoyment of the service;
                    </li>
                    <li>
                        transmitting any viruses, worms, defects, Trojan Horses or other items of a destructive nature; or
                    </li>
                    <li>
                        using the Service for any unlawful, harassing, abusive, criminal or fraudulent purpose.
                    </li>
                </ol>

            <hr>
            <b>Content Disclaimer</b>
            <p>
                The Hotspot Owners do not control and are not responsible for data, content, services, or products
                that are accessed or downloaded through the Service.
                The Owners may, but are not obliged to, block data transmissions to protect the Owner and the Public.
            </p>
            The Owners, their suppliers and their licensors expressly disclaim to the fullest extent permitted by law,
            all express, implied, and statutary warranties, including, without limitation, the warranties of merchantability
            or fitness for a particular purpose.
            <br><br>
            The Owners, their suppliers and their licensors expressly disclaim to the fullest extent permitted by law
            any liability for infringement of proprietory rights and/or infringement of Copyright by any user of the system.
            Login details and device identities may be stored and be used as evidence in a Court of Law against such users.
            <br>

            <hr><b>Limitation of Liability</b>
            <p>
                Under no circumstances shall the Owners, their suppliers or their licensors be liable to any user or
                any third party on account of that party's use or misuse of or reliance on the Service.
            </p>
            <hr><b>Changes to Terms of Service and Termination</b>
            <p>
                We may modify or terminate the Service and these Terms of Service and any accompanying policies,
                for any reason, and without notice, including the right to terminate with or without notice,
                without liability to you, any user or any third party. Please review these Terms of Service
                from time to time so that you will be apprised of any changes.
            </p>
            <p>
                We reserve the right to terminate your use of the Service, for any reason, and without notice.
                Upon any such termination, any and all rights granted to you by this Hotspot Owner shall terminate.
            </p>

            <hr><b>Indemnity</b>
            <p>
                <b>You agree</b> to hold harmless and indemnify the Owners of this Hotspot,
                their suppliers and licensors from and against any third party claim arising from
                or in any way related to your use of the Service, including any liability or expense arising from all claims,
                losses, damages (actual and consequential), suits, judgments, litigation costs and legal fees, of every kind and nature.
            </p>
        </div>
        <form>
            <input type=\"button\" class=\"btn\" value=\"المتابعة\" onClick=\"history.go(-1);return true;\" style=\"background: linear-gradient(to right, #2193b0, #6dd5ed);\">
        </form>
    "
    footer
}

#################################################
#                       #
#  Start - Main entry point     #
#                       #
#################################################

sessiontimeout="0"
upload_rate="0"
download_rate="0"
upload_quota="0"
download_quota="0"

quotas="$sessiontimeout $upload_rate $download_rate $upload_quota $download_quota"

ndscustomparams=""
ndscustomimages=""
ndscustomfiles=""

ndsparamlist="$ndsparamlist $ndscustomparams $ndscustomimages $ndscustomfiles"

additionalthemevars="voucher"
fasvarlist="$fasvarlist $additionalthemevars"
userinfo="$title"
