# Kube Tooling

## Helm

We're going to install Helm natively on our primary machine next, since Helm will allow us to install a some tools without just copy-pasting `kubectl apply` commands pointing to the internet.

Snap is enabled by default in Ubuntu 22.04 Jammy, so we're just going to simply run the snap command to install Helm.

    $ sudo snap install helm --classic
    helm 3.7.0 from Snapcrafters installed
    $ helm version
    version.BuildInfo{Version:"v3.7.0", GitCommit:"eeac83883cb4014fe60267ec6373570374ce770b", GitTreeState:"clean", GoVersion:"go1.16.8"}

## Kube Metrics Server

To get a baseline of how our machine is handling our new single-node Kubernetes cluster, we can attempt to run the `kubectl top` command

    $ kubectl top node rainbow
    error: Metrics API not available

The Metrics Server is super useful and a lot of Kubernetes monitoring tools use it. So we're going to install it.

The documentation is available in the kubernetes-sigs repository, located here: https://github.com/kubernetes-sigs/metrics-server

Since we have Helm available, we're just going to use that to install the metrics server.

    $ helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server/
    "metrics-server" has been added to your repositories
    $ helm upgrade --install metrics-server metrics-server/metrics-server
    Release "metrics-server" does not exist. Installing it now.
    NAME: metrics-server
    LAST DEPLOYED: Wed Nov 00 00:00:00 0000
    NAMESPACE: default
    STATUS: deployed
    REVISION: 1
    TEST SUITE: None
    NOTES:
    ***********************************************************************
    * Metrics Server                                                      *
    ***********************************************************************
    Chart version: 3.8.2
    App version:   0.6.1
    Image tag:     k8s.gcr.io/metrics-server/metrics-server:v0.6.1
    ***********************************************************************

Now we can run `kubectl get pods` and we'll see the metrics server is deployed in our default namespace.

    $ kubectl get pods
    NAME                              READY   STATUS    RESTARTS   AGE
    metrics-server-7f4db5fd87-954qq   0/1     Pending   0          41s

It looks like it didn't stand up though... lets use `kubectl describe pod metrics-server-xxxx` and see what the issue is.

    Warning  FailedScheduling  61s   default-scheduler  0/1 nodes are available: 1 node(s) had untolerated taint {node-role.kubernetes.io/control-plane: }. preemption: 0/1 nodes are available: 1 Preemption is not helpful for scheduling.

Oh right, we never linked up a worker node. Lets make this system a worker node!

We can look at our taints by running `kubectl describe node`

Lets remove the control plane taint that's configured on our single node machine using

    # The minus at the end is what removes the taint
    kubectl taint nodes <nodeName> node-role.kubernetes.io/control-plane:NoSchedule-

Now we rerun our `kubectl describe pod metrics-server-xxxx`

    Events:
    Type     Reason            Age   From               Message
    ----     ------            ----  ----               -------
    Warning  FailedScheduling  82s   default-scheduler  0/1 nodes are available: 1 node(s) had untolerated taint {node-role.kubernetes.io/control-plane: }. preemption: 0/1 nodes are available: 1 Preemption is not helpful for scheduling.
    Normal   Scheduled         3s    default-scheduler  Successfully assigned default/metrics-server-7f4db5fd87-zw95g to rainbow
    Normal   Pulled            3s    kubelet            Container image "k8s.gcr.io/metrics-server/metrics-server:v0.6.1" already present on machine
    Normal   Created           3s    kubelet            Created container metrics-server
    Normal   Started           3s    kubelet            Started container metrics-server

Everything wires up perfectly!

All of this effort was just so we could simply run the `kubectl top` command, so lets do it!

    "Failed to scrape node" err="Get \"https://192.168.1.201:10250/metrics/resource\": x509: cannot validate certificate for 192.168.1.201 because it doesn't contain any IP SANs" node="rainbow"

Ok, well new issue. Lets resolve this by editing the metrics-server config

    kubectl edit deploy metrics-server

Navigate to the `spec.template.spec.containers[0].args` section and add `- --kubelet-insecure-tls`

We'll address this in the future and do certificates properly... probably.

Now running `kubectl top node`!

    NAME      CPU(cores)   CPU%   MEMORY(bytes)   MEMORY%
    rainbow   381m         4%     2909Mi          37%

Woot!

To recap, we now have a working single-node Kube cluster with a working CNI plugin, a metrics server serving up our resources usage per node and container.
