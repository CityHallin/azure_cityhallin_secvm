
#get existing Storage Account
data "azurerm_storage_account" "backend" {
  name                = var.backend_storage_account_name
  resource_group_name = data.azurerm_resource_group.backend.name
}