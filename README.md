# kubernetes-homelab
Documentation around my kubernetes-homelab, setup, cluster bootstrapping and common apps.

My intention is to have a 4 node Kubernetes cluster, with 3 nodes acting as controllers,etcd hosts and workers, and one node acting only as a worker.

Each node will have taints applied so that certain workloads can be pinned to the machine that would best serve it's capabilities and requirements.

# Physical Preperations

All the components needed for this setup are:

1. N physical machines, each with at least one harddrive and enough processing power to run Ubuntu
2. One 16GB+ flash drive to install the Ubuntu server ISO on
3. At least One keyboard, monitor, mouse combo

My personal preparations are as follows:

| Machine     | CPU | RAM |
| ----------- | ----------- | ----------- |
| Gaming Desktop 1      | i5 6500       | 16GB       |
| Gaming Desktop 2      | AMD 8 core Bulldozer       | 8GB       |
| School District Desktop   | Old i3        |4GB       |
| Old HR Manager Desktop   | Old i3        |2GB       |

Some of these are old personal machines, others came from eBay or friends of friends who were throwing away perfectly crappy computers!

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

Leaving me with a grand total of 6 Terabytes!

That's at least one per machine! Assuming at least one system is set up and plugged in with network access, we're good to go!

# Software Preparations

We only need one thing to get started, the aforementioned flash drive with ubuntu installed.

I did this using [Rufus](https://rufus.ie/en/) on a Windows computer. I installed [Rufus](https://rufus.ie/en/) and then downloaded [Ubuntu](https://ubuntu.com/download/server)'s latest server distribution. As of writing, that is [22.04.1 LTS](https://discourse.ubuntu.com/t/jammy-jellyfish-release-notes/24668?_ga=2.24881274.1343425226.1665932151-444169069.1665932151).

# Starting one machine at a time

For this write-up, I'm going to follow my actual steps taken. This will included standing up a single node cluster first, before shifting to configure the full cluster and have everything running together (all 4 nodes).

