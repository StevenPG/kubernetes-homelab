# Disk Mounting

If you recall, this is a 4 node cluster with 2 older, crappier machines acting as worker and worker/master, and 2 moderately new machines acting as worker/masters.

One of these nodes, rainbow, has an absolutely massive case that allowed me to input about 6TB of disk. Since the point of this cluster is to re-use old hardware, I'm sticking to using this node as the primary node for media sharing and streaming (only content that I own, to myself in the same home, of course).

## Mounting our drives

TODO

https://linuxhint.com/how-to-mount-drive-in-ubuntu/

1. List the disks
2. verify they're all configured properly
3. add to /etc/fstab
4. document layout and naming here for NFS bits