# Traefik

We want to use a local ingress controller for simplicity, so lets set up traefik!

    helm repo add traefik https://helm.traefik.io/traefik;
    helm repo update;
    helm install traefik traefik/traefik --values traefik-values.yaml

I then ran into this issue with the installation: https://github.com/traefik/traefik-helm-chart/issues/741

Turns out I shouldn't have been using the snap installation of helm (documented earlier), but it should be fine for most uses.

    $ which helm
    /snap/bin/helm
    $ sudo snap remove helm
    helm removed

Now lets install the latest version of helm!

    $ curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
    $ chmod 700 get_helm.sh
    $ ./get_helm.sh

Now, we rerun the helm install command.

    $ helm install traefik traefik/traefik
    NAME: traefik
    NAMESPACE: default
    STATUS: deployed
    REVISION: 1
    TEST SUITE: None
    NOTES:
    Traefik Proxy v2.9.5 has been deployed successfully
    on default namespace !

