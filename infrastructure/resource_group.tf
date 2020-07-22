# TODO: make variables
# - name
# - location

resource "azurerm_resource_group" "aks-oidc-proxy" {
  name     = "aks-oidc-proxy"
  location = "East US"
}
