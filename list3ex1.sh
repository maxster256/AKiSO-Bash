#!/bin/bash

# Function that displays the bar on the screen
# Arguments: 1) percentage to display
# 2) color of the bar

display_bar() {

  # screen_width=`bc <<< "$(tput cols)"`

  max=`expr $1 / 2`
  for (( i = 0 ; i <= $max ; i++ ))
  do
    #$(tput dim)$(tput bold)
    echo -n "$(tput setab $2) "
  done

  tput setab 7
}

tput clear

max_io_speed=`dd bs=1M count=256 if=/dev/zero of=test conv=fdatasync  2>&1 | awk '/copied/ {print $10}'`
#echo "max_io_speed=$max_io_speed"

prev_read=(0 0 0 0 0)
writes_history=(0 0 0 0 0)
prev_cpuio=0

hist_count=0

while :
do
	# 1. Read the IO stats from /proc/diskstats
  # Get the first sample point of data
	sectors_read_1=`cat /proc/diskstats | grep -w "sda" | awk '{print $6}'`
	read_time_1=`cat /proc/diskstats| grep -w "sda"| awk '{print $7}'`

	sectors_written_1=`cat /proc/diskstats | grep -w "sda" | awk '{print $10}'`
	write_time_1=`cat /proc/diskstats | grep -w "sda"| awk '{print $11}'`

	sleep 0.5

	# Get the data again after a second passes in order to calculate the disk usage
	sectors_read_2=`cat /proc/diskstats | grep -w "sda"| awk '{print $6}'`
	read_time_2=`cat /proc/diskstats | grep -w "sda" | awk '{print $7}'`

	sectors_written_2=`cat /proc/diskstats | grep -w "sda" | awk '{print $10}'`
	write_time_2=`cat /proc/diskstats | grep -w "sda" | awk '{print $11}'`

	# Perform calculations for the data
	d_sectors_read=`echo "$sectors_read_2-$sectors_read_1" | bc`
	d_sectors_written=`echo "$sectors_written_2-$sectors_written_1" | bc`
	d_time_read=`echo "$read_time_2 - $read_time_1" | bc`
	d_time_write=`echo "$write_time_2 - $write_time_1" | bc`

  # 2. Read stats from /proc/loadavg
  # Get the data about the percentage of system resources in usage

  cpuio_1min=`cat /proc/loadavg | awk '{print$1}'`
  cpuio_5min=`cat /proc/loadavg | awk '{print$2}'`
  cpuio_10min=`cat /proc/loadavg | awk '{print$3}'`

  processes_current_total=`cat /proc/loadavg | awk '{print$4}'`
  last_process_id=`cat /proc/loadavg | awk '{print$5}'`

  # 3. Create variables storing IO speed data in different units
  # Read speeds
  read_Bps=0
  read_kBps=0
  read_MBps=0

  # Write speeds
  write_Bps=0
  write_kBps=0
  write_MBps=0

	if [ "$d_time_write" -eq "0" ];
  then
		# Here we should display that the current write speeds are null, since nothing
		# is being written to the disk
    write_Bps=0
	elif [ "$d_time_write" -gt "0" ];
  then
		# Calculate the speed of writing data to the disk
		write_Bps=`bc <<< "($d_sectors_written / $d_time_write) * 512"`

    # Convert the speed to the correct unit, if neccessary that is
		if [ "$write_Bps" -gt "1048575" ];
		then
			write_MBps=`echo "$write_Bps / 1048576" | bc`
		elif [ "$write_Bps" -gt "1023" ];
		then
			write_kBps=`echo "$write_Bps / 1024" | bc`
		fi
	fi

	if [ "$d_time_read" -eq "0" ];
  then
    read_Bps=0
	elif [ "$d_time_read" -gt "0" ];
  then
    # Calculate the speed of reading data from the disk
    read_Bps=`bc <<< "($d_sectors_read / $d_time_read) * 512"`

    # Convert the speed to the correct unit, if neccessary that is
		if [ "$read_Bps" -gt "1048575" ];
		then
			read_MBps=`echo "$read_Bps / 1048576" | bc`
		elif [ "$read_Bps" -gt "1023" ];
		then
			read_kBps=`echo "$read_Bps / 1024" | bc`
		fi
	fi

  #echo "read_bps=$read_Bps, write_bps=$write_Bps, cpuio_1min=$cpuio_1min "
  #echo ">>>> write kbps=$write_kBps, write MBps=$write_MBps"
  #echo ">>>> read kbps=$read_kBps, read MBps=$read_MBps"

  # Prepare for showing the graph
  screen_width=`bc <<< "$(tput cols) - 5"`
  # echo "screen_width=$screen_width"

  max_io_speed_Bps=`bc <<< "$max_io_speed * 1048576/(1024/2)"`
  # echo "max_io_speed_Bps=$max_io_speed_Bps"

  read_a=`bc <<< "scale=20; $read_Bps / $max_io_speed_Bps"`
  read_graph_width=`bc <<< "(($read_a * $screen_width) + 0.5) / 1"`

  #read_prev_a=`bc <<< "scale=20; $prev_read / $max_io_speed_Bps"`
  #read_prev_graph_width=`bc <<< "(($read_prev_a * $screen_width) + 0.5) / 1"`

  write_a=`bc <<< "scale=20; $write_Bps / $max_io_speed_Bps"`
  write_graph_width=`bc <<< "(($write_a * screen_width) + 0.5) / 1"`

  #write_prev_a=`bc <<< "scale=20; $prev_write / $max_io_speed_Bps"`
  #write_prev_graph_width=`bc <<< "(($write_prev_a * $screen_width) + 0.5) / 1"`

  cpuio_a=`bc <<< "scale=20; $cpuio_1min / $cpuio_10min"`
  cpuio_graph_width=`bc <<< "(($cpuio_a  * $screen_width)/4 + 0.5) / 1"`

  cpuio_prev_a=`bc <<< "scale=20; $prev_cpuio / $cpuio_10min"`
  cpuio_prev_graph_width=`bc <<< "(($cpuio_prev_a * $screen_width)/4 + 0.5) / 1"`

  # echo "reada=$read_a,rgw=$read_graph_width, writea=$write_a, cpu=$cpuio_graph_width"
  # echo "readsp=$read_Bps, writesp=$write_Bps"

  #echo "previous_read_speed=$prev_read, previous_write_speed=$prev_write"
  #echo "write_prev_graph_width=$write_prev_graph_width, read_prev_graph_width=$read_prev_graph_width"

  for i in {0..4}
  do
    tput cup $i 0
    tput el

    if [ "${prev_read[$i]}" -gt "0" ]; then
      read_prev_a=`bc <<< "scale=20; ${prev_read[$i]} / $max_io_speed_Bps"`
      read_prev_graph_width=`bc <<< "(($read_prev_a * $screen_width) + 0.5) / 1"`

      echo -n "$(tput bold)Prev read   | "
      display_bar $read_prev_graph_width 3
      echo "$(tput sgr 0) ${prev_read[$i]} B/s"
    else
      prev_read[$i]=0

      echo -n "$(tput bold)Prev read   | "
      display_bar 0 3
      echo "$(tput sgr 0) 0 B/s"
    fi

  done

  tput cup 5 0
  tput el

  if [ "$read_MBps" -gt "0" ]; then
    echo -n "$(tput bold)Curr read   | "
    display_bar $read_graph_width 3
    echo "$(tput sgr 0) $read_MBps MB/s"
  elif [ "$read_kBps" -gt "0" ]; then
    echo -n "$(tput bold)Curr read   | "
    display_bar $read_graph_width 3
    echo "$(tput sgr 0) $read_kBps kB/s"
  else
    echo -n "$(tput bold)Curr read   | "
    display_bar $read_graph_width 3
    echo "$(tput sgr 0) $read_Bps B/s"
  fi

  for i in {0..4}
  do
    counter=`bc <<< "$i + 6"`
    tput cup $counter 0
    tput el

    if [ "${writes_history[$i]}" -gt 0 ]; then
      previos_write_a=`bc <<< "scale=20; ${writes_history[$i]} / $max_io_speed_Bps"`
      previous_write_bar_width=`bc <<< "(($write_prev_a * $screen_width) + 0.5) / 1"`

      echo -n "$(tput bold)Prev write  | "
      display_bar $previous_write_bar_width 4
      echo "$(tput sgr 0) ${prev_write[$i]} B/s"
    else
      writes_history[$i]=0

      echo -n "$(tput bold)Prev write  | "
      display_bar 0 4
      echo "$(tput sgr 0) 0 B/s"
    fi
  done

  tput cup 11 0
  tput el

  if [ "$write_MBps" -gt "0" ]; then
    echo -n "$(tput bold)Curr write  | "
    display_bar $write_graph_width 4
    echo "$(tput sgr 0) $write_MBps MB/s"
  elif [ "$write_kBps" -gt "0" ]; then
    echo -n "$(tput bold)Curr write  | "
    display_bar $write_graph_width 4
    echo "$(tput sgr 0) $write_kBps kB/s"
  else
    echo -n "$(tput bold)Curr write  | "
    display_bar $write_graph_width 4
    echo "$(tput sgr 0) $write_Bps B/s"
  fi

  tput cup 12 0
  tput el

  echo -n "$(tput bold)Prev CPU/IO | "
  display_bar $cpuio_prev_graph_width 5
  echo "$(tput sgr 0) $prev_cpuio"

  tput cup 13 0
  tput el

  echo -n "$(tput bold)Curr CPU/IO | "
  display_bar $cpuio_graph_width 5
  echo "$(tput sgr 0) $cpuio_1min"

  prev_read[hist_count]=$read_Bps
  prev_write[hist_count]=$write_Bps
  prev_cpuio=$cpuio_1min

  hist_count=$((hist_count+1))

  if (( $hist_count >= 5)); then
    hist_count=0
  fi

done
