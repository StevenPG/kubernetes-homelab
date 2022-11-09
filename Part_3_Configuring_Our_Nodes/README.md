# First things first!

We need to get access to our nodes and then actually access them.

There's a handy little script in this folder called `nmap_script.sh`

We're cheating a little bit because the Ubuntu Server installer we used allowed us to install OpenSSH Server on installation! So we get to skip the steps
that we usually have to do, where you plug a monitor and keyboard into each machine, record its IP and MAC address, install OpenSSH Server, etc.

We can just run a port scan from another trusty Linux-based machine using nmap.

    Starting Nmap 7.80 ( https://nmap.org ) at 2022-10-09 00:00 EST
    Nmap scan report for <ip>
    Host is up (0.0029s latency).

    PORT   STATE SERVICE
    22/tcp open  ssh
    MAC Address: --- (System 1)

    Nmap scan report for <ip>
    Host is up (0.014s latency).

    Nmap done: 256 IP addresses (N hosts up) scanned in 9.64 seconds

    ## Connecting!

Each of the IP address and hostnames should be listed when you run nmap. (If they aren't, you can always fall back to the trusty dedicated monitor+keyboard and hostname command)

From here, we're going to execute our SSH commands. We recorded our username and password when we installed Ubuntu Server, so we have those on hand.

