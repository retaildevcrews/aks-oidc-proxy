resource "azurerm_dns_zone" "dns-zone" {
  name                = var.dns-zone-name
  resource_group_name = azurerm_resource_group.aks-oidc-proxy.name
}

output "dns-zone-nameservers" {
  description = "The nameservers for the Azure DNS Zone."
  value       = azurerm_dns_zone.dns-zone.name_servers
}
