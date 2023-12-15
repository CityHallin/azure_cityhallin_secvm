
#Key Vault
resource "azurerm_key_vault" "key_vault" {
  name                        = "${var.project}-kv56"
  location                    = data.azurerm_resource_group.backend.location
  resource_group_name         = data.azurerm_resource_group.backend.name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false
  sku_name                    = "standard"
  enable_rbac_authorization   = true
}

#Add Key Vault Permissions
resource "azurerm_role_assignment" "rbac_key_vault_functionapp" {
  scope                = azurerm_key_vault.key_vault.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_windows_function_app.windows_function_app.identity.0.principal_id
  depends_on           = [azurerm_key_vault.key_vault, azurerm_windows_function_app.windows_function_app]
}

#Add Key Vault Secret
resource "azurerm_key_vault_secret" "github-pat" {
  name         = "github-pat"
  value        = var.kv_github_pat
  key_vault_id = azurerm_key_vault.key_vault.id
  depends_on   = [azurerm_key_vault.key_vault]
}

resource "azurerm_key_vault_secret" "iot_claim" {
  name         = "iot-claim"
  value        = var.kv_iot_claim
  key_vault_id = azurerm_key_vault.key_vault.id
  depends_on   = [azurerm_key_vault.key_vault]
}