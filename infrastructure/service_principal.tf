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

resource "random_password" "password" {
  length  = 32
  special = true
}

resource "azuread_service_principal_password" "cert-manager-password" {
  service_principal_id = azuread_service_principal.cert-manager.id
  value                = random_password.password.result
  end_date_relative    = "17520h" #expire in 2 years
}
