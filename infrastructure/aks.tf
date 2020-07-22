resource "azurerm_kubernetes_cluster" "aks-oidc-proxy" {
  name                = var.aks-cluster-name
  location            = azurerm_resource_group.aks-oidc-proxy.location
  resource_group_name = azurerm_resource_group.aks-oidc-proxy.name
  dns_prefix          = var.aks-cluster-name
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
