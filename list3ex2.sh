#!/bin/bash

# Show all processes in the system

# Prepare an array holding all the processes in it
cd /proc
processes=($(ls -d */))

# Column widths
pid_size=10
state_size=2
files_size=15
names_size=20
threads_size=10

# Headers for the table
printf "%${names_size}s" "Process name"
printf "%${pid_size}s" "PID"
printf "%${state_size}s" "State"
printf "%${threads_size}s" "Threads"
printf "%${threads_size}s" "PPID"
printf "%${files_size}s" "Files open"

printf "\n"

for i in "${processes[@]}"
do
  proc_pid=`sudo cat /proc/${i}/status | grep -w "Pid:" | awk '{print $2}'`
  proc_parent_id=`sudo cat /proc/${i}/status | grep -w "PPid:" | awk '{print $2}'`
  proc_threads=`sudo cat /proc/${i}/status | grep -w "Threads:" | awk '{print $2}'`
  proc_state=`sudo cat /proc/${i}/status | grep -w "State:" | awk '{print $2}'`
  proc_files=`sudo ls -l /proc/${i}/fd | wc -l`
  proc_name=`sudo cat /proc/${i}/status | grep -w "Name:" | awk '{print $2}'`

  printf "%${names_size}s" "$proc_name"
  printf "%${pid_size}s" "$proc_pid"
  printf "%${state_size}s" "$proc_state"
  printf "%${threads_size}s" "$proc_threads"
  printf "%${threads_size}s" "$proc_parent_id"
  printf "%${files_size}s" "$proc_files"

  printf "\n"

done
