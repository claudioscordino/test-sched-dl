#!/bin/bash

# Uncomment to enable reclaiming:
# export TESTDL_SCHED_FLAG=2

# Change to specify a specific path for trace-cmd:
export TRACECMD=trace-cmd

## Check if we have root permissions
if [ "`id -u`" != "0" ]; then
        echo "ERROR: Need to be root to run this script! Use 'sudo' command."
        exit
fi

do_clean() {
	echo "Killing all remaining tasks..."
	killall -s SIGKILL -r 'T00*'
	echo "Umounting /dev/cpuset..."
	umount /dev/cpuset
	echo "Resetting RT throttling..."
	echo 1000000 > /proc/sys/kernel/sched_rt_period_us
	echo  950000 > /proc/sys/kernel/sched_rt_runtime_us
}

do_test() {
	echo "==================================="
	echo "Entering directory $1"
	cd $1
	./run.sh
	sleep 10
	cd ..
}

do_clean

if [[ "$TESTDL_SCHED_FLAG" == "" ]]; then
	echo "Disabling RT throttling..."
	echo -1 > /proc/sys/kernel/sched_rt_runtime_us
	echo -1 > /proc/sys/kernel/sched_rt_period_us
	else
	echo "Setting RT throttling..."
	echo  950000 > /proc/sys/kernel/sched_rt_runtime_us
	echo 1000000 > /proc/sys/kernel/sched_rt_period_us
fi

if [[ $1 == "" ]];then
	echo "No test provided. Running all tests with flag $TESTDL_SCHED_FLAG"
	for TEST in `ls -d T0* | xargs -r`; do
		do_test $TEST
	done
else
	echo "Running test $1 with flag $TESTDL_SCHED_FLAG"
	do_test $1
fi

do_clean
echo "Test finished"
