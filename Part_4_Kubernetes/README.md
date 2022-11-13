# Kubernetes

## Installing and Setting up Kubernetes Dependencies

First, we're going to decide on a Kubernetes deployment mechanism. Rather than use k3s, which auto-configures a lot of stuff for you out of the box, we're going to go with kubeadm. This is still cutting out MANY of the steps it takes to manually set up Kubernetes, but it's a bit closer to the metal. It's also managed by the Kubernetes team, so we aren't dependent on another organization for our documentation and support (Rancher team).

### Network Check

Before we can start anything, we need to verify that the MAC address is unique for each network device we plan on adding to our cluster. MAC addresses are tied to the network hardware. If we're using actual bare-metal machines (like I am), this is just a verification step.

However, if you're going through the guide (or any other kube installation), you'll want to make sure your VMs have unique network MAC addresses. Kubernetes uses these addresses to differentiate the nodes in the cluster.

We can check this by running `sudo cat /sys/class/dmi/id/product_uuid` on each node and verifying a unique UUID is reported back.

### Installing Kubernetes Dependencies

We're going to create an ansible working folder for ourselves.

    cd ~
    mkdir ansible
    cd ansible

Easy enough!
