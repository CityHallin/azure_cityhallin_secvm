
#Virtual Network Resources
resource "azurerm_virtual_network" "virtual_network" {
  name                = "${var.project}-vnet"
  address_space       = ["10.10.0.0/16"]
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name  
}

resource "azurerm_subnet" "vm_subnet" {
  name                 = "vm"
  resource_group_name  = azurerm_resource_group.resource_group.name
  virtual_network_name = azurerm_virtual_network.virtual_network.name
  address_prefixes     = ["10.10.1.0/24"]  
}

#Network Security Group
resource "azurerm_network_security_group" "network_security_group" {
  name                = "${var.project}-nsg"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name   
}

resource "azurerm_network_security_rule" "nsg_rule_rdp" {
  name                        = "WinRM"
  priority                    = 110
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "5986"
  source_address_prefix       = var.runner_ip_address
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.resource_group.name
  network_security_group_name = azurerm_network_security_group.network_security_group.name
  depends_on                  = [azurerm_network_security_group.network_security_group]
}

resource "azurerm_subnet_network_security_group_association" "nsg_subnet_association" {
  subnet_id                 = azurerm_subnet.vm_subnet.id
  network_security_group_id = azurerm_network_security_group.network_security_group.id
}
