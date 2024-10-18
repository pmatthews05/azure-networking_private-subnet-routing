####################################################
## Outbound Load Balancercheck "name" 


resource "azurerm_public_ip" "lb-pip" {
  resource_group_name = azurerm_resource_group.rg.name
  name                = "${var.prefix}-lb-pip"
  location            = var.location
  sku                 = "Standard"
  allocation_method   = "Static"
  timeouts {
    create = "60m"
  }
}

resource "azurerm_lb" "example" {
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  name                = "${var.prefix}-lb"
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.lb-pip.id
  }
}

# Create a Backend Address Pool
resource "azurerm_lb_backend_address_pool" "backend" {
  loadbalancer_id = azurerm_lb.example.id
  name            = "BackEndAddressPool"
}

# Create an Outbound Rule
resource "azurerm_lb_outbound_rule" "example" {
  loadbalancer_id          = azurerm_lb.example.id
  name                     = "outbound-rule"
  backend_address_pool_id  = azurerm_lb_backend_address_pool.backend.id
  enable_tcp_reset         = true
  idle_timeout_in_minutes  = 15
  protocol                 = "All"

  frontend_ip_configuration {
    name = "PublicIPAddress"
  }
}

