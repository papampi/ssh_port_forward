#!/bin/bash

# Set the SSH credentials for server B
username="your_ssh_username"
password="your_ssh_password"
server_ip="your_server_ip"
ssh_port="your_server_ssh_port"

# Set the IP address range to forward
ip_range="miners_first_3_octet" #I.E "192.168.1"
start_ip="start_ip" #i.e:"5"
end_ip="end_ip" #i.e: "25"

# Set the range of local ports to forward to
start_port=8001
end_port=8555

# Check if end_ip is not less than start_ip
if [[ $end_ip -lt $start_ip ]]; then
    echo "Ending IP address cannot be less than starting IP address. Please fix it "
    exit 1
fi

# Check the operating system
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
  # Linux OS detected
  echo "Linux OS detected."
  
  # Check if sshpass is installed and install it if necessary
  if ! command -v sshpass >/dev/null 2>&1; then
      echo "sshpass is not installed. Installing now..."
      sudo apt-get install sshpass -y
  fi
elif [[ "$OSTYPE" == "darwin"* ]]; then
  # macOS detected
  echo "macOS detected."
  
  # Check if Homebrew is installed
  if ! command -v brew >/dev/null 2>&1; then
      echo "Homebrew is not installed. Installing now..."
      /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi

  # Check if sshpass is installed and install it if necessary
  if ! command -v sshpass >/dev/null 2>&1; then
      echo "sshpass is not installed. Installing now..."
      brew install https://raw.githubusercontent.com/kadwanev/bigboybrew/master/Library/Formula/sshpass.rb
  fi
else
  # Unsupported operating system
  echo "Unsupported operating system. This script only supports Linux and macOS."
  exit 1
fi

# Check if the SSH key pair already exists
if [ ! -f "$HOME/.ssh/id_rsa" ]; then
    # SSH key pair does not exist, generate new SSH key pair
    echo "SSH key pair not found. Generating new SSH key pair..."
    ssh-keygen -t rsa -N "" -f "$HOME/.ssh/id_rsa"
else
    echo "SSH key pair found."
fi

# Check if the public key is available on the remote host
if ! ssh -q "$ssh_port $username@$server_ip" 'exit' >/dev/null 2>&1; then
  # Public key is not available, copy public key to remote host
  echo "Public key not found on remote host. Copying public key to remote host..."
  sshpass -p $password ssh-copy-id -p $ssh_port $username@$server_ip
fi

# Connect using ssh
for ((i=start_ip;i<=end_ip;i++)); do
  ip="$ip_range.$i"
  echo "Forwarding $ip:22 to localhost:$start_port"
  ssh -nNT -L $start_port:$ip:22 -p $ssh_port $username@$server_ip &
  ((start_port++))
  echo "Forwarding $ip:80 to localhost:$start_port"
  ssh -nNT -L $start_port:$ip:80 -p $ssh_port $username@$server_ip &
  ((start_port++))
  sleep 1
done

# Function to close all SSH sessions
function close_ssh_sessions {
    echo "Closing all SSH sessions..."
    pkill -f "ssh -nNT -L"
}

# Trap to close all SSH sessions on script exit
trap close_ssh_sessions EXIT

# Wait for user input to close SSH sessions
read -p "Press enter to exit and close all SSH sessions..."
