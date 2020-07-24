resource "azuread_application" "cert-manager" {
  name = "cert-manager"
}

resource "azuread_service_principal" "cert-manager" {
  application_id = azuread_application.cert-manager.application_id
}

resource "azurerm_role_assignment" "cert-manager-dns-zone" {
  scope                = azurerm_dns_zone.dns-zone.id
  role_definition_name = "DNS Zone Contributor"
  principal_id         = azuread_service_principal.cert-manager.object_id
}
