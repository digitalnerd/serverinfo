#!/bin/bash

HOSTNAME=$(hostname -f)
DISTR=$(cat /etc/issue)

MOTHERBOARD=$(dmidecode -t 2 | grep -iP 'manufacturer|product name' | sed 's/[^.]*: //' | paste -s -d' ')
CPUNUMBERS=$(dmidecode -t 4 | grep -i status | grep -iPc "populated|enabled")
CPUINFO=$(dmidecode -t 4 | grep -i version | sed -e 's/[^.]*: //' -e 's/[(R)(TM)@]//g' -e 's/ \{1,\}/ /g')
#HDDNUMBERS=$(ls -1 /dev/sd? | wc -l)
HDDSIZE=$(fdisk -l 2>/dev/null | grep "Disk /dev/" | grep -v "md" | awk '{print $3, $4}' | sed 's/,//' | uniq -c)
RAIDNUMBERS=$(grep -c "active raid" /proc/mdstat)
RAIDTYPE=$(grep "active raid" /proc/mdstat | awk '{print $4}' | uniq | tr 'a-z' 'A-Z')
RAMNUMBERS=$(dmidecode -t 17 | grep Size | grep -vc "No Module Installed")
RAMINFO=$(dmidecode -t 17 | grep -iP "size|type:|speed" | grep -vP "No Module Installed|Unknown" | sort -u | paste -s | awk '{print $2, $3, $8, $5, $6}')
MAXRAM=$(dmidecode -t 16 | grep "Maximum Capacity" | sed 's/[^.]*: //')

echo -e "Hostname: $HOSTNAME
Distr: $DISTR

Mother Board: $MOTHERBOARD
CPU: $CPUNUMBERS x $CPUINFO
HDD: $HDDSIZE
RAID: $RAIDNUMBERS x $RAIDTYPE (soft)
RAM: $RAMNUMBERS x $RAMINFO
Max RAM: $MAXRAM"
