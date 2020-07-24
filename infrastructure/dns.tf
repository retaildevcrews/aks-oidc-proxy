resource "azurerm_dns_zone" "dns-zone" {
  name                = var.dns-zone-name
  resource_group_name = azurerm_resource_group.aks-oidc-proxy.name
}
