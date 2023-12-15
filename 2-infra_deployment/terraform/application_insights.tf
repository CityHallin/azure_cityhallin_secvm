
#Application Insights
resource "azurerm_application_insights" "application_insights" {
  name                = "${var.project}-ai"
  location            = data.azurerm_resource_group.backend.location
  resource_group_name = data.azurerm_resource_group.backend.name
  workspace_id        = azurerm_log_analytics_workspace.log_analytics_workspace.id
  application_type    = "web"
  depends_on          = [azurerm_log_analytics_workspace.log_analytics_workspace]
}