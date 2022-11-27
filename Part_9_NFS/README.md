# NFS

Kubernetes storage management feels like learning an entire application framework in and of itself, but I'm going to try to capture some small part of it here. The first part will be the installation and setup of NFS, the second will be configuring the share in the cluster.

## Setting up NFS on our main disk node

First we're going to install the required components to run the NFS server, specifically by running

    sudo apt update
    sudo apt install nfs-kernel-server

I'm not sure we need it, but just for follow-through, we're going to install the `nfs-common` package on the client (and nfs) nodes.

    sudo apt update
    sudo apt install nfs-common

Now that everything is installed, we're going to create some NFS mounts on each of our extended drives:

    $ sudo mkdir /mnt/sdb/nfs
    $ sudo mkdir /mnt/sdc/nfs
    $ sudo mkdir /mnt/sdd/nfs
    $ sudo mkdir /mnt/sde/nfs
    $ sudo mkdir /mnt/sdf/nfs

Next is editing the file that was created during the installation of `nfs-kernel-server` to provide ONLY our other nodes NFS access.

    /mnt/sdb/nfs    192.168.1.0/24(rw,sync,no_subtree_check)
    /mnt/sdc/nfs    192.168.1.0/24(rw,sync,no_subtree_check)
    /mnt/sdd/nfs    192.168.1.0/24(rw,sync,no_subtree_check)
    /mnt/sde/nfs    192.168.1.0/24(rw,sync,no_subtree_check)
    /mnt/sdf/nfs    192.168.1.0/24(rw,sync,no_subtree_check)

This setup ensures that ONLY the local kubernetes nodes can communicate back to this main node, including the local system to itself. We'll see whether it uses it's NATed IP or localhost as soon as we try to test from Kubernetes!

Now we'll restart nfs-kernel-server with `sudo systemctl restart nfs-kernel-server`

Now our next steps would typically be to create mount points on the client. However, since we're doing everything through Kubernetes, we're going to just set up the NFS storage driver in Kubernetes instead.

## Provisioning NFS "shares"

First, we'll install the application that will do our NFS connections and provisioning.

We'll install this using helm (https://github.com/kubernetes-sigs/nfs-subdir-external-provisioner/blob/master/charts/nfs-subdir-external-provisioner/README.md)

    $ helm repo add nfs-subdir-external-provisioner https://kubernetes-sigs.github.io/nfs-subdir-external-provisioner/

We know we're going to want to create a dedicated mount per nfs share we're exporting, so we're gonna have bunch of commands here

    helm install sdb-nfs-client nfs-subdir-external-provisioner/nfs-subdir-external-provisioner \
    --create-namespace \
    --namespace nfs-client \
    --set nfs.server=192.168.1.201 \
    --set nfs.path=/mnt/sdb/nfs \
    --set storageClass.name=sdb-nfs-client \
    --set storageClass.reclaimPolicy=Retain \
    --set storageClass.provisionerName=k8s-sigs.io/sdb-nfs-client;

    helm install sdc-nfs-client nfs-subdir-external-provisioner/nfs-subdir-external-provisioner \
    --namespace nfs-client \
    --set nfs.server=192.168.1.201 \
    --set nfs.path=/mnt/sdc/nfs \
    --set storageClass.name=sdc-nfs-client \
    --set storageClass.reclaimPolicy=Retain \
    --set storageClass.provisionerName=k8s-sigs.io/sdc-nfs-client;

    helm install sdd-nfs-client nfs-subdir-external-provisioner/nfs-subdir-external-provisioner \
    --namespace nfs-client \
    --set nfs.server=192.168.1.201 \
    --set nfs.path=/mnt/sdd/nfs \
    --set storageClass.name=sdd-nfs-client \
    --set storageClass.reclaimPolicy=Retain \
    --set storageClass.provisionerName=k8s-sigs.io/sdd-nfs-client;

    helm install sde-nfs-client nfs-subdir-external-provisioner/nfs-subdir-external-provisioner \
    --namespace nfs-client \
    --set nfs.server=192.168.1.201 \
    --set nfs.path=/mnt/sde/nfs \
    --set storageClass.name=sde-nfs-client \
    --set storageClass.reclaimPolicy=Retain \
    --set storageClass.provisionerName=k8s-sigs.io/sde-nfs-client;

    helm install sdf-nfs-client nfs-subdir-external-provisioner/nfs-subdir-external-provisioner \
    --namespace nfs-client \
    --set nfs.server=192.168.1.201 \
    --set nfs.path=/mnt/sdf/nfs \
    --set storageClass.name=sdf-nfs-client \
    --set storageClass.reclaimPolicy=Retain \
    --set storageClass.provisionerName=k8s-sigs.io/sdf-nfs-client;

And there we have it!

    $ helm ls -n nfs-client
    NAME            NAMESPACE    REVISION   STATUS          CHART                                   APP VERSION
    metrics-server  default      1          deployed        metrics-server-3.8.2                    0.6.1
    sdb-nfs-client  default      1          deployed        nfs-subdir-external-provisioner-4.0.17  4.0.2
    sdc-nfs-client  default      1          deployed        nfs-subdir-external-provisioner-4.0.17  4.0.2
    sdd-nfs-client  default      1          deployed        nfs-subdir-external-provisioner-4.0.17  4.0.2
    sde-nfs-client  default      1          deployed        nfs-subdir-external-provisioner-4.0.17  4.0.2
    sdf-nfs-client  default      1          deployed        nfs-subdir-external-provisioner-4.0.17  4.0.2
    sgantz@rainbow:~$

We can now run `kubectl get pods` and see our nfs provisioners deploying on our kubernetes cluster!

However, they're all failing!

Looking at the logs, it looks like the NFS mounting is failing `Output: mount.nfs: access denied by server while mounting 192.168.1.201:/mnt/sdc/nfs`

Behind the scenes I've gone and updated the permissions on these mounts so that they should work correctly from the host, if you're following along, this is on you to figure out!

However, now we can restart the deployments for our provisioners and see whether everything is wired up correctly now.

We can do this by blowing away the pods individually using `kubectl delete pod <podName>`

We can also remove all of the installations by executing

    helm uninstall sdb-nfs-client sdc-nfs-client sdd-nfs-client sde-nfs-client sdf-nfs-client -n nfs-client

Just like that, we're setup! We now have storage from any node on the cluster. This theoretically means that we can run any workload on any node and there should be no reason it doesn't work.

However, we'll likely add taints for performance reasons, since some machines are incredibly slow while others are much more powerful.
