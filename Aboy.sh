#!/bin/sh
uci add_list opennds.@opennds[0].fas_custom_variables_list="provider_name=أبو يوسف"
uci commit opennds
