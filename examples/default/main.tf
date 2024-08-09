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
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
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

# This allows us to randomize the region for the resource group.
resource "random_integer" "region_index" {
  max = length(module.regions.regions) - 1
  min = 0
}
## End of section to provide a random Azure region for the resource group

# This ensures we have unique CAF compliant names for our resources.
module "naming" {
  source  = "Azure/naming/azurerm"
  version = "~> 0.3"
}

# This is required for resource modules
data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

data "azapi_resource" "cluster" {
  type      = "Microsoft.AzureStackHCI/clusters@2023-08-01-preview"
  parent_id = data.azurerm_resource_group.rg.id
  name      = var.clusterName
}

data "azapi_resource" "arcSettings" {
  type      = "Microsoft.AzureStackHCI/clusters/ArcSettings@2023-08-01"
  parent_id = data.azapi_resource.cluster.id
  name      = "default"
}

locals {
  serverNames = [for server in var.servers : server.name]
}

# This is the module call
# Do not specify location here due to the randomization above.
# Leaving location as `null` will cause the module to use the resource group location
# with a data source.
module "test" {
  source = "../../"
  # source             = "Azure/avm-<res/ptn>-<name>/azurerm"
  # ...

  location                   = data.azurerm_resource_group.rg.location
  count                      = var.enableInsights ? 1 : 0
  siteId                     = var.siteId
  resource_group_name        = var.resource_group_name
  serverNames                = local.serverNames
  arcSettingId               = data.azapi_resource.arcSettings.id
  workspaceName              = var.workspaceName
  dataCollectionRuleName     = var.dataCollectionRuleName
  dataCollectionEndpointName = var.dataCollectionEndpointName
}
