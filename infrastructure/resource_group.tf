resource "azurerm_resource_group" "aks-oidc-proxy" {
  name     = var.resource-group-name
  location = var.region
}
