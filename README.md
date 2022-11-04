# kubernetes-homelab

Documentation around my kubernetes-homelab, setup, cluster bootstrapping and common apps.

My intention is to have a 4 node Kubernetes cluster, with 3 nodes acting as controllers,etcd hosts and workers, and one node acting only as a worker.

Each node will have taints applied so that certain workloads can be pinned to the machine that would best serve it's capabilities and requirements.
