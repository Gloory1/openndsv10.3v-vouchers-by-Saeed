#!/bin/sh

#------------------------------------------------------------------------
#
# Include sql manager lib
#
. /usr/lib/superwifi/superwifi_database_lib.sh
#------------------------------------------------------------------------

update_accum_auto() {
  local raw="$1"
  local download_this_season="$2"

  # Init database lib

  if echo "$raw" | grep -iq "preemptivemac-"; then
    local decoded=$(printf '%b' "${raw//%/\\x}" | tr -d '\n' | tr -d '\r')
    local mac=$(echo "$decoded" | sed 's/.*preemptivemac-//I' | tr 'A-Z' 'a-z')
    local token=$(get_last_voucher_for_mac "$mac")
    update_accum "$token" "$download_this_season"
  else
    local token=$(echo "$raw" | base64 -d 2>/dev/null)
    [ -z "$token" ] && return
    update_accum "$token" "$download_this_season"
  fi
}

# JSON from openNDS
ndsctl json | jq -r '
  .clients | to_entries[] |
  "\(.value.custom) \(.value.download_this_session)"
' | while read -r custom download_this_session; do
  update_accum_auto "$custom" "$download_this_session"
done
