# Spike Notes

rough notes on getting kube-oidc-setup to work in codespaces k3d kubernetes cluster

## notes

- saw some weird behavior when port forwading components that serve https.
  - resolved by updating forwarded components to serve http
- updated dex to serve both http and https
  - forward http port in codespace
  - in cluster communication goes to https port
- mixture of localhost, cluster, and githubpreview urls
  - "localhost" when kubectl talks to API server
  - "svc.cluster.local" urls when a component needs to initiate request to another in-cluster component
  - "githubpreview.dev" urls when browser needs to make a request and/or redirect to another component
- css/styling issue with dex because of wrong url for static assets
  - spike solution was to override the header.html file with a custom file that uses urls relative to the browser location

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

## auth namespace setup

```bash

kubectl create namespace auth

# setup session secret for gangway
kubectl -n auth create secret generic gangway --from-literal=session-security-key=$(openssl rand -base64 32)

# setup dex html template to override the default header.html so that css styles can be referenced properly.
# this file was copied and modified from the version that is deployed
# if the dex version is updated, check to see if the template was updated between versions and update if needed.
kubectl -n auth create configmap dex-template --from-file "header.html=src/yaml/dex/dex-template-header.html"

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

```bash

# dex
kubectl -n auth apply -f src/yaml/dex/dex-serviceaccount.yaml
kubectl -n auth apply -f src/yaml/dex/dex-roles.yaml
kubectl -n auth apply -f src/yaml/dex/dex-rolebinding.yaml
kubectl -n auth apply -f src/yaml/dex/dex-clusterrole.yaml
kubectl -n auth apply -f src/yaml/dex/dex-clusterrolebinding.yaml
kubectl -n auth apply -f src/yaml/dex/dex-cert.yaml
kubectl -n auth apply -f src/yaml/dex/dex-config.yaml
kubectl -n auth apply -f src/yaml/dex/dex-deploy.yaml
kubectl -n auth apply -f src/yaml/dex/dex-service.yaml

# kube-oidc-proxy
kubectl -n auth apply -f src/yaml/kube-oidc-proxy/kop-cert.yaml
kubectl -n auth apply -f src/yaml/kube-oidc-proxy/kop-secretconfig.yaml
kubectl -n auth apply -f src/yaml/kube-oidc-proxy/kop-serviceaccount.yaml
kubectl -n auth apply -f src/yaml/kube-oidc-proxy/kop-clusterrole.yaml
kubectl -n auth apply -f src/yaml/kube-oidc-proxy/kop-clusterrolebinding.yaml
kubectl -n auth apply -f src/yaml/kube-oidc-proxy/kop-deploy.yaml
kubectl -n auth apply -f src/yaml/kube-oidc-proxy/kop-service.yaml

# gangway
kubectl -n auth apply -f src/yaml/gangway/gwy-config.yaml
kubectl -n auth apply -f src/yaml/gangway/gwy-cert.yaml
kubectl -n auth apply -f src/yaml/gangway/gwy-deploy.yaml
kubectl -n auth apply -f src/yaml/gangway/gwy-service.yaml

```

## setup for testing

```bash

kubectl create namespace test-admin
kubectl create namespace test-reader

kubectl apply -f src/yaml/test/admin-rbac.yaml
kubectl apply -f src/yaml/test/reader-rbac.yaml

kubectl apply -f src/yaml/test/app.yaml

```

Go to "PORTS" tab in codespaces, and navigate to gangway UI with the "open in browser" button.

After setting up kubeconfig, test some [example scenarios](/docs/user/README.md#authorization-test).
