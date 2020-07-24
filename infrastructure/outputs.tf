output "DNS_ZONE_NAMESERVERS" {
  value = azurerm_dns_zone.dns-zone.name_servers
}

output "AZURE_CERT_MANAGER_SP_APP_ID" {
  value = azuread_service_principal.cert-manager.application_id
}

output "AZURE_DNS_ZONE" {
  value = azurerm_dns_zone.dns-zone.name
}

output "AZURE_DNS_ZONE_RESOURCE_GROUP" {
  value = azurerm_resource_group.aks-oidc-proxy.name
}
