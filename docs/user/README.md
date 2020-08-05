# RBAC and End User scenario walkthrough

## Setup testing resources

Some resources need to be setup before updating your kubeconfig to point to the kube-oidc-proxy instance that was setup.

First, Create 2 namespaces for testing.

```shell
kubectl create namespace test-admin
kubectl create namespace test-reader
```

Setup RBAC roles in the new namespaces. Examples are avaiable in [the test directory](../../src/yaml/test/). When using the example files, replace the value "user@INSERT_OWN_DOMAIN.HERE" with the email of the user that was setup during the [dex](../dex/) installation.

```shell
kubectl apply -f src/yaml/test/admin-rbac.yaml
kubectl apply -f src/yaml/test/reader-rbac.yaml
```

Setup sample deployments in the test namespaces. These will be used to verify the RBAC role assignments.

```shell
kubectl apply -f src/yaml/test/app.yaml
```

## Authentication walkthrough

Now that the testing resources are avaiable, go through the process of updating your kubeconfig.

Go to gangway site that was setup previously. https://gangway.INSERT_OWN_DOMAIN.HERE

Click the "SIGN IN" button. You will be redirected to the dex instance that was previously setup.

Log in with the username and password combination that was setup in the dex config under staticPasswords.

Click the "Grant Access" button.

You will now be redirected back to gangway, on a page with instructions on setting up your kubeconfig.

Run the second block of code to update your kubeconfig. The code below the "DOWNLOAD KUBECONFIG" button. Another option is to use the button to download a config file and then replace the contents of your existing kubeconfig with the content of the downloaded file. The default kubeconfig file is located at `$HOME/.kube/config`. The location might also be set the environment variable `KUBECONFIG`.

## Authorization test

kubectl is now configured to use kube-oidc-proxy. Verify this is the case by running

```shell
kubectl config view --minify
```

You should see the details from the gangway kubeconfig page, including the email of our test user from dex. Use the examples below to test different scenarios in our test setup.

User has read access to pods in `test-admin` namespace.

```shell
kubectl get pods -n test-admin
```

User has delete access to pods in `test-admin` namespace. Delete one of the pods from the previous command.

```shell
kubectl delete pod POD_NAME_HERE -n test-admin
```

User does not have access to deployments in the `test-admin` namespace. Only pods. This should result in an error.

```shell
kubectl get deployments -n test-admin
```

User has access to pods in the `test-reader` namespace.

```shell
kubectl get pods -n test-reader
```

User does not have delete access to pods in the `test-reader` namespace. Delete one of the pods from the previous command. This should result in an error.

```shell
kubectl delete pod POD_NAME_HERE -n test-reader
```

User does not have access to other pods outside of the test namespaces created for this demo. This should result in an error.

```shell
kubectl get pods -n kube-system
```
