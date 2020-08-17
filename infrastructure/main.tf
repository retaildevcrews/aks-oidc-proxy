provider "azurerm" {
  version = "=2.19.0"
  features {}
}

provider "azuread" {
  version = "=0.11.0"
}

provider "random" {
  version = "~> 2.3"
}

terraform {
  backend "azurerm" {
    # Replace this with the value of RESOURCE_GROUP_NAME
    resource_group_name  = "terraform-state"
    # Replace this with the value of STORAGE_ACCOUNT_NAME
    storage_account_name = "terraformstate"
    # Replace this with the value of CONTAINER_NAME
    container_name       = "terraform-state"
    key                  = "terraform-state.kube-oidc-proxy"
  }
}
