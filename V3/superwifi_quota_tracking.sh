#!/bin/sh

#------------------------------------------------------------------------
# Include sql manager lib
. /usr/lib/superwifi/superwifi_database_manager.sh
#------------------------------------------------------------------------

# JSON from openNDS
ndsctl json | jq -r '
  .clients | to_entries[] |
  
  # Step 1: Filter only for clients who are authenticated
  select(.value.state == "Authenticated") |

  # Step 2: Format the output and handle null values
  # We use (// 0) to ensure "0" is returned instead of "null"
  "\(.value.mac) \(.value.upload_this_session // 0) \(.value.download_this_session // 0)"

' | while read -r mac upload_this_session download_this_session; do

  # Now we are sure this function is only called for authenticated clients
  # and with valid numeric values (0 at minimum)
  finished=$(update_accumulated_usage_by_mac "$mac" "$upload_this_session" "$download_this_session")

  if [ "$finished" -eq 1 ]; then
    # The user has finished their quota, deauthenticate them.
    ndsctl deauth "$mac"
  fi

done
