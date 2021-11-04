.PHONY: help all create delete deploy check clean app webv test load-test jumpbox

help :
	@echo "Usage:"
	@echo "   make create           - create a k3d cluster"
	@echo "   make delete           - delete the k3d cluster"

delete :
	# delete the cluster (if exists)
	@# this will fail harmlessly if the cluster does not exist
	@k3d cluster delete

create : delete
	@# create the cluster and wait for ready
	@# this will fail harmlessly if the cluster exists
	@# default cluster name is k3d

	@k3d cluster create --registry-use k3d-registry.localhost:5500 --config deploy/k3d.yaml --k3s-server-arg "--no-deploy=traefik" --k3s-server-arg "--no-deploy=servicelb"

	# wait for cluster to be ready
	@kubectl wait node --for condition=ready --all --timeout=60s
	@sleep 5
	@kubectl wait pod -A --all --for condition=ready --timeout=60s

jumpbox :
	# start a jumpbox pod
	@-kubectl delete pod jumpbox --ignore-not-found=true

	@kubectl run jumpbox --image=ghcr.io/cse-labs/jumpbox --restart=Always -- /bin/sh -c "trap : TERM INT; sleep 9999999999d & wait"
	@kubectl wait pod jumpbox --for condition=ready --timeout=30s
	@kubectl exec jumpbox -- /bin/sh -c "apk update && apk add bash curl nano jq py-pip" > /dev/null
	@kubectl exec jumpbox -- /bin/sh -c "pip3 install --upgrade pip setuptools httpie" > /dev/null
	@kubectl exec jumpbox -- /bin/sh -c "echo \"alias ls='ls --color=auto'\" >> /root/.profile && echo \"alias ll='ls -lF'\" >> /root/.profile && echo \"alias la='ls -alF'\" >> /root/.profile && echo 'cd /root' >> /root/.profile" > /dev/null

	# Run an interactive bash shell in the jumpbox
	# kj
	# use kje <command>
