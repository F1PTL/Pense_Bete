#!/bin/bash
#########################################################
#                                                       #
#              HostFilesUpdate.sh Updater               #
#                                                       #
#      Written for Pi-Star (http://www.pistar.uk/)      #
#               By Andy Taylor (MW0MWZ)                 #
#                                                       #
#                     Version 2.25                      #
#                                                       #
#   Based on the update script by Tony Corbett G0WFV    #
# ===================================================== #
# Version 1.1                                           #
# 11/05/2018  Modification F1PTL pour des besoins perso #
#                                                       #
#########################################################
# Check that the network is UP and die if its not
if [ "$(expr length `hostname -I | cut -d' ' -f1`x)" == "1" ]; then
	exit 0
fi

mkdir -p /home/pi/ref
APRSHOSTS=/home/pi/ref/APRSHosts.txt
DCSHOSTS=/home/pi/ref/DCS_Hosts.txt
DExtraHOSTS=/home/pi/ref/DExtra_Hosts.txt
DMRIDFILE=/home/pi/ref/DMRIds.dat
DMRHOSTS=/home/pi/ref/DMR_Hosts.txt
DPlusHOSTS=/home/pi/ref/DPlus_Hosts.txt
P25HOSTS=/home/pi/ref/P25Hosts.txt
YSFHOSTS=/home/pi/ref/YSFHosts.txt
FCSHOSTS=/home/pi/ref/FCSHosts.txt
XLXHOSTS=/home/pi/ref/XLXHosts.txt
NXDNIDFILE=/home/pi/ref/NXDN.csv
NXDNHOSTS=/home/pi/ref/NXDNHosts.txt
TGLISTBM=/home/pi/ref/TGList_BM.txt

# How many backups
FILEBACKUP=1

# Check we are root
if [ "$(id -u)" != "0" ];then
	echo "This script must be run as root" 1>&2
	exit 1
fi

# Create backup of old files
if [ ${FILEBACKUP} -ne 0 ]; then
	cp ${APRSHOSTS} ${APRSHOSTS}.$(date +%Y%m%d)
	cp ${DCSHOSTS} ${DCSHOSTS}.$(date +%Y%m%d)
	cp ${DExtraHOSTS} ${DExtraHOSTS}.$(date +%Y%m%d)
	cp ${DMRIDFILE} ${DMRIDFILE}.$(date +%Y%m%d)
	cp ${DMRHOSTS} ${DMRHOSTS}.$(date +%Y%m%d)
	cp ${DPlusHOSTS} ${DPlusHOSTS}.$(date +%Y%m%d)
	cp ${YSFHOSTS} ${YSFHOSTS}.$(date +%Y%m%d)
	cp ${FCSHOSTS} ${FCSHOSTS}.$(date +%Y%m%d)
	cp ${XLXHOSTS} ${XLXHOSTS}.$(date +%Y%m%d)
	cp ${NXDNIDFILE} ${NXDNIDFILE}.$(date +%Y%m%d)
	cp ${NXDNHOSTS} ${NXDNHOSTS}.$(date +%Y%m%d)
	cp ${TGLISTBM} ${TGLISTBM}.$(date +%Y%m%d)
fi

# Prune backups
FILES="${APRSHOSTS}
${DCSHOSTS}
${DExtraHOSTS}
${DMRIDFILE}
${DMRHOSTS}
${DPlusHOSTS}
${YSFHOSTS}
${FCSHOSTS}
${XLXHOSTS}
${NXDNIDFILE}
${NXDNHOSTS}
${TGLISTBM}"

for file in ${FILES}
do
  BACKUPCOUNT=$(ls ${file}.* | wc -l)
  BACKUPSTODELETE=$(expr ${BACKUPCOUNT} - ${FILEBACKUP})
  if [ ${BACKUPCOUNT} -gt ${FILEBACKUP} ]; then
	for f in $(ls -tr ${file}.* | head -${BACKUPSTODELETE})
	do
		rm $f
	done
  fi
done

