#!/bin/bash

# シングルスレッドなプロセスが使えるCPUの上限を制限するデーモン（笑）
# 拾い物を改変
# cpulimitをインストールすること

CPU_LIMIT=50       	# Maximum percentage CPU consumption by each PID
DAEMON_INTERVAL=10  	# Daemon check interval in seconds
BLACK_PROCESSES_LIST=   # Limit only processes defined in this variable. If variable is empty (default) all violating processes are limited.
WHITE_PROCESSES_LIST=   # Limit all processes except processes defined in this variable. If variable is empty (default) all violating processes are limited.

# Check if one of the variables BLACK_PROCESSES_LIST or WHITE_PROCESSES_LIST is defined.
if [[ -n "$BLACK_PROCESSES_LIST" &&  -n "$WHITE_PROCESSES_LIST" ]] ; then    # If both variables are defined then error is produced.
    echo "At least one or both of the variables BLACK_PROCESSES_LIST or WHITE_PROCESSES_LIST must be empty."
    exit 1
elif [[ -n "$BLACK_PROCESSES_LIST" ]] ; then                                 # If this variable is non-empty then set NEW_PIDS_COMMAND variable to bellow command
    NEW_PIDS_COMMAND="top -b -n1 -c | grep -E '$BLACK_PROCESSES_LIST' | gawk '\$9>CPU_LIMIT {print \$1}' CPU_LIMIT=$CPU_LIMIT"
elif [[ -n "$WHITE_PROCESSES_LIST" ]] ; then                                 # If this variable is non-empty then set NEW_PIDS_COMMAND variable to bellow command
    NEW_PIDS_COMMAND="top -b -n1 -c | gawk 'NR>6' | grep -E -v '$WHITE_PROCESSES_LIST' | gawk '\$9>CPU_LIMIT {print \$1}' CPU_LIMIT=$CPU_LIMIT"
else
    NEW_PIDS_COMMAND="top -b -n1 -c | gawk 'NR>6 && \$9>CPU_LIMIT {print \$1}' CPU_LIMIT=$CPU_LIMIT"
fi

# Search and limit violating PIDs
while sleep $DAEMON_INTERVAL
do
    NEW_PIDS=$(eval "$NEW_PIDS_COMMAND")                                                                    # Violating PIDs
    LIMITED_PIDS=$(ps -eo args | gawk '$1=="cpulimit" {print $3}')                                          # Already limited PIDs
    QUEUE_PIDS=$(comm -23 <(echo "$NEW_PIDS" | sort -u) <(echo "$LIMITED_PIDS" | sort -u) | grep -v '^$')   # PIDs in queue

    for i in $QUEUE_PIDS

    do
        LOG_LINE=`date +"%Y/%m/%d %T" | tr -d '\n' && top -b -n1 -c | awk 'NR==8'`
        echo $LOG_LINE >> /var/log/cpulimit.log
        cpulimit -p $i -l $CPU_LIMIT -z &   # Limit new violating processes
    done
done
