
#Log Analytics Workspace
resource "azurerm_log_analytics_workspace" "log_analytics_workspace" {
  name                = "${var.project}-law"
  location            = data.azurerm_resource_group.backend.location
  resource_group_name = data.azurerm_resource_group.backend.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  depends_on          = [data.azurerm_resource_group.backend]
}