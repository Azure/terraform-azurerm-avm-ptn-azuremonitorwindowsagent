terraform {
  required_version = "~> 1.5"

  required_providers {
    azapi = {
      source  = "azure/azapi"
      version = "~> 2.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

provider "azurerm" {
  subscription_id = "0000000-0000-00000-000000"
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

# This is required for resource modules
data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

data "azapi_resource" "cluster" {
  name      = var.cluster_name
  parent_id = data.azurerm_resource_group.rg.id
  type      = "Microsoft.AzureStackHCI/clusters@2023-08-01-preview"
}

data "azapi_resource" "arc_settings" {
  name      = "default"
  parent_id = data.azapi_resource.cluster.id
  type      = "Microsoft.AzureStackHCI/clusters/ArcSettings@2023-08-01"
}

locals {
  arc_server_ids = { for server in var.servers : server.name => "${data.azurerm_resource_group.rg.id}/providers/Microsoft.HybridCompute/machines/${server.name}" }
}

# This is the module call
# Do not specify location here due to the randomization above.
# Leaving location as `null` will cause the module to use the resource group location
# with a data source.
module "test" {
  source = "../../"
  count  = var.enable_insights ? 1 : 0

  arc_server_ids                   = local.arc_server_ids
  arc_setting_id                   = data.azapi_resource.arc_settings.id
  resource_group_name              = var.resource_group_name
  data_collection_rule_resource_id = var.data_collection_rule_resource_id
  enable_telemetry                 = var.enable_telemetry
}
