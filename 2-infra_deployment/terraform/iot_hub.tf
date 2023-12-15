
#IoT Hub Resources
resource "azurerm_eventhub_namespace" "ehn" {
  name                = "${var.project}-iothub-ehn"
  resource_group_name = data.azurerm_resource_group.backend.name
  location            = data.azurerm_resource_group.backend.location
  sku                 = "Basic"
}

resource "azurerm_eventhub" "eh" {
  name                = "${var.project}-iothub-eh"
  resource_group_name = data.azurerm_resource_group.backend.name
  namespace_name      = azurerm_eventhub_namespace.ehn.name
  partition_count     = 2
  message_retention   = 1
}

resource "azurerm_eventhub_authorization_rule" "eha" {
  resource_group_name = data.azurerm_resource_group.backend.name
  namespace_name      = azurerm_eventhub_namespace.ehn.name
  eventhub_name       = azurerm_eventhub.eh.name
  name                = "ehauth"
  send                = true
}

resource "azurerm_iothub" "iot_hub" {
  name                = "${var.project}-iothub"
  resource_group_name = data.azurerm_resource_group.backend.name
  location            = data.azurerm_resource_group.backend.location

  sku {
    name     = "F1"
    capacity = "1"
  }

   endpoint {
    type              = "AzureIotHub.EventHub"
    connection_string = azurerm_eventhub_authorization_rule.eha.primary_connection_string
    name              = "export"
  }

  route {
    name           = "export"
    source         = "DeviceMessages"
    condition      = "true"
    endpoint_names = ["export"]
    enabled        = true
  }

  enrichment {
    key            = "tenant"
    value          = "$twin.tags.Tenant"
    endpoint_names = ["export"]
  }
}

resource "azurerm_iothub_shared_access_policy" "iot_sap" {
  name                = var.project
  resource_group_name = data.azurerm_resource_group.backend.name
  iothub_name         = azurerm_iothub.iot_hub.name
  registry_read       = true
  registry_write      = true
  service_connect     = true
  device_connect      = true
}

# #IoT Hub Device Workaround
resource "null_resource" "iot_device" {
  provisioner "local-exec" {
    command = "az login --service-principal -u ${var.spn_client_id} -p ${var.spn_client_secret} --tenant ${data.azurerm_client_config.current.tenant_id} && az iot hub device-identity create --device-id button1 --edge-enabled --hub-name ${azurerm_iothub.iot_hub.name} --output none"
  }
}
