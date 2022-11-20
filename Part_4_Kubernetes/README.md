# Kubernetes

## Installing and Setting up Kubernetes Dependencies

First, we're going to decide on a Kubernetes deployment mechanism. Rather than use k3s, which auto-configures a lot of stuff for you out of the box, we're going to go with kubeadm. This is still cutting out MANY of the steps it takes to manually set up Kubernetes, but it's a bit closer to the metal. It's also managed by the Kubernetes team, so we aren't dependent on another organization for our documentation and support (Rancher team).

### Network Check

Before we can start anything, we need to verify that the MAC address is unique for each network device we plan on adding to our cluster. MAC addresses are tied to the network hardware. If we're using actual bare-metal machines (like I am), this is just a verification step.

However, if you're going through the guide (or any other kube installation), you'll want to make sure your VMs have unique network MAC addresses. Kubernetes uses these addresses to differentiate the nodes in the cluster.

We can check this by running `sudo cat /sys/class/dmi/id/product_uuid` on each node and verifying a unique UUID is reported back.

### Installing Kubernetes Dependencies

Initially I planned on using Ansible to do these installations, but Kubeadm is so easy to use, that we're going to just walk through the steps manually, since it's only a few script executions.

Speaking of script executions, onto the first! We're running these on all 4 nodes.

#### Docker

Installing docker is fairly straightforward

    sudo apt update
    sudo apt install docker.io
    # Wait for docker to finish installing
    sudo systemctl start docker
    sudo systemctl enable docker
    sudo docker ps
    # Expect to see standard docker results
    sudo docker run hello-world

By the end of this section, you should see the "Hello From Docker!" results from executing hello-world.

#### CRI-O

As of version 1.24 of Kubernetes, the dockershim is removed and therefore, while we can use docker as a generic runtime engine, we can't use it to underpin Kubernetes. So we're going to use cri-o instead.

Following this guide, we'll perform the installation: https://computingforgeeks.com/install-cri-o-container-runtime-on-ubuntu-linux/

    OS=xUbuntu_20.04
    CRIO_VERSION=1.23
    echo "deb https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/$OS/ /"|sudo tee /etc/apt/sources.list.d/devel:kubic:libcontainers:stable.list
    echo "deb http://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable:/cri-o:/$CRIO_VERSION/$OS/ /"|sudo tee /etc/apt/sources.list.d/devel:kubic:libcontainers:stable:cri-o:$CRIO_VERSION.list

    # Import GPG keys
    curl -L https://download.opensuse.org/repositories/devel:kubic:libcontainers:stable:cri-o:$CRIO_VERSION/$OS/Release.key | sudo apt-key add -
    curl -L https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/$OS/Release.key | sudo apt-key add -

Now that we've added the latest CRI-O packages, we'll install them.

    # Install packages
    sudo apt update
    sudo apt install cri-o cri-o-runc

    # Check version using
    apt show cri-o

Similar to how we set up docker, we'll start cri-o-runc

    sudo systemctl enable crio.service
    sudo systemctl start crio.service
    # Check we're up and running with
    systemctl status crio

Much like the `docker` command, cri-o has the crictl tool, we'll install that with

    sudo apt install cri-tools
    # Check installation
    sudo crictl info

#### Kube Components

Same as docker and cri-o, these commands are pretty simple to execute.

    sudo apt-get update
    sudo apt-get install -y apt-transport-https ca-certificates curl
    sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
    echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
    sudo apt-get update
    sudo apt-get install -y kubelet kubeadm kubectl

    # This will keep the versions from updating, which is important when using kubernetes as the client/server versions must stay mostly in sync
    sudo apt-mark hold kubelet kubeadm kubectl

### Bootstrapping our Cluster

Now the fun begins.

If you execute `service status kubelet` you should see it's failing. This is because it's waiting for instructions from kubeadm on what to do next.

We're gonna first choose our biggest machine, the one with all the storage and the most CPUs, and use that as our initial bootstrapping host.

We're going to execute a simple `kubeadm init` on this node and follow the prompts.

For this guide, we're grabbing the latest version of kubernetes, which at time of writing was 1.25.1. So after running kubeadm init, once we can see our downloaded kubernetes version, we're going to install that version of kubectl before continuing. This can be done using the following commands:

    curl -LO https://dl.k8s.io/release/v1.25.0/bin/linux/amd64/kubectl
    sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
    sudo kubectl version --client

