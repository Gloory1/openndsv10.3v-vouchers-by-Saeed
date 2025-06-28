#!/bin/sh

update_voucher_accum() {
    local method_type="$1"
    local voucher_url="$2"
    local season_bytes_incoming="$3"

    local vouchers_file="/mnt/usb/ndslog/vouchers.txt"
    local debug_file="/mnt/usb/ndslog/debug.log"

    echo "------------------------------------------------------------------------------------------------" >> "$debug_file"
    echo "New operator | method : $method_type | raw url: $voucher_url" >> "$debug_file"


    voucher_code=$(echo -n "$voucher_url" | perl -pe 's/%(\w+)/chr hex $1/ge' | base64 -d | sed 's/.*=//')


    if [ -z "$voucher_code" ]; then
        echo "❌ Empty voucher from decoded: $voucher_code" >> "$debug_file"
        return
    fi

    echo "✅ update_voucher_accum started" >> "$debug_file"
    echo "voucher_code: $voucher_code" >> "$debug_file"

    local added_kb=0
    if [ -n "$season_bytes_incoming" ]; then
        added_kb=$((season_bytes_incoming / 1024))
    fi

    local voucher_line
    voucher_line=$(grep "^$voucher_code," "$vouchers_file")
    if [ -z "$voucher_line" ]; then
        echo "❌ Voucher not found: $voucher_code" >> "$debug_file"
        return
    fi

    local old_accum
    old_accum=$(echo "$voucher_line" | awk -F',' '{print $9}')
    [ -z "$old_accum" ] && old_accum=0

    local new_accum=$((old_accum + added_kb))

    sed -i "/^$voucher_code,/d" "$vouchers_file"
    local new_line
    new_line=$(echo "$voucher_line" | awk -F',' -v n=$new_accum 'BEGIN{OFS=","}{$9=n; print $0}')

    echo "old_line: $voucher_line" >> "$debug_file"
    echo "new_line: $new_line" >> "$debug_file"
    echo "$new_line" >> "$vouchers_file"

    return
}

#---------------------------#---------------------------------------#
