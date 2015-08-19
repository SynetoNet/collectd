#!/usr/bin/env bash
MY_PATH=$(readlink -f `dirname $0`)

setUp() {
	. $MY_PATH/iostat_illumos_functions.sh
}

testItRecognizesIostatHeaderLines() {
	isAStatisticsLine "                    extended device statistics              "
	assertFalse "First iostat header line should not be recognized as a statistics line" $?

	isAStatisticsLine "    r/s    w/s   kr/s   kw/s wait actv wsvc_t asvc_t  %w  %b device"
	assertFalse "Second iostat header line should not be recognized as a statistics line" $?
}

testItIgnoresFloppyDisk() {
	isAnIgnoredStatisticsLine "    0.0    0.0    0.0    0.0  0.0  0.0    0.0    0.0   0   0 fd0"
	assertTrue "Floppy disk should have been ignored" $?
}

testItIgnoresNFSMounts() {
	isAnIgnoredStatisticsLine "    0.0    0.0    0.0    0.0  0.0  0.0    0.0    0.0   0   0 192.168.1.101:/Volumes/SourceRepos/unistore/StorageCLI"
	assertTrue "NFS mounts should have been ignored" $?
}

testItRecognizesThatAnIostatLineWithASataDiskIsForDiskTypeDevices() {
	local disk="c3t0d0"
	isStatisticsForADisk "    0.0    0.0    0.0    0.0  0.0  0.0    0.0    0.0   0   0 $disk"
	assertTrue "$disk was not recognized as a disk" $?
}

testItRecognizesThatAnIostatLineWithAISCSIDiskIsForDiskTypeDevices() {
	local disk="c2t5000CCA03835B714d0"
	isStatisticsForADisk "    0.0    0.0    0.0    0.0  0.0  0.0    0.0    0.0   0   0 $disk"
	assertTrue "$disk was not recognized as a disk" $?
}

testItRecognizesThatAnIostatLineWithADiskControllerHavingAnMultiDigitIndexIsForDiskTypeDevices() {
	local disk="c999t5000CCA03835B714d0"
	isStatisticsForADisk "    0.0    0.0    0.0    0.0  0.0  0.0    0.0    0.0   0   0 $disk"
	assertTrue "$disk was not recognized as a disk" $?
}

testAnEmptyLineIsNotForADiskDeviceStatistics() {
	isStatisticsForADisk ""
	assertFalse "Empty string should not represent a line for disk parameters" $?
}

testItDoesNotRecognizeALineForAPoolAsDiskType() {
	local device="rpool"
	isStatisticsForADisk "    0.0    0.0    0.0    0.0  0.0  0.0    0.0    0.0   0   0 $device"
	assertFalse "$device is a pool and should not be recognized as a disk" $?
}

testItDoesNotRecognizeALineForAFloppyAsDiskType() {
	local device="fd0"
	isStatisticsForADisk "    0.0    0.0    0.0    0.0  0.0  0.0    0.0    0.0   0   0 $device"
	assertFalse "$device is a Flopyy Disk and should not be recognized as a disk" $?
}

testItDoesNotRecognizeALineForANFSMountAsDiskType() {
	local device="192.168.1.101:/Volumes/SourceRepos/collectd"
	isStatisticsForADisk "    0.0    0.0    0.0    0.0  0.0  0.0    0.0    0.0   0   0 $device"
	assertFalse "$device is a NFS mount and should not be recognized as a disk" $?
}

testItCanFindTheDeviceFromAnIostatLine() {
	local device="c2t0d0"
	local iostatLine="    0.0    0.0    0.0    0.0  0.0  0.0    0.0    0.0   0   0 $device"
	assertEquals $device $(getDeviceFromIostatLine "$iostatLine")
}

testItCanFindIopsReadRSFromAnIostatLine() {
	local iopsReadRS="99.88"
	local iostatLine="    $iopsReadRS    0.0    0.0    0.0  0.0  0.0    0.0    0.0   0   0 c1t1d0"
	assertEquals $iopsReadRS $(getIopsReadRS "$iostatLine")
}

