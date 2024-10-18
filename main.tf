####################################################
# PROVIDERS
####################################################

provider "azurerm" {
  resource_provider_registrations = "core"
  resource_providers_to_register = [
    "Microsoft.KeyVault",
  ]


  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

provider "azapi" {}

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.4.0"
    }
    azapi = {
      source = "azure/azapi"
    }
  }
}

####################################################
# Resource Group  
####################################################

resource "azurerm_resource_group" "rg" {
  name     = "${var.prefix}-rg"
  location = var.location
}
