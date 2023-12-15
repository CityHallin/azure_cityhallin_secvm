
#Resource Group
resource "azurerm_resource_group" "resource_group" {
  name     = var.project
  location = var.region  
}