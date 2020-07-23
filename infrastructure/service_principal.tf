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

# TODO:
#   https://www.terraform.io/docs/state/sensitive-data.html
#   how to create password for service principal? in here or somewhere else?
#   creating it in terraform like this will save the plaintext value in the state file.
#
# resource "random_password" "cert-manager-password" {
#   length = 16
# }
#
# resource "azuread_service_principal_password" "cert-manager-password" {
#   service_principal_id = azuread_service_principal.cert-manager.object_id
#   description          = "Password for cert-manager service principal"
#   value                = random_password.cert-manager-password.result
# }