# Generate Host Files
curl --fail -o ${APRSHOSTS} -s http://www.pistar.uk/downloads/APRS_Hosts.txt
curl --fail -o ${DCSHOSTS} -s http://www.pistar.uk/downloads/DCS_Hosts.txt
curl --fail -o ${DMRHOSTS} -s http://www.pistar.uk/downloads/DMR_Hosts.txt
if [ -f /etc/hostfiles.nodextra ]; then
# Move XRFs to DPlus Protocol
  curl --fail -o ${DPlusHOSTS} -s http://www.pistar.uk/downloads/DPlus_WithXRF_Hosts.txt
  curl --fail -o ${DExtraHOSTS} -s http://www.pistar.uk/downloads/DExtra_NoXRF_Hosts.txt
else
# Normal Operation
  curl --fail -o ${DPlusHOSTS} -s http://www.pistar.uk/downloads/DPlus_Hosts.txt
  curl --fail -o ${DExtraHOSTS} -s http://www.pistar.uk/downloads/DExtra_Hosts.txt
fi
curl --fail -o ${DMRIDFILE} -s http://www.pistar.uk/downloads/DMRIds.dat
curl --fail -o ${P25HOSTS} -s http://www.pistar.uk/downloads/P25_Hosts.txt
# curl --fail -o ${YSFHOSTS} -s http://www.pistar.uk/downloads/YSF_Hosts.txt
curl --fail -o ${YSFHOSTS}-TMP -s http://www.pistar.uk/downloads/YSF_Hosts.txt
# curl --fail -o ${FCSHOSTS} -s http://www.pistar.uk/downloads/FCS_Hosts.txt
curl --fail -o ${FCSHOSTS}-TMP -s http://www.pistar.uk/downloads/FCS_Hosts.txt
curl --fail -o ${XLXHOSTS} -s http://www.pistar.uk/downloads/XLXHosts.txt
curl --fail -o ${NXDNIDFILE} -s http://www.pistar.uk/downloads/NXDN.csv
# curl --fail -o ${NXDNHOSTS} -s http://www.pistar.uk/downloads/NXDN_Hosts.txt
curl --fail -o ${NXDNHOSTS}-TMP -s http://www.pistar.uk/downloads/NXDN_Hosts.txt
curl --fail -o ${TGLISTBM} -s http://www.pistar.uk/downloads/TGList_BM.txt

# If there is a DMR Over-ride file, add it's contents to DMR_Hosts.txt
if [ -f "/root/DMR_Priv_Hosts.txt" ]; then
	cat /root/DMR_Priv_Hosts.txt >> ${DMRHOSTS}
fi
# ID-DMR Private
if [ -f "/root/ID_DMR_Priv.txt" ]; then
	cat /root/ID_DMR_Priv.txt >> ${DMRIDFILE}
fi

# Add custom DMRIDFILE
cp ${DMRIDFILE} /home/pi/DMRIds.dat


# Add custom YSFHosts FR
if [ -f ${YSFHOSTS}-TMP ]; then
        cat ${YSFHOSTS}-TMP | grep 'FR-' > ${YSFHOSTS}
        cat ${YSFHOSTS}-TMP | grep '127.0.0.1' >> ${YSFHOSTS}
		echo "61210;BE-YSF-TEST;Belgique-Tests;serveur.on4rd.be;53004;001;http://ysfdashon4rd.ddns.net" >> ${YSFHOSTS}
fi

# Add custom FCSHOSTS FR
if [ -f ${FCSHOSTS}-TMP ]; then
        cat ${FCSHOSTS}-TMP | grep 'Franc' > ${FCSHOSTS}
fi

# Add custom NXDN Hosts
if [ -f ${NXDNHOSTS}-TMP ]; then
	cat ${NXDNHOSTS}-TMP > ${NXDNHOSTS}
fi

# If there is an XLX over-ride
if [ -f "/root/XLXHosts.txt" ]; then
        while IFS= read -r line; do
                if [[ $line != \#* ]] && [[ $line = *";"* ]]
                then
                        xlxid=`echo $line | awk -F  ";" '{print $1}'`
                        xlxroom=`echo $line | awk -F  ";" '{print $3}'`
                        xlxip=`grep "^${xlxid}" /home/pi/XLXHosts.txt | awk -F  ";" '{print $2}'`
                        xlxNewLine="${xlxid};${xlxip};${xlxroom}"
                        /bin/sed -i "/^$xlxid\;/c\\$xlxNewLine" /home/pi/XLXHosts.txt
                fi
        done < /root/XLXHosts.txt
fi

exit 0
