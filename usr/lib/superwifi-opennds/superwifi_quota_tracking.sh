#!/bin/sh

#------------------------------------------------------------------------
#
# Include sql manager lib
#
. /usr/lib/superwifi/superwifi_database_manager.sh
#------------------------------------------------------------------------

# JSON from openNDS
ndsctl json | jq -r '
  .clients | to_entries[] |
  "\(.value.mac) \(.value.upload_this_session) \(.value.download_this_session)"
' | while read -r mac upload_this_session download_this_session; do

  finished=$(update_accumulated_usage_by_mac "$mac" "$upload_this_session" "$download_this_session")

  if [ "$finished" -eq 1 ]; then
    ndsctl deauth "$mac"
  fi

done