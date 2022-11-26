# Disk Mounting

If you recall, this is a 4 node cluster with 2 older, crappier machines acting as worker and worker/master, and 2 moderately new machines acting as worker/masters.

One of these nodes, rainbow, has an absolutely massive case that allowed me to input about 6TB of disk. Since the point of this cluster is to re-use old hardware, I'm sticking to using this node as the primary node for media sharing and streaming (only content that I own, to myself in the same home, of course).

## Mounting our drives

First, we're going to grab the paths of the storage devices. We configured these devices already when we did the installation, but if we look at the drives in `lsblk` and see something we don't like, we can make edits using `parted` or, my preference, `cfdisk`.

So, we'll run `lsblk` and get the following output:

    sdb                         8:16   0 931.5G  0 disk
    └─sdb1                      8:17   0 931.5G  0 part
    sdc                         8:32   0   1.8T  0 disk
    └─sdc1                      8:33   0   1.8T  0 part
    sdd                         8:48   0 698.6G  0 disk
    └─sdd1                      8:49   0 698.6G  0 part
    sde                         8:64   0 698.6G  0 disk
    └─sde1                      8:65   0 698.6G  0 part
    sdf                         8:80   0 931.5G  0 disk
    └─sdf1                      8:81   0 931.5G  0 part

That looks right, we have a dedicated partition for each disk that maps to the entire size of the disk. We can two pairs of identically sized disks, which is extremely tempting for some software RAID, but we can get to that later.

Lets create our mount folders for each one

    $ sudo mkdir /mnt/sdb
    $ sudo mkdir /mnt/sdc
    $ sudo mkdir /mnt/sdd
    $ sudo mkdir /mnt/sde
    $ sudo mkdir /mnt/sdf

Now we'll test it out by running the mount command for each drive

    $ sudo mount /dev/sd[a-z] /mnt/sd[a-z]

Good thing we tested! We just received the following error:

    mount: /mnt/sdb: wrong fs type, bad option, bad superblock on /dev/sdb, missing codepage or helper program, or other error.

Lets set the correct file system using `sudo mkfs.ext4 /dev/sdb`

We'll overwrite our existing partitions for each disk using the `mkfs` command, and then run the mount command for each disk to our new `/mnt` folder. Now our lsblk should look like this

    sdb                         8:16   0 931.5G  0 disk /mnt/sdb
    sdc                         8:32   0   1.8T  0 disk /mnt/sdc
    sdd                         8:48   0 698.6G  0 disk /mnt/sdd
    sde                         8:64   0 698.6G  0 disk /mnt/sde
    sdf                         8:80   0 931.5G  0 disk /mnt/sdf

More importantly, we can see how much storage we'll have available on this system using `df -h`

    /dev/sdb                           916G   28K  870G   1% /mnt/sdb
    /dev/sdc                           1.8T   28K  1.7T   1% /mnt/sdc
    /dev/sdd                           687G   28K  652G   1% /mnt/sdd
    /dev/sde                           687G   28K  652G   1% /mnt/sde
    /dev/sdf                           916G   28K  870G   1% /mnt/sdf

However, we need this to persist on startup, so lets add it to our `/etc/fstab` file.

We're going to add the disk by id instead of by name, that way if we mess around with the disks, they'll always mount correctly. Even if the name changes for some reason.

It's simple to grab the IDs (IDs have been replaced)

    $ ls -l /dev/disk/by-uuid
    total 0
    lrwxrwxrwx 1 root root  9 Nov 26 15:22 d2e5f8c2-70dc-4c67-af68-7bc37b8a0e71 -> ../../sdb
    lrwxrwxrwx 1 root root  9 Nov 26 15:23 7c61238a-8b7c-450b-8b31-3a6302a8e404 -> ../../sdd
    lrwxrwxrwx 1 root root  9 Nov 26 15:24 4bc7d983-3ce1-4722-a1c8-6201d38dff55 -> ../../sdf
    lrwxrwxrwx 1 root root  9 Nov 26 15:23 c5dfee34-cf18-4d29-9159-78b927b61074 -> ../../sdc
    lrwxrwxrwx 1 root root  9 Nov 26 15:24 c36d3d12-da21-4576-a0ed-bb2fe881abfe -> ../../sde

And we'll add them to `/etc/fstab` (again, random values here, not actual disk UUIDs)

    /dev/disk/by-uuid/d2e5f8c2-70dc-4c67-af68-7bc37b8a0e71 /mnt/sdb ext4 defaults 0 0
    /dev/disk/by-uuid/c5dfee34-cf18-4d29-9159-78b927b61074 /mnt/sdc ext4 defaults 0 0
    /dev/disk/by-uuid/7c61238a-8b7c-450b-8b31-3a6302a8e404 /mnt/sdd ext4 defaults 0 0
    /dev/disk/by-uuid/c36d3d12-da21-4576-a0ed-bb2fe881abfe /mnt/sde ext4 defaults 0 0
    /dev/disk/by-uuid/4bc7d983-3ce1-4722-a1c8-6201d38dff55 /mnt/sdf ext4 defaults 0 0

Now all of our drives should be mounted, and we can move onto setting up NFS, which will be our backing storage for the entire kubernetes cluster.

Because this is a test cluster where I'm just going to be running some workloads and messing around, we're not worried about redundancy or high availability just yet. All the storage on this cluster will be sourced from our main node with all of the storage directly.
