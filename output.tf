output "bastion_host" {
  value = {
    rg_name   = azurerm_resource_group.rg.name
    name      = azurerm_bastion_host.azure_bastion_instance.name
    public_ip = azurerm_public_ip.azure_bastion
  }
}

output "firewall" {
  value = {
    rg_name   = azurerm_resource_group.rg.name
    name      = azurerm_firewall.this.name
    public_ip = azurerm_firewall.this.ip_configuration[0].private_ip_address
  }
}

output "vm" {
  value = {
    rg_name      = azurerm_resource_group.rg.name
    name         = azurerm_linux_virtual_machine.this.name
    id           = azurerm_linux_virtual_machine.this.id
    principal_id = azurerm_linux_virtual_machine.this.identity[0].principal_id
    nic_id       = azurerm_linux_virtual_machine.this.network_interface_ids[0]
  }
}

output "keyvault" {
  value = {
    rg_name      = azurerm_resource_group.rg.name
    name         = azurerm_key_vault.key_vault.name
  }
}

output "law" {
  value = {
    rg_name      = azurerm_resource_group.rg.name
    name         = azurerm_log_analytics_workspace.example.name
    id           = azurerm_log_analytics_workspace.example.id
    workspace_id = azurerm_log_analytics_workspace.example.workspace_id
  }
}
