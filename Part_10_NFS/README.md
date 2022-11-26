# NFS

Kubernetes storage management feels like learning an entire application framework in and of itself, but I'm going to try to capture some small part of it here. The first part will be the installation and setup of NFS, the second will be configuring the share in the cluster.

## Setting up NFS on our main disk node

First we're going to install the required components to run the NFS server, specifically by running

    sudo apt update
    sudo apt install nfs-kernel-server

I'm not sure we need it, but just for follow-through, we're going to install the `nfs-common` package on the client (and nfs) nodes.

    sudo apt update
    sudo apt install nfs-common

