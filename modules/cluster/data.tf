data "azuread_client_config" "current" {}

data "azurerm_subscription" "current" {}

data "azurerm_resource_group" "this" {
  count = var.resource_group_exists ? 1 : 0
  name = var.resource_group
}
