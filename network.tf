
resource "azurerm_virtual_network" "vnet" {
  resource_group_name = azurerm_resource_group.rg.name
  name                = "${var.prefix}-vnet"
  address_space       = [var.base_cidr_space]
  location            = var.location
}

resource "azurerm_subnet" "azure_fw" {
  name                 = "AzureFirewallSubnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [cidrsubnet(var.base_cidr_space, 8, 0)]
}

resource "azurerm_subnet" "azure_fw_mgmt" {
  name                 = "AzureFirewallManagementSubnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [cidrsubnet(var.base_cidr_space, 8, 1)]
}

resource "azurerm_subnet" "azure_bastion" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [cidrsubnet(var.base_cidr_space, 8, 2)]
}

# Private subnet, NSG and Route Table for VM
resource "azapi_resource" "subnet-vm" {
  type      = "Microsoft.Network/virtualNetworks/subnets@2023-09-01"
  name      = "${azurerm_virtual_network.vnet.name}-vm-snet"
  parent_id = azurerm_virtual_network.vnet.id

  body = {
    properties = {
      addressPrefixes       = [cidrsubnet(var.base_cidr_space, 8, 3)]
      defaultOutboundAccess = false
      #---------------------------------------------------
      # SCENARIO 4: Enable Service Endpoint for Key Vault.
      #---------------------------------------------------
      # serviceEndpoints = [{
      #   service = "Microsoft.KeyVault"
      #   }
      # ]
    }
  }
  schema_validation_enabled = false

  depends_on = [
    azurerm_virtual_network.vnet,
    azurerm_subnet.azure_fw,
    azurerm_subnet.azure_fw_mgmt,
    azurerm_subnet.azure_bastion
  ]
}

resource "azurerm_route_table" "rt" {
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  name                = "${azapi_resource.subnet-vm.name}-rt"
}

resource "azurerm_subnet_route_table_association" "rt-association" {
  subnet_id      = azapi_resource.subnet-vm.id
  route_table_id = azurerm_route_table.rt.id
  depends_on     = [azapi_resource.subnet-vm]
}

#---------------------------------------------------
# SCENARIO 2: Send outbound traffic to Azure Firewall by default.
#---------------------------------------------------
# resource "azurerm_route" "default-to-firewall" {
#   resource_group_name    = azurerm_resource_group.rg.name
#   route_table_name       = azurerm_route_table.rt.name
#   name                   = "default"
#   address_prefix         = "0.0.0.0/0"
#   next_hop_type          = "VirtualAppliance"
#   next_hop_in_ip_address = azurerm_firewall.this.ip_configuration[0].private_ip_address
# }

#---------------------------------------------------
# SCENARIO 3 (a): Send traffic to 'AzureResourceManager' directly to Internet (rather than to the Firewall).
# (This one will crash a 'az keyvault show --name "..." -o table' command.)
#---------------------------------------------------
# resource "azurerm_route" "azurerm_2_internet" {
#   resource_group_name = azurerm_resource_group.rg.name
#   route_table_name    = azurerm_route_table.rt.name
#   name                = "AzureResourceManager-to-Internet"
#   address_prefix      = "AzureResourceManager"
#   next_hop_type       = "Internet"
# }


