####################################################
# ip addresses
####################################################

resource "azurerm_public_ip" "azure_bastion" {
  name                = "${var.prefix}-bastion-pip"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}


####################################################
# bastion host
####################################################

resource "azurerm_bastion_host" "azure_bastion_instance" {
  name                = "${var.prefix}-bastion"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "Standard"
  tunneling_enabled   = true

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.azure_bastion.id
    public_ip_address_id = azurerm_public_ip.azure_bastion.id
  }
}

