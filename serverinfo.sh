#!/bin/bash

# Other
HOSTNAME=$(hostname -f)
DISTR=$(cat /etc/issue | head -1)
MOTHERBOARD=$(dmidecode -t 2 | grep -iP 'manufacturer|product name' | sed -e 's/[^.]*: //' -e 's/Corporation//' | paste -s -d' ')
# CPU
CPUNUMBERS=$(dmidecode -t 4 | grep -i status | grep -iPc "populated|enabled")
CPUINFO=$(dmidecode -t 4 | grep -i version | uniq | sed -e 's/[^.]*: //' -e 's/[(R)(TM)@]//g' -e 's/ \{1,\}/ /g')
CPUNUMBERSPROC=$(grep -ic "model name" /proc/cpuinfo)
CPUINFOPROC=$(grep -i "model name" /proc/cpuinfo | uniq | sed -e 's/[^.]*: //' -e 's/[(R)(TM)@]//g' -e 's/ \{1,\}/ /g')
# HDD
HDDINFO=$(fdisk -l 2>/dev/null | grep "Disk /dev/" | grep -v "md" | awk '{print $3, $4}' | sed 's/,//g' | uniq -c | awk '{print $1 " x" ,$2, $3}')
# RAID
RAIDNUMBERS=$(grep -c "active raid" /proc/mdstat)
RAIDTYPE=$(grep "active raid" /proc/mdstat | awk '{print $4}' | uniq -c | tr 'a-z' 'A-Z' | awk '{print $1, "x " $2}')
RAIDNUMBEROFTYPES=$(grep "active raid" /proc/mdstat | awk '{print $4}' | uniq | wc -l)
# RAM
RAMNUMBERS=$(dmidecode -t 17 | grep Size | grep -vc "No Module Installed")
RAMINFO=$(dmidecode -t 17 | grep -iP "size|type:|speed" | grep -vP "No Module Installed|Unknown|Clock" | sort -u | paste -s | awk '{print $2, $3, $8, $5, $6}')
MAXRAM=$(dmidecode -t 16 | grep "Maximum Capacity" | uniq | sed 's/[^.]*: //')

function motherInfo {
    CHECK=$(dmidecode | grep -P "No SMBIOS|sorry")
    if [ $? -eq 0 ]; then
        echo "Mother Board: no found"
    else
        echo "Mother Board: $MOTHERBOARD"
    fi
}

function hddInfo {
    echo "HDD: $HDDINFO"
}

function raidInfo {
    if [ "$RAIDNUMBERS" == 0 ]; then
        echo "RAID: no found"
    else
        echo "RAID: $RAIDTYPE $SOFTRAID"
    fi
}

function cpuInfo {
    CHECK=$(dmidecode | grep -P "No SMBIOS|sorry")
    if [ $? -eq 0 ]; then
        echo "CPU: $CPUNUMBERSPROC x $CPUINFOPROC"
    else 
        if [ "$CPUINFO" == 00000000000000000000000000000000 ] || [ "$CPUINFO" == "Not Specified" ]; then
            echo "CPU: $CPUNUMBERSPROC x $CPUINFOPROC"
        else
            echo "CPU: $CPUNUMBERS x $CPUINFO"
        fi
    fi
}

function ramInfo {
    CHECK=$(dmidecode | grep -P "No SMBIOS|sorry")
    if [ $? -eq 0 ]; then
        echo "RAM: no found"
        echo "Max RAM: no found"
    else
        echo "RAM: $RAMNUMBERS x $RAMINFO"
        echo "Max RAM: $MAXRAM"
    fi
}

echo -e "Hostname: $HOSTNAME
Distr: $DISTR"

motherInfo
hddInfo
raidInfo
cpuInfo
ramInfo
