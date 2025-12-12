#!/usr/bin/env bash

Vd="106b"
Pd="003f"
Cd="0c0310"
Sv=""
Sd=""
Sc="${Cd:2:2}"
Sprog="${Cd:4:2}"
Cd="${Cd:0:2}"

p1='print $2'
echo $Cd $Sc $Sprog
output=$(awk -F "  "  -v found="" -v vind="$Vd" -v prod="$Pd" -v class="$Cd" -v subvd="$Sv $Sd" \
 -v subcs="$Sc" -v subprog=$Sprog \
\
'/^[0-9a-f]{4}/ {if ($1==vind){ found="1"; print "1:"$1"_" $2;next }} \
\
 found == "1" && /^\t[0-9a-f]{4}/ \
 {if ($1 =="\t"prod ){ print "2:"$1"_"$2  ;if (subvd != " "){found="2"}else if(class){found="3"; }\
else{exit};next }} \
\
 found == "2" &&  /^\t\t[0-9a-f]{4}[[:space:]]+[0-9a-f]{4}/ \
 {if ($1==subvd){ found="3"; print "3:"$1"_"$2 ;if(!length(class)){exit};next}} \
\
 found == "3" &&  /^[C][[:space:]]+[0-9a-f]{2}/ \
 {if ($1=="C "class){ found="4"; print "4:"class"_"$2;if(!length(subcs)){exit};next}} \
\
 found == "4" && /^\t[0-9a-f]{2}/\
 {if ($1=="\t"subcs){ found="5"; print "5:"$1"_"$2 ;if(!length(subprog)){exit };next}}\
\
found == "5" && /^\t\t[0-9a-f]{2}/\
 {if ($1=="\t\t"subprog){ found="6"; print "6:"$1"_"$2 ;exit} }\
' /usr/share/hwdata/pci.ids )

#output="${output//$'\n'/}"
#output="${output//$'\t'/ }"
#$mapfile -t arr=
##vendor 1 
##device 2
##subdv empty 3 
##class  4
##subclass 5
##subprog 6
declare -A arr=( ["1"]=0 ["2"]=0 ["3"]=0 ["4"]=0 ["5"]=0 ["6"]=0 )
echo "${arr[@]}"
echo "${!arr[@]}"
while read -r n;do
arr["${n%%:*}"]="${n#*:}"
done <<< "${output//$'\t'/}"

echo "${arr['5']#*_}: ${arr['1']#*_} ${arr['2']#*_} "
