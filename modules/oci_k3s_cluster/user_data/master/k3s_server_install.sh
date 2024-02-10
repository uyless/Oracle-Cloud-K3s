#!/usr/bin/env bash
set -x
exec >/tmp/k3s-server-install-debug.log 2>&1

export K3S_TOKEN="${cluster_token}"
export K3S_KUBECONFIG_MODE="644"
export INSTALL_K3S_VERSION="${k3s_version}"

node_id=$(curl -s http://169.254.169.254/opc/v1/instance/ | jq -r '.id')

curl -sfL https://get.k3s.io | /usr/bin/env bash -s - server \
	--disable servicelb \
	--disable local-storage \
	--disable traefik \
	--node-name="$(hostname -f)" \
	--bind-address="${control_node_private_ip}" \
	--disable-cloud-controller \
	--kubelet-arg="cloud-provider=external" \
	--kubelet-arg="provider-id=$${node_id}" \
	--resolv-conf="/etc/rancher/k3s/resolv.conf"

unset INSTALL_K3S_NAME
unset K3S_TOKEN
unset K3S_KUBECONFIG_MODE

export KUBECONFIG=/etc/rancher/k3s/k3s.yaml

if [[ $(kubectl get crd --no-headers | grep volumesnapshot | wc -l) != "3" ]]; then
	echo "Installing CRDs for OCI storage interface snapshot functionality"
	kubectl apply -f https://raw.githubusercontent.com/kubernetes-csi/external-snapshotter/master/client/config/crd/snapshot.storage.k8s.io_volumesnapshotclasses.yaml
	kubectl apply -f https://raw.githubusercontent.com/kubernetes-csi/external-snapshotter/master/client/config/crd/snapshot.storage.k8s.io_volumesnapshotcontents.yaml
	kubectl apply -f https://raw.githubusercontent.com/kubernetes-csi/external-snapshotter/master/client/config/crd/snapshot.storage.k8s.io_volumesnapshots.yaml
else
	echo "CRDs for OCI storage interface has been already installed"
fi

echo "Installing Helm"
curl -sfL https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | /usr/bin/env bash 

echo "Configure iptables"
echo "Create private input and output iptable chains"
iptables -N private-network-chain-input
iptables -A private-network-chain-input -s ${private_network} -p tcp --dport 6443 -j ACCEPT

iptables -N private-network-chain-output
iptables -A private-network-chain-output -d ${private_network} -p tcp --dport 6443 -j ACCEPT

echo "Create public input and output iptable chains"
iptables -N public-network-chain-input
iptables -A public-network-chain-input -s ${public_network} -p tcp --dport 22 -j ACCEPT

iptables -N public-network-chain-output
iptables -A public-network-chain-output -d ${public_network} -p tcp --dport 22 -j ACCEPT


iptables -I INPUT 1 -s ${private_network} -j private-network-chain-input
iptables -I INPUT 1 -s ${public_network} -j public-network-chain-input
iptables -I OUTPUT 1 -d ${private_network} -j private-network-chain-output
iptables -I OUTPUT 1 -d ${public_network} -j public-network-chain-output

if [[ "$(kubectl get deployment ingress-nginx-controller -n ingress-nginx --no-headers | wc -l)" == "0" ]]; then
	echo "Install Ingress-Nginx"
	helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
	helm repo update
	helm install ingress-nginx ingress-nginx/ingress-nginx --namespace ingress-nginx --create-namespace --set controller.ingressClassResource.default=true
else
	echo "Ingress-Nginx has been already installed"
fi

find /var/lib/rancher/k3s/server/manifests/ -name *.yaml -type f -exec chmod 0600 {} \;

unset KUBECONFIG
echo "K3s Setup Completed"