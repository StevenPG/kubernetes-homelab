# This will show all systems on your network that has port 22 open. Replace 192.168.10.0 with your local network mask (e.g. 10.0.0.0/25)
sudo nmap -sS --open -p 22 192.168.10.0/24