# Ingress Deployment and Configuration

For the test environment an ingress controller will be used to facilitate communication between the 3 components of the architecture; Dex acting as the Identity Provider, Gangway which facilitates authenticating the user against Dex and creating a kubeconfig with the proper tokens, and kube-oidc-proxy which will intercept the calls to the Kubernetes API and validate the user against Dex and impersonate the user request to the Kubernetes API endpoint.

In this setup [Contour](https://projectcontour.io/) will be used as an Ingress Controller inside Kubernetes.

## Add Contour to your cluster

Run:

```bash
kubectl apply -f https://projectcontour.io/quickstart/contour.yaml
```

This command creates:

- A new namespace `projectcontour`
- Two instances of Contour in the namespace
- A Kubernetes Daemonset running Envoy on each node in the cluster listening on host ports 80/443
- A Service of `type: LoadBalancer` that points to the Contour's Envoy instances
- An Azure Standard Load Balancer with frontend PublicIP and a backend pool of the Cluster nodes with port 80 and 443 NATed through the Load Balancer.

## Configure a DNS Zone for resolution between the services

In this scenario, we are assuming that the 3 different services can be deployed in different environments. In most production scenarios there will be a single Dex environment and potentially a gangway and kube-proxy-oidc service in each cluster. To facilitate this an Azure DNS Zone will be used in this example and a fully resolvable DNS is required and the Nameservers for your domain need to be updated with your registrar to the Azure DNS Zone Name Servers. You can find instructions [here](https://docs.microsoft.com/en-us/azure/dns/dns-delegate-domain-azure-dns).

Once a domain has been established 3 A records need to be created for the example system.

- dex.INSERT_OWN_DOMAIN.HERE
- gangway.INSERT_OWN_DOMAIN.HERE
- kube-oidc-proxy.INSERT_OWN_DOMAIN.HERE

The 3 records will be behind the external IP address of the Contour Ingress that was just deployed.

## Configure the Ingress for each service

The Ingress object was added to Kubernetes in version 1.1 to describe properties of a cluster-wide reverse HTTP proxy. Since that time, the Ingress object has not progressed beyond the beta stage, and its stagnation inspired an explosion of annotations to express missing properties of HTTP routing.

The goal of the HTTPProxy Custom Resource Definition (CRD) is to expand upon the functionality of the Ingress API to allow for a richer user experience as well addressing the limitations of the latter’s use in multi tenent environments.

For the example scenario each service will have an ingress defined using an HTTPProxy definition. Sample defintions have been provided, all that is required is to change the Domain Name that the ingress will be listening for:

- [dex ingress](../../src/yaml/ingress/dex-ingress.yaml)
- [gangway ingress](../../src/yaml/ingress/gwy-ingress.yaml)
- [kube-oidc-proxy ingress](../../src/yaml/ingress/kop-ingress.yaml)

>Excerpt
```yaml
apiVersion: projectcontour.io/v1
kind: HTTPProxy
metadata:
  labels:
    name: dex
  name: dex
  namespace: auth
spec:
  routes:
  ...
  virtualhost:
    fqdn: dex.INSERT_DOMAIN.HERE
    tls:
      passthrough: true
```

HTTPProxy resources are scoped to the namespace level of the application that needs the ingress route. For purposes of this example Dex, Gangway and kube-oidc-proxy can be deployed to the same namespace

```bash
kubectl create namespace auth
```

The HTTPProxy object can be applied before the services exists as the system will reconcile once everything is deployed

```bash
kubectl -n auth apply -f src/yaml/ingress/
```

Now the individual services can be deployed. Start with the [Dex deployment and configuration](../dex/README.md).