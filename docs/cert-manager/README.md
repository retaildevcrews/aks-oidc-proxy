# Cert-Manager Deployment and Configuration

This directory contains the configuration files for the Cert-Manager deployment.

## ACME DNS Configuration for Let's Encrypt

Cert-Manager can use Let's Encrypt to attain TLS certificates for the different components of the system. First you must install cert-manager into your cluster.

### Install Cert-Manager

cert-manager runs within your Kubernetes cluster as a series of deployment
resources. It utilizes
[`CustomResourceDefinitions`](https://kubernetes.io/docs/concepts/extend-kubernetes/api-extension/custom-resources)
to configure Certificate Authorities and request certificates.

It is deployed using regular YAML manifests, like any other application on
Kubernetes.

Once cert-manager has been deployed, you must configure `Issuer` or `ClusterIssuer`
resources which represent certificate authorities.  More information on
configuring different `Issuer` types can be found in the [respective configuration
guides](https://cert-manager.io/docs/configuration/).

> Note: From cert-manager `v0.14.0` onward, the minimum supported version of
> Kubernetes is `v1.11.0`. Users still running Kubernetes `v1.10` or below should
> upgrade to a supported version before installing cert-manager.
> **Warning**: You should not install multiple instances of cert-manager on a single
> cluster. This will lead to undefined behavior and you may be banned from
> providers such as Let's Encrypt.

#### Installing with regular manifests

All resources (the `CustomResourceDefinitions`, cert-manager, namespace, and the webhook component)
are included in a single YAML manifest file:

Install the `CustomResourceDefinitions` and cert-manager itself:

```bash
# Kubernetes 1.15+
kubectl apply --validate=false -f https://github.com/jetstack/cert-manager/releases/download/v0.15.2/cert-manager.yaml

# Kubernetes <1.15
kubectl apply --validate=false -f https://github.com/jetstack/cert-manager/releases/download/v0.15.2/cert-manager-legacy.yaml
```

> **Note**: If you're using a Kubernetes version below `v1.15` you will need to install the legacy version of the manifests.
> This version does not have API version conversion and only supports `cert-manager.io/v1alpha2` API resources.
> **Note**: If you are running Kubernetes `v1.15.4` or below, you will need to add the
> `--validate=false` flag to your `kubectl apply` command above else you will
> receive a validation error relating to the
> `x-kubernetes-preserve-unknown-fields` field in cert-manager's
> `CustomResourceDefinition` resources.  This is a benign error and occurs due
> to the way `kubectl` performs resource validation.

> **Note**: By default, cert-manager will be installed into the `cert-manager`
> namespace. It is possible to run cert-manager in a different namespace, although you
> will need to make modifications to the deployment manifests.

#### Installing with Helm

As an alternative to the YAML manifests referenced above, we also provide an
official Helm chart for installing cert-manager.

##### Prerequisites

- Helm v2 or v3 installed

##### Note: Helm v2

Before deploying cert-manager with Helm v2, you must ensure
[Tiller](https://github.com/helm/helm) is up and running in your cluster. Tiller
is the server side component to Helm.

Your cluster administrator may have already setup and configured Helm for you,
in which case you can skip this step.

Full documentation on installing Helm can be found in the [installing helm
docs](https://v2.helm.sh/docs/install/#installing-helm).

If your cluster has RBAC (Role Based Access Control) enabled (default in GKE
`v1.7`+), you will need to take special care when deploying Tiller, to ensure
Tiller has permission to create resources as a cluster administrator. More
information on deploying Helm with RBAC can be found in the [Helm RBAC
docs](https://github.com/helm/helm/blob/240e539cec44e2b746b3541529d41f4ba01e77df/docs/rbac.md#Example-Service-account-with-cluster-admin-role).

##### Steps

In order to install the Helm chart, you must follow these steps:

Create the namespace for cert-manager:

```bash
kubectl create namespace cert-manager
```

Add the Jetstack Helm repository:

> **Warning**: It is important that this repository is used to install
> cert-manager. The version residing in the helm stable repository is
> *deprecated* and should *not* be used.

```bash
helm repo add jetstack https://charts.jetstack.io
```

Update your local Helm chart repository cache:

```bash
helm repo update
```

cert-manager requires a number of CRD resources to be installed into your
cluster as part of installation.

This can either be done manually, using `kubectl`, or using the `installCRDs`
option when installing the Helm chart.

**Option 1: installing CRDs with `kubectl`**

Install the `CustomResourceDefinition` resources using `kubectl`:

```bash
# Kubernetes 1.15+
kubectl apply --validate=false -f https://github.com/jetstack/cert-manager/releases/download/v0.15.1/cert-manager.crds.yaml

# Kubernetes <1.15
kubectl apply --validate=false -f https://github.com/jetstack/cert-manager/releases/download/v0.15.1/cert-manager-legacy.crds.yaml
```

> **Note**: If you're using a Kubernetes version below `v1.15` you will need to install the legacy version of the CRDs.
> This version does not have API version conversion and only supports `cert-manager.io/v1alpha2` API resources.

**Option 2: install CRDs as part of the Helm release**

To automatically install and manage the CRDs as part of your Helm release, you
must add the `--set installCRDs=true` flag to your Helm installation command.

**Uncomment the relevant line in the next steps to enable this**.

---

To install the cert-manager Helm chart:

```bash
# Helm v3+
helm install \
cert-manager jetstack/cert-manager \
--namespace cert-manager \
--version v0.15.1 \
# --set installCRDs=true

# Helm v2
helm install \
--name cert-manager \
--namespace cert-manager \
--version v0.15.1 \
jetstack/cert-manager \
  # --set installCRDs=true
```

The default cert-manager configuration is good for the majority of users, but a
full list of the available options can be found in the [Helm chart
README](https://hub.helm.sh/charts/jetstack/cert-manager).

#### Verifying the installation

Once you've installed cert-manager, you can verify it is deployed correctly by
checking the `cert-manager` namespace for running pods:

```bash
kubectl get pods --namespace cert-manager

NAME                                       READY   STATUS    RESTARTS   AGE
cert-manager-5c6866597-zw7kh               1/1     Running   0          2m
cert-manager-cainjector-577f6d9fd7-tr77l   1/1     Running   0          2m
cert-manager-webhook-787858fcdb-nlzsq      1/1     Running   0          2m
```

You should see the `cert-manager`, `cert-manager-cainjector`, and
`cert-manager-webhook` pod in a `Running` state.
It may take a minute or so for the TLS assets required for the webhook to
function to be provisioned. This may cause the webhook to take a while longer
to start for the first time than other pods. If you experience problems, please
check the [FAQ guide](https://cert-manager.io/docs/faq/).

### Create the ClusterIssuer object

cert-manager can use different certificate issuing services to automate the lidecycle of TLS certificates. FOr the purpose of demonstration Let'S Encrypt service uses the Automated Certificate Management Environment (ACME) Certificate Authority server to issue certificates.

In order for the ACME CA server to verify that a client owns the domain, or domains, a certificate is being requested for, the client must complete “challenges”. This is to ensure clients are unable to request certificates for domains they do not own and as a result, fraudulently impersonate another’s site. As detailed in the RFC8555, cert-manager offers two challenge validations - HTTP01 and DNS01 challenges.

Cert-manager can be configured to use [AzureDNS Zones](https://cert-manager.io/docs/configuration/acme/dns01/azuredns/) to validate the domain name which requires that a Service Principal that has at least `DNS Zone Contributor" IAM role for the DNS zone to validate the certificates against.

To create the service principal you can use the following script (requires
`azure-cli` and `jq`):

```bash
# Choose a name for the service principal that contacts azure DNS to present the challenge
AZURE_CERT_MANAGER_NEW_SP_NAME=NEW_SERVICE_PRINCIPAL_NAME
# This is the name of the resource group that you have your dns zone in
AZURE_DNS_ZONE_RESOURCE_GROUP=AZURE_DNS_ZONE_RESOURCE_GROUP
# The DNS zone name. It should be something like domain.com or sub.domain.com
AZURE_DNS_ZONE=AZURE_DNS_ZONE

DNS_SP=$(az ad sp create-for-rbac --name $AZURE_CERT_MANAGER_NEW_SP_NAME)
AZURE_CERT_MANAGER_SP_APP_ID=$(echo $DNS_SP | jq -r '.appId')
AZURE_CERT_MANAGER_SP_PASSWORD=$(echo $DNS_SP | jq -r '.password')
AZURE_TENANT_ID=$(echo $DNS_SP | jq -r '.tenant')
AZURE_SUBSCRIPTION_ID=$(az account show | jq -r '.id')
```

For security purposes, it is appropriate to utilize RBAC to ensure that you
properly maintain access control to your resources in Azure. The service
principal that is generated by this tutorial has fine grained access to ONLY the
DNS Zone in the specific resource group specified. It requires this permission
so that it can read/write the \_acme\_challenge TXT records to the zone.

Lower the Permissions of the service principal.

```bash
az role assignment delete --assignee $AZURE_CERT_MANAGER_SP_APP_ID --role Contributor
```

Give Access to DNS Zone.

```bash
DNS_ID=$(az network dns zone show --name $AZURE_DNS_ZONE --resource-group $AZURE_DNS_ZONE_RESOURCE_GROUP --query "id" --output tsv)
az role assignment create --assignee $AZURE_CERT_MANAGER_SP_APP_ID --role "DNS Zone Contributor" --scope $DNS_ID
```

Check Permissions. As the result of the following command, we would like to see just one object in the permissions array with "DNS Zone Contributor" role.

```bash
az role assignment list --all --assignee $AZURE_CERT_MANAGER_SP_APP_ID
```

A secret containing service principal password should be created on Kubernetes to facilitate presenting the challenge to Azure DNS. You can create the secret with the following command:

```bash
kubectl -n cert-manager create secret generic azuredns-config --from-literal=client-secret=$AZURE_CERT_MANAGER_SP_PASSWORD
```

Get the variables for configuring the issuer.

```bash
echo "AZURE_CERT_MANAGER_SP_APP_ID: $AZURE_CERT_MANAGER_SP_APP_ID"
echo "AZURE_CERT_MANAGER_SP_PASSWORD: $AZURE_CERT_MANAGER_SP_PASSWORD"
echo "AZURE_SUBSCRIPTION_ID: $AZURE_SUBSCRIPTION_ID"
echo "AZURE_TENANT_ID: $AZURE_TENANT_ID"
echo "AZURE_DNS_ZONE: $AZURE_DNS_ZONE"
echo "AZURE_DNS_ZONE_RESOURCE_GROUP: $AZURE_DNS_ZONE_RESOURCE_GROUP"
```

To configure the issuer, substitute the capital cased variables with the values from the previous script. A sample yaml has been provided to configure: [clusterIssuer.yaml](../../src/yaml/cert-manager/clusterIssuer.yaml)

> Excerpt:

```yaml
apiVersion: cert-manager.io/v1alpha2
kind: ClusterIssuer
metadata:
  labels:
    name: letsencrypt-prod
  name: letsencrypt-prod
spec:
  acme:
    ...
    solvers:
    - dns01:
        azuredns:
          clientID: AZURE_CERT_MANAGER_SP_APP_ID
          clientSecretSecretRef:
          # The following is the secret we created in Kubernetes. Issuer will use this to present challenge to Azure DNS.
            name: azuredns-config
            key: client-secret
          subscriptionID: AZURE_SUBSCRIPTION_ID
          tenantID: AZURE_TENANT_ID
          resourceGroupName: AZURE_DNS_ZONE_RESOURCE_GROUP
          hostedZoneName: AZURE_DNS_ZONE
          # Azure Cloud Environment, default to AzurePublicCloud
          environment: AzurePublicCloud
```

Then apply the configured yaml to the cluster in the cert-manager namespace

```bash
kubectl -n cert-manager apply -f src/yaml/cert-manager/clusterIssuer.yaml
```

No Certificates will be issued until a Certificate Request is created for each service you need a certificate for. This example will have a Certificate request for [Dex](../dex/README.md), [Gangway](../gangway/README.md) and [kube-oidc-proxy](../kube-oidc-proxy/README.md). The configuration for those will be explained in the README for each service.

Now the [Ingress Controller can be deployed and configured](../ingress/README.md). This will allow traffic to flow to the different services.