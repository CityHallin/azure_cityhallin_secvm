
#App Service PLan
resource "azurerm_service_plan" "windows_service_plan" {
  name                = "${var.project}-function-asp"
  resource_group_name = data.azurerm_resource_group.backend.name
  location            = data.azurerm_resource_group.backend.location
  os_type             = "Windows"
  sku_name            = "Y1"
}

#Function App
resource "azurerm_windows_function_app" "windows_function_app" {
  name                          = "${var.project}winfunc"
  resource_group_name           = data.azurerm_resource_group.backend.name
  location                      = data.azurerm_resource_group.backend.location
  storage_account_name          = data.azurerm_storage_account.backend.name
  storage_account_access_key    = data.azurerm_storage_account.backend.primary_access_key
  service_plan_id               = azurerm_service_plan.windows_service_plan.id
  https_only                    = true
  public_network_access_enabled = true

  app_settings = {
    application_insights_connection_string = azurerm_application_insights.application_insights.connection_string
    application_insights_key               = azurerm_application_insights.application_insights.instrumentation_key
    "githubpat"                            = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault_secret.github-pat.versionless_id})"
    "githubowner"                          = var.github_owner
    "githubreponame"                       = var.github_repo_name
    "iotclaim"                             = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault_secret.iot_claim.versionless_id})"
    "iot_hub_connection"                   = "Endpoint=${azurerm_iothub.iot_hub.event_hub_events_endpoint}/;SharedAccessKeyName=${azurerm_iothub_shared_access_policy.iot_sap.name};SharedAccessKey=${azurerm_iothub_shared_access_policy.iot_sap.primary_key};EntityPath=${azurerm_iothub.iot_hub.event_hub_events_path}"
  }

  identity {
    type = "SystemAssigned"
  }

  site_config {
    application_insights_connection_string = azurerm_application_insights.application_insights.connection_string
    application_insights_key               = azurerm_application_insights.application_insights.instrumentation_key
    cors {
      allowed_origins     = ["https://portal.azure.com"]
      support_credentials = false
    }
    application_stack {
      powershell_core_version = "7.2"
    }
  }
  depends_on = [azurerm_log_analytics_workspace.log_analytics_workspace, azurerm_application_insights.application_insights, azurerm_iothub.iot_hub]
}

#PowerShell Function
resource "azurerm_function_app_function" "function" {
  name            = "secvm_creation"
  function_app_id = azurerm_windows_function_app.windows_function_app.id
  language        = "PowerShell"

  file {
    name    = "run.ps1"
    content = file("./function_app_files/run.ps1")
  }

  test_data = jsonencode({
    "claim" = "test"  
  })

  config_json = jsonencode({
    "bindings" = [
      {
        "type"          = "eventHubTrigger",
        "name"          = "IoTHubMessages",
        "direction"     = "in",
        "eventHubName"  = "iot_eventhub",
        "connection"    = "iot_hub_connection",
        "cardinality"   = "many",
        "consumerGroup" = "$Default"
      },
    ]
  })
}

