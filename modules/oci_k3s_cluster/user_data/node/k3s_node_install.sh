#!/usr/bin/env bash
set -x
exec >/tmp/k3s-agent-join-debug.log 2>&1

export K3S_TOKEN="${cluster_token}"
export K3S_URL="https://${cluster_server}:6443"
export INSTALL_K3S_VERSION="${k3s_version}"

node_id=$(curl -s http://169.254.169.254/opc/v1/instance/ | jq -r '.id')

curl -sfL https://get.k3s.io | sh -s - agent \
	--node-name="$(hostname -f)" \
	--kubelet-arg="cloud-provider=external" \
	--kubelet-arg="provider-id=$${node_id}" \
	--node-label="node.kubernetes.io/worker=worker" \
	--resolv-conf="/etc/rancher/k3s/resolv.conf"

unset K3S_TOKEN
unset K3S_URL

echo "K3s Node Join Completed"