# Physical Preperations

All the components needed for this setup are:

1. N physical machines, each with at least one harddrive and enough processing power to run Ubuntu
2. One 16GB+ flash drive to install the Ubuntu server ISO on
3. At least One keyboard, monitor, mouse combo

Some of my nodes are old personal machines, others came from eBay or friends of friends who were throwing away perfectly crappy computers!

Now onto storage. I picked up a new 2TB 5400RPM WD Red NAS HDD, and a 500GB WD Blue SSD.

Then I opened a drawer I haven't opened in years and found additional drives! Everything is enumerated below:

My total available storage is now the following:

1. 500GB WD Blue SSD (2.5) NEW!
2. 2TB WD Red HDD (3.5) NEW!
3. Seagate 750GB Hybrid SSD (2.5) Old laptop!
4. PNY 250GB SSD (2.5) Old desktop!
5. 1TB Samsung HDD (2.5)
6. 750GB HGST 750GB HDD (2.5)
7. 200GB Toshiba HDD (2.5)
8. 20GB Seagate HDD (2.5)
9. 1TB Toshiba HDD (3.5)

Leaving me with a grand total of 7 Terabytes!

That's at least one per machine! Assuming at least one system is set up and plugged in with network access, we're good to go!

## Software Preparations

We only need one thing to get started, the aforementioned flash drive with ubuntu installed.

I did this using [Rufus](https://rufus.ie/en/) on a Windows computer. I installed [Rufus](https://rufus.ie/en/) and then downloaded [Ubuntu](https://ubuntu.com/download/server)'s latest server distribution. As of writing, that is [22.04.1 LTS](https://discourse.ubuntu.com/t/jammy-jellyfish-release-notes/24668?_ga=2.24881274.1343425226.1665932151-444169069.1665932151).

## Server Names and Details

As they say, the hardest thing about computer science is naming things and off-by-one errors.

But we're going to try to set up the servers with the following hostnames; rainbow, oldie, school and hp

Final cluster layout (in kube terms):

| hostnam     | CPU | RAM | GPU | DISK |
| ----------- | ----------- | ----------- | -- | -- |
| rainbow      |  AMD FX-8120 (8) @ 3.100GHz | 7896MiB (8GB) | NVIDIA GeForce GTX 1050 Ti | 6001.3G
| oldie      | Intel i5-6500 (4) @ 3.600GHz | 15889MiB (16GB) | Intel HD Graphics 530 | 221.6G
| school   | Intel Core 2 Duo E8400 (2) @ 2.071GHz |3785MiB (4GB) | Intel 82Q35 Express | 232.9G
| hp   | Intel i5-8400 (6) @ 4.000GHz |7772MiB (8GB) | Intel CoffeeLake-S GT2 [UHD Graphics 630] | 183.3G
