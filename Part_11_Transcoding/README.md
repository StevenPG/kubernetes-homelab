# Pivot

SO, turns out the server I'm using to stream files over plex isn't powerful enough to do the transcoding I planned for it.

Therefore, this is a PIVOT!

Steps:

1. Uninstall cri-o and install gpu tools

    - We can search for things using `sudo apt search <searchString>`

        sudo apt install -y nvidia-headless-525 nvidia-encode libnvidia-encode-525 nvidia-utils-525

Then restart using `sudo shutdown -r now`

We can test whether we're all set up by installing `gpustat` and running it after a restart.

    gpustat (Merry Christmas!)
    server                        Sat Dec 25 00:00:00
    2022  525.60.11
    [0] NVIDIA GeForce GTX 1050 Ti | 18'C, 0 % | 60 / 4096 MB |

The true tool we should use to check is `nvidia-smi`, which will spit out a whole bunch of info about the GPU.

## Install Nvidia Container Tooling

    distribution=$(. /etc/os-release;echo $ID$VERSION_ID) \
      && curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg \
      && curl -s -L https://nvidia.github.io/libnvidia-container/$distribution/libnvidia-container.list | \
            sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
            sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list

    # Update apt.
    sudo apt-get update

    # Install the nvidia-docker2 package.
    sudo apt-get install -y nvidia-docker2

    # Restart Docker.
    sudo systemctl restart docker

    # Test the GPU with a base CUDA container.
    sudo docker run --rm --gpus all nvidia/cuda:11.0.3-base-ubuntu20.04 nvidia-smi

# Allow Docker to work with post-dockershim versions of Kube

https://www.mirantis.com/blog/how-to-install-cri-dockerd-and-migrate-nodes-from-dockershim/

    wget https://github.com/Mirantis/cri-dockerd/releases/download/v0.2.0/cri-dockerd-v0.2.0-linux-amd64.tar.gz
    tar xvf cri-dockerd-v0.2.0-linux-amd64.tar.gz
    sudo mv ./cri-dockerd /usr/local/bin/ 
    cri-dockerd --help

    wget https://raw.githubusercontent.com/Mirantis/cri-dockerd/master/packaging/systemd/cri-docker.service
    wget https://raw.githubusercontent.com/Mirantis/cri-dockerd/master/packaging/systemd/cri-docker.socket
    sudo mv cri-docker.socket cri-docker.service /etc/systemd/system/
    sudo sed -i -e 's,/usr/bin/cri-dockerd,/usr/local/bin/cri-dockerd,' /etc/systemd/system/cri-docker.service

    systemctl daemon-reload
    systemctl enable cri-docker.service
    systemctl enable --now cri-docker.socket

    systemctl status cri-docker.socket

Now in our kubeadm run command, we'll use the following socket: `unix:///var/run/cri-dockerd.sock`. We'll use this socket anywhere in the documentation we were previously running cri-o.
