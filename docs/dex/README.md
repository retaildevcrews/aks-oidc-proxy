# Dex Deployment and Configuration

Dex is an identity service that uses [OpenID Connect](https://openid.net/connect/) to drive authentication for other apps.

Dex acts as a portal to other identity providers through ["connectors."](https://github.com/dexidp/dex#connectors) This lets dex defer authentication to LDAP servers, SAML providers, or established identity providers like GitHub, Google, and Active Directory. Clients write their authentication logic once to talk to dex, then dex handles the protocols for a given backend.

Dex runs natively on top of any Kubernetes cluster using Third Party Resources and can drive API server authentication through the OpenID Connect plugin. Clients, such as kubectl, can act on behalf users who can login to the cluster through any identity provider dex supports.

## Prerequsites

To allow the Dex service to deploy properly there is an order to applying the yaml files provided. Dex uses its service account to create the needed Custom Resource Defintions (CRDs) and to have proper access to its own namespace to update CRD files.

Add a Service account, role and role bindings for Dex

```bash
kubectl -n auth apply -f src/yaml/dex/dex-serviceaccount.yaml
kubectl -n auth apply -f src/yaml/dex/dex-roles.yaml
kubectl -n auth apply -f src/yaml/dex/dex-rolebinding.yaml
```

Add a ClusterRole that has permissions to create CRDs and then bind the role to the Service Account using a ClusterRoleBinding defintion

```bash
kubectl -n auth apply -f src/yaml/dex/dex-clusterrole.yaml

kubectl -n auth apply -f src/yaml/dex/dex-clusterrolebinding.yaml
```

Deploy the Certificate request so cert-manager can create the required tls secret that the dex deployment will use as a volume mount

```bash
kubectl -n auth apply -f src/yaml/dex/dex-cert.yaml
```

Verify if the certificate has been issued

```bash
kubectl -n auth describe certificate dex
```

A successful Certiicate assignment will show the last few lines as such

```bash
Name:         dex
Namespace:    auth
Labels:       name=dex
Annotations:  API Version:  cert-manager.io/v1alpha3
Kind:         Certificate
...
Status:
  Conditions:
    Last Transition Time:  2020-07-24T13:35:10Z
    Message:               Certificate is up to date and has not expired
    Reason:                Ready
    Status:                True
    Type:                  Ready
  Not After:               2020-10-22T12:35:09Z
Events:
  Type    Reason  Age   From          Message
  ----    ------  ----  ----          -------
  Normal  Issued  38s   cert-manager  Certificate issued successfully
```

Now the Dex service can be deployed. The dex-config.yaml file needs to be updated to have the correct domain that is being used for the example scenario. In the `staticPasswords` section of the config, a Hash of a password that has been encrypted with the bcrypt hash algorithm. You can visit [bcrypt-generator.com](https://bcrypt-generator.com/) to encrypt your plaintext password (use a 10 round hash). The `staticClients` section of the config requires also a `id` and `secret`, but these can be any random value. The important thing is that these values be recorded as they will be needed in the [Gangway](../../docs/gangway/README.md) setup.

```bash
kubectl -n auth apply -f src/yaml/dex/dex-config.yaml
kubectl -n auth apply -f src/yaml/dex/dex-deploy.yaml
kubectl -n auth apply -f src/yaml/dex/dex-service.yaml
```

The dex service should now be up and running and can be verified by running

```bash
kubectl -n auth get pods
NAME                   READY   STATUS    RESTARTS   AGE
dex-686d49bf85-sxlj8   1/1     Running   0          9m51s
```

Dex is now configured for a single user with an email claim and a password in the static database. There is also the option to use a 3rd party authentication system such as GitHub, Google, Microsoft, LDAP etc. There is a sample deployment and configuration files needed in the [src/yaml/dex/github_config/](../..src/yaml/dex/github_config/) directory as an example.

Now gangway can be configured to offer configuration files to authorized users. Follow the [Gangway deployment and configuration](../../docs/gangway/README.md) instructions.
