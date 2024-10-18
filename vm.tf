locals {
  vm_name = "${var.prefix}-vm"
  vm_size = "Standard_B2s"
  source_image_publisher = "Canonical"
  source_image_offer = "0001-com-ubuntu-server-focal"
  source_image_sku = "20_04-lts"
  source_image_version = "latest"
}


####################################################
# interfaces
####################################################

resource "azurerm_network_interface" "this" {
  resource_group_name  = azurerm_resource_group.rg.name
  name                 = "${local.vm_name}-nic"
  location             = var.location

  ip_configuration {
    primary                       = true
    name                          = "${local.vm_name}-nic"
    subnet_id                     = azapi_resource.subnet-vm.id
    private_ip_address_allocation = "Dynamic"
    private_ip_address_version    = "IPv4"
  }

  lifecycle {
    ignore_changes = [
      ip_configuration.0.subnet_id,
    ]
  }

  timeouts {
    create = "60m"
  }
}

####################################################
# virtual machine
####################################################

resource "azurerm_linux_virtual_machine" "this" {
  resource_group_name = azurerm_resource_group.rg.name
  name                = local.vm_name
  location            = var.location
  size                = local.vm_size

  network_interface_ids = [
    azurerm_network_interface.this.id
  ]

  os_disk {
    name                 = "${local.vm_name}-os-disk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  source_image_reference {
    publisher = local.source_image_publisher
    offer     = local.source_image_offer
    sku       = local.source_image_sku
    version   = local.source_image_version
  }
  computer_name  = replace(local.vm_name, "_", "-")
  admin_username = var.admin_username
  admin_password = var.admin_password
  disable_password_authentication = false

  patch_mode = "AutomaticByPlatform"
  patch_assessment_mode = "AutomaticByPlatform"
  bypass_platform_safety_checks_on_user_schedule_enabled = true

  identity {
    type = "SystemAssigned"
  }

  lifecycle {
    ignore_changes = [
      identity,
    ]
  }
  timeouts {
    create = "60m"
  }
}


####################################################
# role assignment to access the key vault
####################################################

resource "azurerm_role_assignment" "vm_identity" {
  scope                = azurerm_key_vault.key_vault.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_linux_virtual_machine.this.identity[0].principal_id
}

resource "azurerm_role_assignment" "vm_identity_kv_contributor" {
  scope                = azurerm_key_vault.key_vault.id
  role_definition_name = "Key Vault Contributor"
  principal_id         = azurerm_linux_virtual_machine.this.identity[0].principal_id
}


####################################################
# assignment to load balancer backend pool
####################################################

#---------------------------------------------------
# SCENARIO 3 (b): Now attach the NIC to the backend pool of the outbound LB.
# (This will change the behavior of 'NextHopType: Internet' in route table.)
#---------------------------------------------------
# resource "azurerm_network_interface_backend_address_pool_association" "vm-nic_2_lb" {
#   network_interface_id    = azurerm_network_interface.this.id
#   ip_configuration_name   = "${var.prefix}-vm-nic"
#   backend_address_pool_id = azurerm_lb_backend_address_pool.backend.id
# }