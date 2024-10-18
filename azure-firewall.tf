####################################################
# ip addresses
####################################################

resource "azurerm_public_ip" "pip" {
  resource_group_name = azurerm_resource_group.rg.name
  name                = "${var.prefix}-azfw-pip"
  location            = var.location
  sku                 = "Standard"
  allocation_method   = "Static"
  timeouts {
    create = "60m"
  }
}

resource "azurerm_public_ip" "mgmt_pip" {
  resource_group_name = azurerm_resource_group.rg.name
  name                = "${var.prefix}-azfw-pip-mgmt"
  location            = var.location
  sku                 = "Standard"
  allocation_method   = "Static"
  timeouts {
    create = "60m"
  }
}



####################################################
# firewall policy
####################################################

resource "azurerm_firewall_policy" "firewall_policy" {
  resource_group_name      = azurerm_resource_group.rg.name
  name                     = "${var.prefix}-fwpolicy"
  location                 = var.location
  threat_intelligence_mode = "Alert"
  sku                      = "Basic"
}


resource "azurerm_firewall_policy_rule_collection_group" "firewall_policy_rule_collection_group" {
  name               = "rule-collection-group"
  firewall_policy_id = azurerm_firewall_policy.firewall_policy.id
  priority           = 500

  network_rule_collection {
    name     = "network-rc"
    priority = 100
    action   = "Allow"

    rule {
      name                  = "network-rc-any-to-any"
      protocols             = ["Any"]
      source_addresses      = ["*"]
      destination_addresses = ["*"]
      destination_ports     = ["*"]
    }
  }
}

####################################################
# firewall
####################################################

resource "azurerm_firewall" "this" {
  resource_group_name = azurerm_resource_group.rg.name
  name                = "${var.prefix}-azfw"
  location            = var.location
  sku_tier            = "Basic"
  sku_name            = "AZFW_VNet"
  firewall_policy_id  = azurerm_firewall_policy.firewall_policy.id

  ip_configuration {
    name                 = "ip-config"
    subnet_id            = azurerm_subnet.azure_fw.id
    public_ip_address_id = azurerm_public_ip.pip.id
  }
  
  management_ip_configuration {
    name                 = "mgmt-ip-config"
    subnet_id            = azurerm_subnet.azure_fw_mgmt.id
    public_ip_address_id = azurerm_public_ip.mgmt_pip.id
  }

  timeouts {
    create = "60m"
  }

  lifecycle {
    ignore_changes = [
      ip_configuration,
    ]
  }

  depends_on = [
    azurerm_public_ip.pip,
  ]
}
