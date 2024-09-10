<!-- BEGIN_TF_DOCS -->
# Default example

This deploys the module in its simplest form.

```hcl
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
  }
}

provider "azurerm" {
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
  # source             = "Azure/avm-ptn-azuremonitorwindowsagent/azurerm"
  # version = "~> 0.1.0"

  enable_telemetry = var.enable_telemetry

  count                            = var.enable_insights ? 1 : 0
  resource_group_name              = var.resource_group_name
  server_names                     = local.server_names
  arc_setting_id                   = data.azapi_resource.arc_settings.id
  data_collection_rule_resource_id = var.data_collection_rule_resource_id
}
```

<!-- markdownlint-disable MD033 -->
## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (~> 1.5)

- <a name="requirement_azapi"></a> [azapi](#requirement\_azapi) (~> 1.13)

- <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) (~> 3.74)

## Resources

The following resources are used by this module:

- [azapi_resource.arc_settings](https://registry.terraform.io/providers/azure/azapi/latest/docs/data-sources/resource) (data source)
- [azapi_resource.cluster](https://registry.terraform.io/providers/azure/azapi/latest/docs/data-sources/resource) (data source)
- [azurerm_resource_group.rg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) (data source)

<!-- markdownlint-disable MD013 -->
## Required Inputs

The following input variables are required:

### <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name)

Description: The name of the HCI cluster. Must be the same as the name when preparing AD.

Type: `string`

### <a name="input_data_collection_rule_resource_id"></a> [data\_collection\_rule\_resource\_id](#input\_data\_collection\_rule\_resource\_id)

Description: The id of the Azure Log Analytics data collection rule.

Type: `string`

### <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name)

Description: The resource group name for the Azure Stack HCI cluster.

Type: `string`

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_enable_insights"></a> [enable\_insights](#input\_enable\_insights)

Description: Whether to enable Azure Monitor Insights.

Type: `bool`

Default: `false`

### <a name="input_enable_telemetry"></a> [enable\_telemetry](#input\_enable\_telemetry)

Description: This variable controls whether or not telemetry is enabled for the module.  
For more information see <https://aka.ms/avm/telemetryinfo>.  
If it is set to false, then no telemetry will be collected.

Type: `bool`

Default: `true`

### <a name="input_servers"></a> [servers](#input\_servers)

Description: A list of servers with their names and IPv4 addresses.

Type:

```hcl
list(object({
    name        = string
    ipv4Address = string
  }))
```

Default:

```json
[
  {
    "ipv4Address": "192.168.1.12",
    "name": "AzSHOST1"
  },
  {
    "ipv4Address": "192.168.1.13",
    "name": "AzSHOST2"
  }
]
```

## Outputs

No outputs.

## Modules

The following Modules are called:

### <a name="module_test"></a> [test](#module\_test)

Source: ../../

Version:

<!-- markdownlint-disable-next-line MD041 -->
## Data Collection

The software may collect information about you and your use of the software and send it to Microsoft. Microsoft may use this information to provide services and improve our products and services. You may turn off the telemetry as described in the repository. There are also some features in the software that may enable you and Microsoft to collect data from users of your applications. If you use these features, you must comply with applicable law, including providing appropriate notices to users of your applications together with a copy of Microsoft’s privacy statement. Our privacy statement is located at <https://go.microsoft.com/fwlink/?LinkID=824704>. You can learn more about data collection and use in the help documentation and our privacy statement. Your use of the software operates as your consent to these practices.
<!-- END_TF_DOCS -->