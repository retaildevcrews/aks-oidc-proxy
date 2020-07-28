# Gangway Deployment and Configuration

Deploying Gangway consists of writing a config file and then deploying the service. The service is stateless so it is relatively easy to manage on Kubernetes. How you provide access to the service is going to be dependent on your specific configuration.

A good starting point for yaml manifests for deploying to Kubernetes is in the [yaml](../../src/yaml/gangway) directory. This creates a configmap, deployment and service. There is also an example ingress config that is set up to work with Heptio Contour, JetStack cert-manager and Let's Encrypt in the [ingress](../../src/yaml/ingress/gwy-ingress.yaml) directory.

The "client secret" is embedded in this config file.
While this is called a secret, based on the way that OAuth2 works with command line tools, this secret won't be all secret.
This will be divulged to any client that is configured through gangway.
As such, it is probably acceptable to keep that secret in the config file and not worry about managing it as a true secret.

We also have a secret string that is used to as a way to encrypt the cookies that are returned to the users.
If using the example YAML, create a secret to hold this value with the following command line:

```
kubectl -n gangway create secret generic gangway-key \
  --from-literal=sessionkey=$(openssl rand -base64 32)
```

## Setup up the ConfigMap file with needed Values

The key to customizing gangway to integrate with the other components of the system is to properly set up the configMap with the gangway.yaml contents. The sample file looks like this:

```yaml
apiVersion: v1
data:
  gangway.yaml: |-
    {
      "apiServerURL": "https://kube-oidc-proxy.INSERT_OWN_DOMAIN.HERE",
      "authorizeURL": "https://dex.INSERT_OWN_DOMAIN.HERE/auth",
      "authorize_url": "https://gangway.INSERT_OWN_DOMAIN.HERE/auth",
      "certFile": "/etc/gangway/tls/tls.crt",
      "clientID": "75UiO2E81m5Vi3nST4269fuO", #random string used in the config of dex staticClient
      "clientSecret": "kubYhdk7TBZCO4H1MwF0RpuT", #random string used in the config of dex staticClient
      "clusterName": "oidcproxy.INSERT_OWN_DOMAIN.HERE",
      "keyFile": "/etc/gangway/tls/tls.key",
      "redirectURL": "https://gangway.INSERT_OWN_DOMAIN.HERE/callback",
      "scopes": [
        "openid",
        "email",
        "profile",
        "groups",
        "offline_access"
      ],
      "serveTLS": true,
      "tokenURL": "https://dex.INSERT_OWN_DOMAIN.HERE/token",
      "usernameClaim": "name"
    }
kind: ConfigMap
metadata:
  labels:
    name: gangway
  name: gangway
  namespace: auth
```

If running through the sample docuemntation here to configure an environment, the only changes needed are replacing `INSERT_OWN_DOMAIN.HERE` with a valid DNS name that is being used or the example walkthrough (See the [ingress readme](../ingress/README.md)).

The `clientID` and `clientSecret` values can also be changed as long as they match the same fields in the [dex configuration file](../../src/yaml/dex/dex-config.yaml).