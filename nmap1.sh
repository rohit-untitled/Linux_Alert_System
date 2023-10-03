#!/bin/bash

# List of ports to check
ports=("22" "23" "445" "3389" "80" "443" "139" "445" "135" "1433" "5900")

# Function to check if a port is open
check_port() {
  port="$1"
  timeout 1 bash -c "</dev/tcp/localhost/$port" &>/dev/null
  if [ $? -eq 0 ]; then
    echo "Port $port is OPEN"
  fi
}

# Check each port and notify if it's open
error_message=""
for port in "${ports[@]}"; do
  result=$(check_port "$port")
  if [ -n "$result" ]; then
    error_message+="$result\n"
  fi
done

# Display error message using zenity if there are open ports
if [ -n "$error_message" ]; then
  zenity --error --title "Open Port Alert" --text "$error_message"
fi
