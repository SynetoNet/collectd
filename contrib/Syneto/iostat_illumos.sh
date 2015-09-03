#!/usr/bin/env bash
MY_PATH=$(readlink -f `dirname $0`)
. $MY_PATH/iostat_illumos_functions.sh

INTERVAL=${COLLECTD_INTERVAL:-10}
INTERVAL=${INTERVAL%.*}
HOSTNAME=${COLLECTD_HOSTNAME:-`hostname`}

while read -r line; do
	isAnIgnoredStatisticsLine "$line"
	isAnIgnoredLine=$?
	isAStatisticsLine "$line"
	isAHeaderLine=$?
	if [ "$isAnIgnoredLine" == "0" -o "$isAHeaderLine" != "0" ]; then
		continue
	fi

	isStatisticsForADisk "$line"
	IS_FOR_DISK=$?
	if [ "$IS_FOR_DISK" == "0" ]; then
		TYPE="disk"
	elif [ "$IS_FOR_DISK" != "0" ]; then
		TYPE="pool"
	fi

	DEVICE=$(getDeviceFromIostatLine "$line")

	iopsReadRS=$(getIopsReadRS "$line")
	isValidValue "$iopsReadRS" && echo "PUTVAL $HOSTNAME/iostat-$TYPE-$DEVICE/gauge-iops_read-rs interval=$INTERVAL N:$iopsReadRS"

	iopsWriteWS=$(getIopsWriteWS "$line")
	isValidValue "$iopsWriteWS" && echo "PUTVAL $HOSTNAME/iostat-$TYPE-$DEVICE/gauge-iops_write-ws interval=$INTERVAL N:$iopsWriteWS"

	bandwidthReadKRS=$(getBandwidthReadKRS "$line")
	isValidValue "$bandwidthReadKRS" && echo "PUTVAL $HOSTNAME/iostat-$TYPE-$DEVICE/gauge-bandwidth_read-krs interval=$INTERVAL N:$bandwidthReadKRS"

	bandwidthWritesKWS=$(getBandwidthWritesKWS "$line")
	isValidValue "$bandwidthWritesKWS" && echo "PUTVAL $HOSTNAME/iostat-$TYPE-$DEVICE/gauge-bandwidth_write-kws interval=$INTERVAL N:$bandwidthWritesKWS"

	waitingTransactions=$(getWaitingTransactions "$line")
	isValidValue "$waitingTransactions" && echo "PUTVAL $HOSTNAME/iostat-$TYPE-$DEVICE/gauge-wait_transactions-wait interval=$INTERVAL N:$waitingTransactions"

	activeTransactions=$(getActiveTransactions "$line")
	isValidValue "$activeTransactions" && echo "PUTVAL $HOSTNAME/iostat-$TYPE-$DEVICE/gauge-active_transactions-actv interval=$INTERVAL N:$activeTransactions"

	waitAverageServiceTime=$(getWaitAverageServiceTime "$line")
	isValidValue "$waitAverageServiceTime" && echo "PUTVAL $HOSTNAME/iostat-$TYPE-$DEVICE/gauge-wait_avg_service_time-wsvc_t interval=$INTERVAL N:$waitAverageServiceTime"

	activeAverageServiceTime=$(getActiveAverageServiceTime "$line")
	isValidValue "$activeAverageServiceTime" && echo "PUTVAL $HOSTNAME/iostat-$TYPE-$DEVICE/gauge-active_avg_service_time-asvc_t interval=$INTERVAL N:$activeAverageServiceTime"

	waitPercent=$(getWaitPercent "$line")
	isValidValue "$waitPercent" && echo "PUTVAL $HOSTNAME/iostat-$TYPE-$DEVICE/gauge-wait_percent-w interval=$INTERVAL N:$waitPercent"

	activePercent=$(getActivePercent "$line")
	isValidValue "$activePercent" && echo "PUTVAL $HOSTNAME/iostat-$TYPE-$DEVICE/gauge-active_percent-b interval=$INTERVAL N:$activePercent"


done < <(/usr/bin/iostat -xn 10)



