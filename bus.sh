#!/usr/bin/env bash
sysfs="/sys/bus/usb/devices/"
usbdb="/usr/share/hwdata/usb.ids"
dbc=$(<"$usbdb")

gettype(){

awk -v vid="$1" -v pod="$2" ' $0 ~ "^"vid".*" \
{print $0 ; found=1 ; next } \
found && $0 ~ "\t"pod".*" {print $0 ; exit }  '
}


mapfile -t arr < <(find "$sysfs" -maxdepth 1 -type l -name "*usb*" | sort )

(( "${#arr[@]}" == 0 )) && echo "USB Bus Not Gound " && exit 1 

for fd in "${arr[@]}";do
Vd=$(<"$fd/idVendor")
Pd=$(<"$fd/idProduct")
Nd=$(<"$fd/devnum")
Nb=$(<"$fd/busnum")

#echo "Vendor ID		:$Vd"
#echo "Product ID        :$Pd"
#echo "Devic Num         :$Nd"
#echo "Bus Num           :$Nb"

printf "%-15s\n" "Vendor ID         :$Vd"
printf "%-15s\n" "Product ID        :$Pd"
printf "%-15s\n" "Devic Num         :$Nd"
printf "%-15s\n" "Bus Num          :$Nb"


mapfile -t tmpar < <(gettype "$Vd" "$Pd" <<< "$dbc")

if (( ${#tmpar[@]} == 0  ));then
echo "no device Vendor with this name"
else
var1="${tmpar[1]//$'\t'/}"

echo -e "Vendor :\t${tmpar[0]}" | column -t -s $'\t' 
echo -e "Product:\t${var}"| column -t -s $'\t'
#echo "-------------------"
unset tmpar

mapfile -t tmpar < <(find "$fd/" -maxdepth 1 -type d -regextype posix-extended -iregex '.*/[0-9]{1,2}-[0-9]{1,2}$' )
if (( ${#tmpar[@]} == 0 ));then 
echo "their no another device on this Bus"
else
echo "-++++++++++++++++-"

echo "Another Device: ${#tmpar[@]}"

for dv in "${tmpar[@]}";do
Vd=$(<"$dv/idVendor")
Pd=$(<"$dv/idProduct")
Nd=$(<"$dv/devnum")
Nb=$(<"$dv/busnum")
echo -e "Vendor ID \t:$Vd" | column -t -s $'\t'
echo -e "Product ID\t:$Pd" | column -t -s $'\t'
echo -e "Devic Num \t:$Nd" | column -t -s $'\t'
echo -e "Bus Num   \t:$Nb" | column -t -s $'\t'

mapfile -t tmpar1 < <(gettype "$Vd" "$Pd" <<< "$dbc")

var1="${tmpar1[1]//$'\t'/}"

echo -e "Vendor :\t${tmpar1[0]}" | column -t -s $'\t' 
echo -e "Product:\t${var1}"| column -t -s $'\t'
unset tmpar1
echo "-++++++++++++++++++-"

done
fi
fi
echo "-------------------"

done 
