# TODO: make variables
# - name
# - dns_prefix
# - kubernetes_version

resource "azurerm_kubernetes_cluster" "aks-oidc-proxy" {
  name                = "cluster-aakindele"
  location            = azurerm_resource_group.aks-oidc-proxy.location
  resource_group_name = azurerm_resource_group.aks-oidc-proxy.name
  dns_prefix          = "cluster-aakindele"
  kubernetes_version  = "1.16.10"

  default_node_pool {
    name       = "default"
    node_count = 3
    vm_size    = "Standard_D2_v2"
  }

  identity {
    type = "SystemAssigned"
  }

  role_based_access_control {
    enabled = true
  }
}
