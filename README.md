# ssh_port_forward
SSH Port Forward/Tunneling Script

This script sets up an SSH tunnel to forward traffic from a specified IP address range on a remote server to a range of local ports on the client machine. It prompts the user for the necessary input, including the SSH credentials for the remote server, the IP address range to forward, and the range of local ports to forward to.

The script uses `sshpass` to automate password authentication and avoid the need for manual input of passwords. If `sshpass` is not installed on the client machine, the script will attempt to install it using the appropriate package manager for the operating system.

The script also checks if the SSH key pair already exists on the client machine. If the key pair does not exist, the script will generate a new key pair. If the public key is not available on the remote server, the script will copy the public key to the remote server to enable passwordless SSH authentication.

Finally, the script adds an alias for the remote server to the `~/.bash_aliases` file on the client machine, allowing the user to easily connect to the server by typing the alias in the terminal.

**Operating System Support:** This script has been tested on Linux and macOS. It should work on other Unix-based operating systems as well, as long as the necessary dependencies are installed.

Feel free to modify and use this script as needed for your own purposes.
