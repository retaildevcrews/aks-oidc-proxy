# Setup Azure infrastructure

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

Run a plan to verify what terraform will do. Terraform will prompt for values when variables are not defined.
To add default values and skip the variable prompts, copy the contents of `terraform.tfvars.example` to `terraform.tfvars`. Then add in your values.

```shell
terraform plan
```

Apply the changes if they look satisfactory. You will have a chance to verify the plan one more time before terraform makes changes.

```shell
terraform apply
```
