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
# az account set --subscription="00000000-1111-2222-3333-444444444444"
```

## Terraform state file

This terraform setup will create sensitive data. The terraform state file will include this data and other potential pieces of sensitive information. It is recommended to store the state file remotely for better security. Run the commands below to setup Azure Storage for the state file.
More information can be found here https://docs.microsoft.com/en-us/azure/developer/terraform/store-state-in-azure-storage.

```shell
# Update the values here if needed for your environment
RESOURCE_GROUP_NAME=terraform-state
# The name you choose must be unique across Azure. The name also must be between 3 and 24 characters in length, and can include numbers and lowercase letters only.
STORAGE_ACCOUNT_NAME=terraformstate$RANDOM
CONTAINER_NAME=terraform-state
LOCATION=eastus

# Create resource group
az group create --name $RESOURCE_GROUP_NAME --location $LOCATION

# Create storage account
az storage account create --resource-group $RESOURCE_GROUP_NAME --name $STORAGE_ACCOUNT_NAME --sku Standard_LRS --encryption-services blob

# Get storage account key
ACCOUNT_KEY=$(az storage account keys list --resource-group $RESOURCE_GROUP_NAME --account-name $STORAGE_ACCOUNT_NAME --query [0].value -o tsv)

# Create blob container
az storage container create --name $CONTAINER_NAME --account-name $STORAGE_ACCOUNT_NAME --account-key $ACCOUNT_KEY
```

Replace the value for "storage_account_name"  in the terraform backend in [main.tf](./main.tf) with the output of the command below.

```shell
echo $STORAGE_ACCOUNT_NAME
```

## Running terraform

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

Part of the terraform output will be the Nameservers for the DNS Zone. The Nameservers for your domain need to be updated with your registrar to the Azure DNS Zone Name Servers. You can find instructions [here](https://docs.microsoft.com/en-us/azure/dns/dns-delegate-domain-azure-dns).
