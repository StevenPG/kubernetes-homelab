# First things first

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

`ssh user@ip-address`

## Setting a static IP

So that our nodes don't change IP address, we're going to set them up so that they request a static IP from the router each time they restart.

First we're going to run `ip a` on each node. This will tell us wheat IP `eth0` is configured with currently. For simplicity, we'll make that the static local ip.

Note, this is only for your local network, any guides or intent to have a static IP externally following these steps WILL NOT WORK.

Once we know the IP we want to set (I'm doing this across 4 machines as I write this), navigate to the following folder `/etc/netplan`. This is the iterative configuration for setting up network components in this version of Ubuntu.

Much like flyway or liquibase, we're going to ignore the pre-existing files (e.g.)

    00-installer-config-wifi.yaml  00-installer-config.yaml

and instead create a new file, prepended with 01-\<filename>

Execute the following command:

    sudo vi /etc/netplan/01-netcfg.yaml

Add the following content into the file

    network:
        version: 2
        renderer: networkd
        ethernets:
            eth0:
                addresses:
                    - 192.168.1.123/24
                nameservers:
                    addresses: [8.8.8.8, 8.8.4.4]
                routes:
                    - to: default
                      via: 192.168.1.1

Then change the following fields:

- ethernets.eth0.address = your preferred static internal IP
- ethernets.eth0.nameservers.address = your preferred pair of DNS nameservers
- ethernets.eth0.routes.via = your router's gateway ip

Then we'll execute `sudo netplan apply`.

## Installing our basic packages

We're going to utilize some automation to configure these nodes, so that these steps are easier to follow in the future, or if a node dies, or a new node gets added to the cluster.

We're going to execute the following commands in order

- `sudo apt update`
- `sudo apt-get update`
- `sudo apt install neofetch`

We're also installing neofetch because it's a clever little way to print out the machine specifications whenever we want to remind ourselves what resources we have available. (That is, until Kube is configured!)

## TODO -- disable swap across all nodes!

I skipped this step for brevity, need to perform it and add it here. Probably after configuring the mounts on the big 6T box
