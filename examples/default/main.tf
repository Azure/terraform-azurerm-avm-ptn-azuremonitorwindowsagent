terraform {
  required_version = "~> 1.5"
  required_providers {
    azapi = {
      source  = "azure/azapi"
      version = "~> 1.13"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.74"
    }
    modtm = {
      source  = "azure/modtm"
      version = "~> 0.3"
    }
  }
}

provider "azurerm" {
  features {}
}

## Section to provide a random Azure region for the resource group
# This allows us to randomize the region for the resource group.
module "regions" {
  source  = "Azure/avm-utl-regions/azurerm"
  version = "~> 0.1"
}

# This is required for resource modules
data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

data "azapi_resource" "cluster" {
  type      = "Microsoft.AzureStackHCI/clusters@2023-08-01-preview"
  name      = var.cluster_name
  parent_id = data.azurerm_resource_group.rg.id
}

data "azapi_resource" "arc_settings" {
  type      = "Microsoft.AzureStackHCI/clusters/ArcSettings@2023-08-01"
  name      = "default"
  parent_id = data.azapi_resource.cluster.id
}

locals {
  server_names = [for server in var.servers : server.name]
}

# This is the module call
# Do not specify location here due to the randomization above.
# Leaving location as `null` will cause the module to use the resource group location
# with a data source.
module "test" {
  source = "../../"
  # source             = "Azure/avm-<res/ptn>-<name>/azurerm"
  # ...

  location                      = data.azurerm_resource_group.rg.location
  count                         = var.enable_insights ? 1 : 0
  resource_group_name           = var.resource_group_name
  server_names                  = local.server_names
  arcSettingId                  = data.azapi_resource.arc_settings.id
  workspace_name                = var.workspace_name
  data_collection_rule_name     = var.data_collection_rule_name
  data_collection_endpoint_name = var.data_collection_endpoint_name
}
