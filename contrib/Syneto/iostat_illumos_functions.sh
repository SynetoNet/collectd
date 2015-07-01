#!/usr/bin/env bash

MIN_VALID_STATISTICS_VALUE=0
MAX_VALID_STATISTICS_THRESHOLD=7200000

function isStatisticsForADisk() {
	echo "$1" | /usr/gnu/bin/grep -E -e "c[0-9]+t.*d.*" >/dev/null 2>&1
}

function getColumnValueFromIostatLine() {
	echo "$1" | /usr/gnu/bin/awk -v col=$2 '{print $col}'
}

function getDeviceFromIostatLine() {
	getColumnValueFromIostatLine "$1" "11"
}

function getIopsReadRS() {
	getColumnValueFromIostatLine "$1" "1"
}

function getIopsWriteWS() {
	getColumnValueFromIostatLine "$1" "2"
}

function getBandwidthReadKRS() {
	getColumnValueFromIostatLine "$1" "3"
}

function getBandwidthWritesKWS() {
	getColumnValueFromIostatLine "$1" "4"
}

function getWaitingTransactions() {
	getColumnValueFromIostatLine "$1" "5"
}

function getActiveTransactions() {
	getColumnValueFromIostatLine "$1" "6"
}

function getWaitAverageServiceTime() {
	getColumnValueFromIostatLine "$1" "7"
}

function getActiveAverageServiceTime() {
	getColumnValueFromIostatLine "$1" "8"
}

function getWaitPercent() {
	getColumnValueFromIostatLine "$1" "9"
}

function getActivePercent() {
	getColumnValueFromIostatLine "$1" "10"
}

function isValidValue() {
	if [ $(expr $1 \< $MIN_VALID_STATISTICS_VALUE) == 1 ] || [ $(expr $1 \>= $MAX_VALID_STATISTICS_THRESHOLD) == 1 ]; then
		return 1
	fi
}