# Personal Notes

## Authenticating using the Azure CLI

```shell
az login
```

Show list of available Subscriptions.

```shell
az account list
```

Find the Subscription where resources will be created and take note of the "id". Then set the subscription for the CLI.

```shell
az account set --subscription="SUBSCRIPTION_ID"

# example:
# az account set --subscription="04f0d2e0-703b-4e4d-a267-cafae20b6992"
```

Initialize terraform.

```shell
terraform init
```

Run a plan to see verify what terraform will do.

```shell
terraform plan
```

Apply the changes if they look satisfactory. You will have a chance to verify the plan one more time before terraform makes changes.

```shell
terraform apply
```

TODO: some info about what to do with the dns zone name servers
