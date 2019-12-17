#!/bin/sh
#
#
REP_LOG=/var/log
REP_ARCH=/var/log/adrip
ARCH_LOG=adr-pi.log
rm ${REP_ARCH}/${ARCH_LOG}
DERNIER_FIC_LOG=`ls -got ${REP_LOG} | grep YSFReflector | head -1 | awk '{print $7}'`

tac ${REP_LOG}/${DERNIER_FIC_LOG} | while read col1 col2 col3 col4 col5 col6 col7
 do
 if [ ${col4} = "Currently" ]
        then
        break
 fi
 ADR_IP=`echo ${col6} | awk -F'[(:)]' '{print $1}'`
 echo "${col4} ${ADR_IP}" >> ${REP_ARCH}/${ARCH_LOG}
done


# grep $1 ${REP_ARCH}/${ARCH_LOG} | head -1
