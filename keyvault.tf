locals {
  key_vault_secret_name  = "message"
  key_vault_secret_value = "Hello, World!"
}

data "azurerm_client_config" "current" {}

####################################################
# key vault
####################################################

# vault

resource "azurerm_key_vault" "key_vault" {
  resource_group_name = azurerm_resource_group.rg.name
  name                = "${var.prefix}-kv" 
  location            = var.location
  sku_name            = "standard"
  tenant_id           = data.azurerm_client_config.current.tenant_id
  enable_rbac_authorization = true
}

# RBAC role assignment
resource "azurerm_role_assignment" "current_identity" {
    scope                = azurerm_key_vault.key_vault.id
    role_definition_name = "Key Vault Secrets Officer"
    principal_id         = data.azurerm_client_config.current.object_id
}

resource "time_sleep" "key_vault" {
  create_duration = "30s"
  depends_on = [
    azurerm_role_assignment.current_identity
  ]
}

# secret

resource "azurerm_key_vault_secret" "key_vault" {
  name         = local.key_vault_secret_name
  value        = local.key_vault_secret_value
  key_vault_id = azurerm_key_vault.key_vault.id
  depends_on = [
    time_sleep.key_vault,
  ]
}

# log analytics workspace for audit logs
resource "azurerm_log_analytics_workspace" "example" {
  name                = "${var.prefix}-law"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

# diagnostic setting for key vault
resource "azurerm_monitor_diagnostic_setting" "example" {
  name                       = "to-law"
  target_resource_id         = azurerm_key_vault.key_vault.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.example.id

  enabled_log  {
    category = "AuditEvent"
  }

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}

