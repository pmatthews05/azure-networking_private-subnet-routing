resource "azurerm_network_security_group" "nsg" {
  resource_group_name = azurerm_resource_group.rg.name
  name                = "${azapi_resource.subnet-vm.name}-nsg"
  location            = var.location
}

resource "azurerm_network_security_rule" "nsg_AllowAzureLoadBalancerInBound" {
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.nsg.name
  name                        = "AllowAzureLoadBalancerInBound"
  direction                   = "Inbound"
  access                      = "Allow"
  priority                    = 4000
  source_address_prefix       = "AzureLoadBalancer"
  source_port_range           = "*"
  destination_address_prefix  = "*"
  destination_port_range      = "*"
  protocol                    = "*"
}

resource "azurerm_network_security_rule" "nsg_AllowSshFromVnet" {
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.nsg.name
  name                        = "AllowSshFromVnet"
  direction                   = "Inbound"
  access                      = "Allow"
  priority                    = 4001
  source_address_prefix       = "VirtualNetwork"
  source_port_range           = "*"
  destination_address_prefix  = "*"
  destination_port_range      = "22"
  protocol                    = "*"
}

resource "azurerm_network_security_rule" "nsg_DenyAllInbound" {
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.nsg.name
  name                        = "DenyAllVnetInbound"
  direction                   = "Inbound"
  access                      = "Deny"
  priority                    = 4096
  source_address_prefix       = "*"
  source_port_range           = "*"
  destination_address_prefix  = "VirtualNetwork"
  destination_port_range      = "*"
  protocol                    = "*"
}

resource "azurerm_subnet_network_security_group_association" "nsg-to-subnet" {
  subnet_id                 = azapi_resource.subnet-vm.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

