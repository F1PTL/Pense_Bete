#!/bin/bash
#
# Date : 04/05/2021
# F1PTL Bruno
# Version : 1.0
# Liste des nodes present sur le Node ASL
# 2 valeurs a positionner
# Le node a consulter val1
# Le node a supprimer val2
# script.bash val1 val2
###########################################

VAL1=${1:-NODE}
VAL2=${2:-ARIEN}
/usr/sbin/asterisk -rx "rpt nodes ${VAL1}" | grep T${VAL2} 
RC=$?
if [ $RC = 1 ]
	then
	echo "==> Rien a faire sur le node ASL ${VAL1} !"
	exit 1
	else
	echo "==> Suppression du node ${VAL2}"
	/usr/sbin/asterisk -rx "rpt fun ${VAL1} *1${VAL2}"
fi
