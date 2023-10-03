#!/bin/bash

# Check if nmap is installed
if ! command -v nmap &> /dev/null; then
  echo "nmap not found. Please install nmap first."
  exit 1
fi

# List of ports to check
ports=("22" "23" "445" "3389" "80" "443" "139" "445" "135" "1433" "5900")

# Function to check if a port is open
check_port() {
  target="$1"
  port="$2"
  open_ports=$(nmap -p $port $target | grep -E '^[0-9]+/tcp' | awk '{print $1}')
  if [[ "$open_ports" == *"$port/tcp"* ]]; then
    echo "Port $port is OPEN"
  fi
}

# Get the target device IP from the user
target_ip=$(zenity --entry --title "Enter Target Device IP" --text "Please enter the IP address of the target device:")

# Check each port and notify if it's open
error_message=""
for port in "${ports[@]}"; do
  result=$(check_port "$target_ip" "$port")
  if [ -n "$result" ]; then
    error_message+="$result\n"
  fi
done

# Display error message using zenity if there are open ports
if [ -n "$error_message" ]; then
  zenity --error --title "Open Port Alert" --text "$error_message"
else
  zenity --info --title "Open Port Alert" --text "All ports on $target_ip are closed."
fi
