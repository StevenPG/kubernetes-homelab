# The Second Node

Here comes the daunting part... adding the worker node to our cluster!

Actually, it's a lot simpler than we'd expect.

There's a few simple steps to go through

1. Generate the join command
2. Update our kubeadm join file
3. Give our new node admin access (optional)
4. Label our new node a worker (for now)

So lets get rolling

## Join Command

Generating the join command is simple. From the existing cluster, run 

    kubeadm token create --print-join-command

The command will have a token and config in it. Grab those and put it into our oldie-join.yaml file in this folder.

Add the same token in both fields. I'm naming this node "oldie" because reasons.

Make sure to set the cri-socket, and follow the steps in Part 4 for setting up CRI-O, since that's where our pods are going to be running.

Next, execute the join command using the below command from the new node (oldie in this case)

    sudo kubeadm join 192.168.1.201:6443 --config oldie-join.yaml

In moments, you'll be able to execute `kubectl get node` from your master node (rainbow in my case) and see oldie go from NotReady to Ready.

The kubeconfig file will be available in `/etc/kubernetes/kubelet.config`. We can rename that and add it to our home folder as `config`. That way kubectl will pick it up automatically. Worst comes to worst, as root if you execute `kubectl get node --kubeconfig /etc/kubernetes/kubelet.config`, it'll work just as well.

However, if you attempt to do this on oldie now, you'll get an error that says it doesn't have permissions.

Let's rectify that in a VERY bad way, that we'll come back and clean up later... probably.

In the Part 6 folder is a ClusterRoleBinding file called baremetal-cluster-admin.yaml.

In that file, we're adding oldie's default node role to the cluster-admin role, giving it permission to run basically any command.

Execute this file from our master node using `kubectl apply -f baremetal-cluster-admin.yaml`.

Now you can run `kubectl get node --kubeconfig /etc/kubernetes/kubelet.config` and you should get valid output from kubectl on the node details.

Just like that, we have an additional \<none> in our cluster when we look at our nodes. Lets fix that by adding a label

    kubectl label node oldie node-role.kubernetes.io/worker=worker

Now oldie is labeled a worker (as configured), and we have a perfectly happy two node cluster, one control-plane/etcd/worker node, and one dedicated worker node.

    NAME      STATUS   ROLES           AGE   VERSION
    oldie     Ready    worker          30m   v1.25.4
    rainbow   Ready    control-plane   40m   v1.25.4

However, we want oldie to be a master node. So we're going to clean it out by first going to rainbow (our sole master node) and running the following commands

    kubectl drain oldie --ignore-daemonsets
    kubectl delete node oldie

Now on oldie, we're going to run `sudo kubeadm reset --cri-socket=unix:///var/run/crio/crio.sock`

This will clean out oldie so we can rerun the steps needed to make oldie into a second master.

To prepare for our new master node, we also run:

    sudo kubeadm init phase upload-certs --upload-certs --config kubeadm-config.yaml
    [upload-certs] Storing the certificates in Secret "kubeadm-certs" in the "kube-system" Namespace
    [upload-certs] Using certificate key:
    someKey

This is going to print out our certificate key. Next, we'll run `sudo kubeadm token create --print-join-command` on our main node.

The result will be 

    kubeadm join 192.168.1.201:6443 --token some.token --discovery-token-ca-cert-hash sha256:someHash

On our other node, we're going to add some details, specifically our certificate-key from earlier and an additional `--control-plane` command.

     sudo kubeadm join 192.168.1.201:6443 --token some.token --discovery-token-ca-cert-hash sha256:someSha --control-plane --certificate-key=someCertKey --cri-socket=unix:///var/run/crio/crio.sock

Now we wait!

Follow the steps to get access to the 2 node master cluster using kubectl.

Next, lets remove the taint on oldie like we did on rainbow. From rainbow, run the following

    kubectl taint nodes <nodeName> node-role.kubernetes.io/control-plane:NoSchedule-

Section 7 will be setup of the next two nodes.