The output should display the correct version.

### Uh oh, kubeadm failed

If we have any trouble with kubeadm, we can restart the process using

    kubeadm reset
    sudo apt-get purge kubeadm kubectl kubelet kubernetes-cni kube*   
    sudo apt-get autoremove  
    sudo rm -rf ~/.kube

And then restarting the machine.

During my installation, I ran into a failure with kubeadm. The error from startup looked like this:

    This error is likely caused by:
        - The kubelet is not running
        - The kubelet is unhealthy due to a misconfiguration of the node in some way (required cgroups disabled)

We can set our cgroups driver by overriding the docker defaults using the following configuration file `/etc/docker/daemon.json`

    {
        "exec-opts": ["native.cgroupdriver=systemd"]
    }

We can check that this worked using `sudo docker info | grep Cgroup`. We expect to see the following result:

    Cgroup Driver: systemd
    Cgroup Version: 2

Then I reset kubeadm using `sudo kubeadm reset`

Before restarting everything

    sudo systemctl daemon-reload
    sudo systemctl restart docker
    sudo systemctl restart kubelet

Now we'll re-execute `sudo kube-adm init`

However, I ran into yet another problem. After doing some searching, it looks like swap being on is not fully supported, although the error message says it should be disabled for production.

So we'll disable swap using the following

    # Lets reset again for a clean next pass
    sudo kubeadm reset
    # Disables swap until restart
    sudo swapoff -a
    # Remove any lines that have swap devices, you can check these names using 
    cat /proc/swaps
    # Remove swap volumes
    vi /etc/fstab

Now we'll restart the machine and bring our terminal back up once the SSH server is up. Walk away, make some coffee!

...

Ok, we're back. Lets run `sudo kubeadm init` with some additional bits.

We set our cgroup driver to systemd, which means all we need to do to link up with cri-o is the following:

    # We could run this command, however we may run into issues with certain tools that expect more kube configuration
    sudo kubeadm init --pod-network-cidr=192.169.0.0/16 --cri-socket=unix:///var/run/crio/crio.sock

So we're going to run the following command instead

    sudo kubeadm init --config kubeadm-config.yaml --upload-certs

Since we've provided a controlPlane URL in our config file, other nodes are eligible to be masters (eventually). We're going to run `--upload-certs` so that other nodes will be able to download our certs. We'll see this in Step 6!

This kubeadm config yaml contains an additional SAN and other configurations that should handle any missing pieces. We can also use a configuration file like this to join to the kubeadm cluster! All of the kubeadm config options are available here: https://pkg.go.dev/k8s.io/kubernetes/cmd/kubeadm/app/apis/kubeadm/v1beta2#hdr-Migration_from_old_kubeadm_config_versions

Also it's worth mentioning, if you follow another tutorial or these issues don't happen for you, you can just skip along. I'm documenting what happened to me as I worked through the full setup.

Success! We now have a join command that we're going to save into a local text file.

We can now check the node by executing `kubectl get node`

    NAME      STATUS     ROLES           AGE     VERSION
    rainbow   NotReady   control-plane   4m46s   v1.25.4

From here, we need to install our CNI plugins. We're going to use canal because it takes the best from Calico and Flannel. We can do this using two simple commands:

    curl https://raw.githubusercontent.com/projectcalico/calico/v3.24.5/manifests/canal.yaml -O
    kubectl apply -f canal.yaml

Now we watch the fireworks with `watch kubectl get pods --all-namespaces`

After a little while, you should see everything up and running!
 
    NAMESPACE     NAME                                       READY   STATUS    RESTARTS   AGE
    kube-system   calico-kube-controllers-798cc86c47-th574   1/1     Running   0          84s
    kube-system   canal-4px6q                                2/2     Running   0          84s
    kube-system   coredns-565d847f94-54qgj                   1/1     Running   0          13m
    kube-system   coredns-565d847f94-5m6hj                   1/1     Running   0          13m
    kube-system   etcd-rainbow                               1/1     Running   54         13m
    kube-system   kube-apiserver-rainbow                     1/1     Running   53         13m
    kube-system   kube-controller-manager-rainbow            1/1     Running   0          13m
    kube-system   kube-proxy-24jrx                           1/1     Running   0          13m
    kube-system   kube-scheduler-rainbow                     1/1     Running   59         13m
