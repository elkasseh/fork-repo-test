#!/usr/bin/env bash
Vd="1d6b"
Pd="0001"
Cd="09"
Sd="00"
Sp="00"
awk -F "  " -v found="" -v vind="$Vd" -v prod="$Pd" -v class="$Cd" -v subcs="$Sd" -v cpro="$Sp" \
'/^[0-9a-f]{4}/ {if ($1==vind){ found="1"; print $1" " $2;next }} \
 found == "1" && /^\t[0-9a-f]{4}/ \
 {if ($1==prod){ found="2"; print $1"  "$2 ;if ( ! class){ exit};next}} \
 found == "2" &&  /^[C][[:space:]]+[0-9a-f]{2}/ \
 {if ($1=="C "class){ found="3"; print $1 " " $2 " " ;if(!length(subcs)){exit};next}} \
 found == "3" && /^\t[0-9a-f]{2}/\
 {if ($1==subcs){ found="4"; print $1 " " $2 ;if ( !length(cpro) ){ exit};next}} \
 found == "4" && /^\t\t[0-9a-f]{2}/ \
{if ($1==cpro){ print $1 " " $2 } }\
 ' /usr/share/hwdata/usb.ids
