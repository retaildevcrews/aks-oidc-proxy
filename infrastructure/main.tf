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