testItCanFindIopsWriteWSFromAnIostatLine() {
	local iopsWriteRS="99.88"
	local iostatLine="    0.0    $iopsWriteRS    0.0    0.0  0.0  0.0    0.0    0.0   0   0 c1t1d0"
	assertEquals $iopsWriteRS $(getIopsWriteWS "$iostatLine")
}

testItCanFindBandwidthReadKRSFromAnIostatLine() {
	local kiloReadsPerSecond="99.88"
	local readsInBytes="102277.12"
	local iostatLine="    0.0    0.0    $kiloReadsPerSecond    0.0  0.0  0.0    0.0    0.0   0   0 c1t1d0"
	assertEquals $readsInBytes $(getBandwidthReadKRS "$iostatLine")
}

testItCanFindBandwidthWriteInBytesFromAnIostatLine() {
	local kiloWritesPerSecond="99.88"
	local writesInBytes="102277.12"
	local iostatLine="    0.0    0.0    0.0    $kiloWritesPerSecond  0.0  0.0    0.0    0.0   0   0 c1t1d0"
	assertEquals $writesInBytes $(getBandwidthWritesKWS "$iostatLine")
}

testItCanFindWaitTransactionsFromAnIostatLine() {
	local transactionsWaiting="99.88"
	local iostatLine="    0.0    0.0    0.0    0.0  $transactionsWaiting  0.0    0.0    0.0   0   0 c1t1d0"
	assertEquals $transactionsWaiting $(getWaitingTransactions "$iostatLine")
}

testItCanFindActiveTransactionFromAnIostatLine() {
	local activeTransactions="99.88"
	local iostatLine="    0.0    0.0    0.0    0.0  0.0  $activeTransactions    0.0    0.0   0   0 c1t1d0"
	assertEquals $activeTransactions $(getActiveTransactions "$iostatLine")
}

testItCanFindWaitAverageServiceTimeFromAnIostatLine() {
	local waitServiceTime="99.88"
	local iostatLine="    0.0    0.0    0.0    0.0  0.0  0.0    $waitServiceTime    0.0   0   0 c1t1d0"
	assertEquals $waitServiceTime $(getWaitAverageServiceTime "$iostatLine")
}

testItCanFindActiveAverageServiceTimeFromAnIostatLine() {
	local activeServiceTime="99.88"
	local iostatLine="    0.0    0.0    0.0    0.0  0.0  0.0    0.0    $activeServiceTime   0   0 c1t1d0"
	assertEquals $activeServiceTime $(getActiveAverageServiceTime "$iostatLine")
}

testItCanFindWaitPercentFromAnIostatLine() {
	local waitPercent="99.88"
	local iostatLine="    0.0    0.0    0.0    0.0  0.0  0.0    0.0    0.0   $waitPercent   0 c1t1d0"
	assertEquals $waitPercent $(getWaitPercent "$iostatLine")
}

testItCanFindActivePercentFromAnIostatLine() {
	local activePercent="99.88"
	local iostatLine="    0.0    0.0    0.0    0.0  0.0  0.0    0.0    0.0   0   $activePercent c1t1d0"
	assertEquals $activePercent $(getActivePercent "$iostatLine")
}

testItCanValidateAStatisticsValue() {
	isValidValue "$(($MIN_VALID_STATISTICS_VALUE - 1))"; assertFalse "$(($MIN_VALID_STATISTICS_VALUE - 1)) should be invalid" $?
	isValidValue "$MAX_VALID_STATISTICS_THRESHOLD"     ; assertFalse "$MAX_VALID_STATISTICS_THRESHOLD should be invalid" $?
	isValidValue "$MIN_VALID_STATISTICS_VALUE" ; assertTrue  "$MIN_VALID_STATISTICS_VALUE should be valid"    $?
	isValidValue "0.0"                         ; assertTrue  "0.0 should be a valid number" $?
}



# Import shunit2
. /usr/shunit2/src/shunit2