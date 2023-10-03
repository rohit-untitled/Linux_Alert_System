#!/bin/bash

function report_utilisation {
  # Process collected CPU data
  echo
  echo "CPU eaters :"
  cat /tmp/cpu_usage.$$ | 
awk '
{ process[$1]+=$2; }
END{
  for(i in process)
  {
    printf("%-20s %s\n",i, process[i]) ;
  }

   }' | sort -nrk 2 | head

  # Real-time CPU usage
  echo
  echo "Real-time CPU Usage :"
  cpu_usage=$(top -b -n 1 | grep "%Cpu" | awk '{print $2 + $4}')
  echo "$cpu_usage%"

  # Check if CPU usage crosses the 70% threshold
  if (( $(echo "$cpu_usage > 0.1" | bc -l) )); then
    # Display a warning pop-up using zenity
    zenity --warning --text="Warning: CPU usage has crossed 70%! Current usage: $cpu_usage%"
  fi

  # Real-time RAM usage
  echo
  echo "Real-time RAM Usage :"
  ram_usage=$(free -m | grep "Mem:" | awk '{printf("%.2f%%", ($3/($2-$7)) * 100)}')
  echo "$ram_usage"


  # Real-time Disk usage
  echo
  echo "Real-time Disk Usage :"
  df -h | grep -E '^Filesystem|/dev/' | awk '{print $1, $5}'
  
  # Calculate and display total disk usage
  echo
  echo "Total Disk Usage :"
  total_disk_usage=$(df -h --output=used | awk '{total += $1} END {print total}')
  echo "${total_disk_usage}MB"

  # Calculate and display total RAM usage
  echo
  echo "Total RAM Usage :"
  total_ram_usage=$(free -m --total | grep "Mem:" | awk '{print $3}')
  echo "${total_ram_usage}MB"
}

UNIT_TIME=2

echo "Watching CPU, RAM, and Disk usage... ;"

# Continuous monitoring loop
while true; do
    # Collect CPU data in a temporary file
    ps -eocomm,pcpu | egrep -v '(0.0)|(%CPU)' >> /tmp/cpu_usage.$$
    sleep $UNIT_TIME
    report_utilisation
done
