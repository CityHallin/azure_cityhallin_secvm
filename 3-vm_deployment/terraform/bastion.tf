
#Bastion Resources
#Using ARM template deployment as azurerm provider
#does not allow Developer Sku at this time
resource "azurerm_resource_group_template_deployment" "bastion" {
  name                = "${var.project}-bastion-deployment"
  resource_group_name = azurerm_resource_group.resource_group.name
  deployment_mode     = "Incremental"
  parameters_content = jsonencode({
    "location" = {
        value = azurerm_resource_group.resource_group.location
    },
    "resourceGroup" = {
        value = azurerm_resource_group.resource_group.name
    }
    "bastionHostName" = {
        value = "${var.project}-bastion"
    },    
    "vnetId" = {
        value = azurerm_virtual_network.virtual_network.id
    },
    "bastionHostSku" = {
        value = "Developer"
    }    
  })
  template_content = file("./arm_templates/bastion.json")
  depends_on = [azurerm_resource_group.resource_group,azurerm_virtual_network.virtual_network]
}