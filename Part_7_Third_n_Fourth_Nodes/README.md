# Third and Fourth nodes!

Good news! Setting up the 3rd and 4th nodes just requires following step 4 and 6 again. However, our 4th node is going to ONLY be a worker and node a control plane node. This will give us a 4 node cluster with 3 master/worker pairs and a quorum of 3 nodes.

For the sake of brevity, I won't be rehasing the steps here, but will present the results!

    NAME      STATUS   ROLES           AGE     VERSION   INTERNAL-IP     EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION      CONTAINER-RUNTIME
    hp        Ready    <none>          6m44s   v1.25.4   192.168.1.198   <none>        Ubuntu 22.04.1 LTS   5.15.0-53-generic   containerd://1.5.9-0ubuntu3
    oldie     Ready    control-plane   16m     v1.25.4   192.168.1.199   <none>        Ubuntu 22.04.1 LTS   5.15.0-53-generic   cri-o://1.23.4
    rainbow   Ready    control-plane   17m     v1.25.4   192.168.1.201   <none>        Ubuntu 22.04.1 LTS   5.15.0-53-generic   cri-o://1.23.4
    school    Ready    control-plane   6m40s   v1.25.4   192.168.1.202   <none>        Ubuntu 22.04.1 LTS   5.15.0-53-generic   containerd://1.5.9-0ubuntu3

Also, jokes on you (and me), for whatever reason, containerd doesn't seem to be working, so my school and hp nodes are failing to bring any containers up, while the cri-o nodes are working fine. So we're going to remove docker from hp and school using the following commands

    sudo apt-get remove containerd 
    sudo apt-get remove --auto-remove containerd 
    sudo apt-get purge containerd 