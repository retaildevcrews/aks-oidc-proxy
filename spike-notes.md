# Spike Notes

## codespace app URL

```bash

# codespace url for app is the format
# https://<codespace name>-<app forwarded port>.githubpreview.dev

# example
# CODESPACE_NAME is already populated in the codespace by default
GANGWAY_CODESPACE_PORT=30080
DEX_CODESPACE_PORT=30556

echo "https://${CODESPACE_NAME}-${GANGWAY_CODESPACE_PORT}.githubpreview.dev"
echo "https://${CODESPACE_NAME}-${DEX_CODESPACE_PORT}.githubpreview.dev"

```

## start

```bash

make create

```

## cert manager

skipped existing certmanager docs

```bash

# install cert manager
kubectl apply -f https://github.com/jetstack/cert-manager/releases/download/v1.6.0/cert-manager.yaml

# wait for pods to be ready
kubectl wait --for=condition=ready pod -l app.kubernetes.io/instance=cert-manager -n cert-manager

# create certificate authority with self-signed cert
kubectl apply -f src/yaml/cert-manager-config/self-signed-ca.yaml

```

## ingress

skipped ingress docs

## auth namespace

```bash

kubectl create namespace auth

```

## random client secert and bcrypt

```bash

# can create a static client secret from command line.
openssl rand -hex 12

# can create a bcrypt password from command line
sudo apt-get update
sudo apt-get install apache2-utils
htpasswd -nbBC 10 "" password | tr -d ':\n'

```

## deploy

dex

```bash

kubectl -n auth apply -f src/yaml/dex/dex-serviceaccount.yaml
kubectl -n auth apply -f src/yaml/dex/dex-roles.yaml
kubectl -n auth apply -f src/yaml/dex/dex-rolebinding.yaml
kubectl -n auth apply -f src/yaml/dex/dex-clusterrole.yaml
kubectl -n auth apply -f src/yaml/dex/dex-clusterrolebinding.yaml
kubectl -n auth apply -f src/yaml/dex/dex-cert.yaml
kubectl -n auth apply -f src/yaml/dex/dex-config.yaml
kubectl -n auth apply -f src/yaml/dex/dex-deploy.yaml
kubectl -n auth apply -f src/yaml/dex/dex-service.yaml

```

kube-oidc-proxy

```bash

kubectl -n auth apply -f src/yaml/kube-oidc-proxy/kop-cert.yaml
kubectl -n auth apply -f src/yaml/kube-oidc-proxy/kop-secretconfig.yaml
kubectl -n auth apply -f src/yaml/kube-oidc-proxy/kop-serviceaccount.yaml
kubectl -n auth apply -f src/yaml/kube-oidc-proxy/kop-clusterrole.yaml
kubectl -n auth apply -f src/yaml/kube-oidc-proxy/kop-clusterrolebinding.yaml
kubectl -n auth apply -f src/yaml/kube-oidc-proxy/kop-deploy.yaml
kubectl -n auth apply -f src/yaml/kube-oidc-proxy/kop-service.yaml

```

gangway

```bash

kubectl -n auth create secret generic gangway --from-literal=session-security-key=$(openssl rand -base64 32)

kubectl -n auth apply -f src/yaml/gangway/gwy-config.yaml
kubectl -n auth apply -f src/yaml/gangway/gwy-cert.yaml
kubectl -n auth apply -f src/yaml/gangway/gwy-deploy.yaml
kubectl -n auth apply -f src/yaml/gangway/gwy-service.yaml

```
