<!-- BEGIN_TF_DOCS -->
# terraform-azurerm-avm-ptn-azuremonitorwindowsagent

This is a module to provision AzureStachHCI extension `azuremonitorwindowsagent`.

<!-- markdownlint-disable MD033 -->
## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (~> 1.5)

- <a name="requirement_azapi"></a> [azapi](#requirement\_azapi) (~> 1.13)

- <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) (~> 3.71)

- <a name="requirement_modtm"></a> [modtm](#requirement\_modtm) (~> 0.3)

- <a name="requirement_random"></a> [random](#requirement\_random) (~> 3.5)

## Resources

The following resources are used by this module:

- [azapi_resource.monitor_agent](https://registry.terraform.io/providers/azure/azapi/latest/docs/resources/resource) (resource)
- [azurerm_log_analytics_workspace.workspace](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/log_analytics_workspace) (resource)
- [azurerm_management_lock.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/management_lock) (resource)
- [azurerm_monitor_data_collection_endpoint.dce](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_data_collection_endpoint) (resource)
- [azurerm_monitor_data_collection_rule.dcr](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_data_collection_rule) (resource)
- [azurerm_monitor_data_collection_rule_association.association](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_data_collection_rule_association) (resource)
- [azurerm_role_assignment.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) (resource)
- [modtm_telemetry.telemetry](https://registry.terraform.io/providers/azure/modtm/latest/docs/resources/telemetry) (resource)
- [random_uuid.telemetry](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/uuid) (resource)
- [azurerm_client_config.telemetry](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) (data source)
- [modtm_module_source.telemetry](https://registry.terraform.io/providers/azure/modtm/latest/docs/data-sources/module_source) (data source)

<!-- markdownlint-disable MD013 -->
## Required Inputs

The following input variables are required:

### <a name="input_arc_server_ids"></a> [arc\_server\_ids](#input\_arc\_server\_ids)

Description: The resource IDs of the Azure Arc servers.

Type: `list(string)`

### <a name="input_arc_setting_id"></a> [arc\_setting\_id](#input\_arc\_setting\_id)

Description: The resource ID for the Azure Arc setting.

Type: `string`

### <a name="input_data_collection_resources_location"></a> [data\_collection\_resources\_location](#input\_data\_collection\_resources\_location)

Description: The location of the data collection resources.

Type: `string`

### <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name)

Description: The resource group where the resources will be deployed.

Type: `string`

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_azurerm_monitor_data_collection_rule_association_name"></a> [azurerm\_monitor\_data\_collection\_rule\_association\_name](#input\_azurerm\_monitor\_data\_collection\_rule\_association\_name)

Description: The name of the Azure Monitor Data Collection Rule Association.

Type: `string`

Default: `""`

### <a name="input_cmk_for_query_forced"></a> [cmk\_for\_query\_forced](#input\_cmk\_for\_query\_forced)

Description: (Optional) Is Customer Managed Storage mandatory for query management?

Type: `bool`

Default: `false`

### <a name="input_counter_specifiers"></a> [counter\_specifiers](#input\_counter\_specifiers)

Description: A list of performance counter specifiers.

Type: `list(string)`

Default:

```json
[
  "\\Memory\\Available Bytes",
  "\\Network Interface(*)\\Bytes Total/sec",
  "\\Processor(_Total)\\% Processor Time",
  "\\RDMA Activity(*)\\RDMA Inbound Bytes/sec",
  "\\RDMA Activity(*)\\RDMA Outbound Bytes/sec"
]
```

### <a name="input_create_data_collection_resources"></a> [create\_data\_collection\_resources](#input\_create\_data\_collection\_resources)

Description: Whether to create the data collection resources.

Type: `bool`

Default: `false`

### <a name="input_data_collection_endpoint_name"></a> [data\_collection\_endpoint\_name](#input\_data\_collection\_endpoint\_name)

Description: The name of the Azure Log Analytics data collection endpoint.

Type: `string`

Default: `null`

### <a name="input_data_collection_endpoint_tags"></a> [data\_collection\_endpoint\_tags](#input\_data\_collection\_endpoint\_tags)

Description: A mapping of tags to assign to th data collection endpoint.

Type: `map(string)`

Default: `{}`

### <a name="input_data_collection_rule_destination_id"></a> [data\_collection\_rule\_destination\_id](#input\_data\_collection\_rule\_destination\_id)

Description: The id of data collection rule destination id.

Type: `string`

Default: `"2-90d1-e814dab6067e"`

### <a name="input_data_collection_rule_name"></a> [data\_collection\_rule\_name](#input\_data\_collection\_rule\_name)

Description: The name of the Azure Log Analytics data collection rule.

Type: `string`

Default: `null`

### <a name="input_data_collection_rule_resource_id"></a> [data\_collection\_rule\_resource\_id](#input\_data\_collection\_rule\_resource\_id)

Description: The id of the Azure Log Analytics data collection rule.

Type: `string`

Default: `null`

### <a name="input_data_collection_rule_tags"></a> [data\_collection\_rule\_tags](#input\_data\_collection\_rule\_tags)

Description: A mapping of tags to assign to th data collection rule.

Type: `map(string)`

Default: `{}`

### <a name="input_enable_telemetry"></a> [enable\_telemetry](#input\_enable\_telemetry)

Description: This variable controls whether or not telemetry is enabled for the module.  
For more information see <https://aka.ms/avm/telemetryinfo>.  
If it is set to false, then no telemetry will be collected.

Type: `bool`

Default: `true`

### <a name="input_immediate_data_purge_on_30_days_enabled"></a> [immediate\_data\_purge\_on\_30\_days\_enabled](#input\_immediate\_data\_purge\_on\_30\_days\_enabled)

Description: (Optional) Whether to remove the data in the Log Analytics Workspace immediately after 30 days.

Type: `bool`

Default: `false`

### <a name="input_lock"></a> [lock](#input\_lock)

Description: Controls the Resource Lock configuration for this resource. The following properties can be specified:

- `kind` - (Required) The type of lock. Possible values are `\"CanNotDelete\"` and `\"ReadOnly\"`.
- `name` - (Optional) The name of the lock. If not specified, a name will be generated based on the `kind` value. Changing this forces the creation of a new resource.

Type:

```hcl
object({
    kind = string
    name = optional(string, null)
  })
```

Default: `null`

### <a name="input_name"></a> [name](#input\_name)

Description: The name of the this resource.

Type: `string`

Default: `"AzureMonitorWindowsAgent"`

### <a name="input_retention_in_days"></a> [retention\_in\_days](#input\_retention\_in\_days)

Description: (Optional) The workspace data retention in days. Possible values are either 7 (Free Tier only) or range between 30 and 730.

Type: `number`

Default: `30`

### <a name="input_role_assignments"></a> [role\_assignments](#input\_role\_assignments)

Description: A map of role assignments to create on this resource. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.

- `role_definition_id_or_name` - The ID or name of the role definition to assign to the principal.
- `principal_id` - The ID of the principal to assign the role to.
- `description` - The description of the role assignment.
- `skip_service_principal_aad_check` - If set to true, skips the Azure Active Directory check for the service principal in the tenant. Defaults to false.
- `condition` - The condition which will be used to scope the role assignment.
- `condition_version` - The version of the condition syntax. Valid values are '2.0'.

> Note: only set `skip_service_principal_aad_check` to true if you are assigning a role to a service principal.

Type:

```hcl
map(object({
    role_definition_id_or_name             = string
    principal_id                           = string
    description                            = optional(string, null)
    skip_service_principal_aad_check       = optional(bool, false)
    condition                              = optional(string, null)
    condition_version                      = optional(string, null)
    delegated_managed_identity_resource_id = optional(string, null)
    principal_type                         = optional(string, null)
  }))
```

Default: `{}`

### <a name="input_sku"></a> [sku](#input\_sku)

Description:  (Optional) Specifies the SKU of the Log Analytics Workspace.

Type: `string`

Default: `"PerGB2018"`

### <a name="input_workspace_name"></a> [workspace\_name](#input\_workspace\_name)

Description: The name of the Azure Log Analytics workspace.

Type: `string`

Default: `null`

### <a name="input_workspace_tags"></a> [workspace\_tags](#input\_workspace\_tags)

Description: A mapping of tags to assign to the Azure Log Analytics workspace.

Type: `map(string)`

Default: `{}`

### <a name="input_x_path_queries"></a> [x\_path\_queries](#input\_x\_path\_queries)

Description: A list of XPath queries for event logs.

Type: `list(string)`

Default:

```json
[
  "Microsoft-Windows-SDDC-Management/Operational!*[System[(EventID=3000 or EventID=3001 or EventID=3002 or EventID=3003 or EventID=3004)]]",
  "microsoft-windows-health/operational!*"
]
```

## Outputs

The following outputs are exported:

### <a name="output_resource_id"></a> [resource\_id](#output\_resource\_id)

Description: This is the full output for the resource.

## Modules

No modules.

<!-- markdownlint-disable-next-line MD041 -->
## Data Collection

The software may collect information about you and your use of the software and send it to Microsoft. Microsoft may use this information to provide services and improve our products and services. You may turn off the telemetry as described in the repository. There are also some features in the software that may enable you and Microsoft to collect data from users of your applications. If you use these features, you must comply with applicable law, including providing appropriate notices to users of your applications together with a copy of Microsoft’s privacy statement. Our privacy statement is located at <https://go.microsoft.com/fwlink/?LinkID=824704>. You can learn more about data collection and use in the help documentation and our privacy statement. Your use of the software operates as your consent to these practices.
<!-- END_TF_DOCS -->