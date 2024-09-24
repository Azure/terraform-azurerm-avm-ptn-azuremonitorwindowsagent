variable "arc_server_ids" {
  type        = list(string)
  description = "The resource IDs of the Azure Arc servers."
  nullable    = false
}

variable "arc_setting_id" {
  type        = string
  description = "The resource ID for the Azure Arc setting."
}

variable "resource_group_name" {
  type        = string
  description = "The resource group where the resources will be deployed."
}

variable "azurerm_monitor_data_collection_rule_association_name" {
  type        = string
  default     = ""
  description = "The name of the Azure Monitor Data Collection Rule Association."
}

variable "cmk_for_query_forced" {
  type        = bool
  default     = false
  description = "(Optional) Is Customer Managed Storage mandatory for query management?"
}

variable "counter_specifiers" {
  type = list(string)
  default = [
    "\\Memory\\Available Bytes",
    "\\Network Interface(*)\\Bytes Total/sec",
    "\\Processor(_Total)\\% Processor Time",
    "\\RDMA Activity(*)\\RDMA Inbound Bytes/sec",
    "\\RDMA Activity(*)\\RDMA Outbound Bytes/sec"
  ]
  description = "A list of performance counter specifiers."
}

variable "create_data_collection_resources" {
  type        = bool
  default     = false
  description = "Whether to create the data collection resources."
}

variable "data_collection_endpoint_name" {
  type        = string
  default     = null
  description = "The name of the Azure Log Analytics data collection endpoint."

  validation {
    condition     = var.create_data_collection_resources == true ? var.data_collection_endpoint_name != null : true
    error_message = "You must provide 'data_collection_endpoint_name' when 'create_data_collection_resources' is set to true."
  }
}

variable "data_collection_endpoint_tags" {
  type        = map(string)
  default     = {}
  description = "A mapping of tags to assign to th data collection endpoint."
}

variable "data_collection_resources_location" {
  type        = string
  default     = ""
  description = "The location of the data collection resources."

  validation {
    condition     = var.create_data_collection_resources == true ? var.data_collection_resources_location != "" : true
    error_message = "You must provide 'data_collection_resources_location' when 'create_data_collection_resources' is set to true."
  }
}

variable "data_collection_rule_destination_id" {
  type        = string
  default     = "2-90d1-e814dab6067e"
  description = "The id of data collection rule destination id."
}

variable "data_collection_rule_name" {
  type        = string
  default     = null
  description = "The name of the Azure Log Analytics data collection rule."

  validation {
    condition     = var.create_data_collection_resources == true ? var.data_collection_rule_name != null : true
    error_message = "You must provide 'data_collection_rule_name' when 'create_data_collection_resources' is set to true."
  }
}

variable "data_collection_rule_resource_id" {
  type        = string
  default     = null
  description = "The id of the Azure Log Analytics data collection rule."

  validation {
    condition     = var.create_data_collection_resources == false ? var.data_collection_rule_resource_id != null : true
    error_message = "You must provide 'data_collection_rule_resource_id' when 'create_data_collection_resources' is set to false."
  }
}

variable "data_collection_rule_tags" {
  type        = map(string)
  default     = {}
  description = "A mapping of tags to assign to th data collection rule."
}

variable "enable_telemetry" {
  type        = bool
  default     = true
  description = <<DESCRIPTION
This variable controls whether or not telemetry is enabled for the module.
For more information see <https://aka.ms/avm/telemetryinfo>.
If it is set to false, then no telemetry will be collected.
DESCRIPTION
  nullable    = false
}

variable "immediate_data_purge_on_30_days_enabled" {
  type        = bool
  default     = false
  description = "(Optional) Whether to remove the data in the Log Analytics Workspace immediately after 30 days."
}

variable "lock" {
  type = object({
    kind = string
    name = optional(string, null)
  })
  default     = null
  description = <<DESCRIPTION
Controls the Resource Lock configuration for this resource. The following properties can be specified:

- `kind` - (Required) The type of lock. Possible values are `\"CanNotDelete\"` and `\"ReadOnly\"`.
- `name` - (Optional) The name of the lock. If not specified, a name will be generated based on the `kind` value. Changing this forces the creation of a new resource.
DESCRIPTION

  validation {
    condition     = var.lock != null ? contains(["CanNotDelete", "ReadOnly"], var.lock.kind) : true
    error_message = "The lock level must be one of: 'None', 'CanNotDelete', or 'ReadOnly'."
  }
}

variable "name" {
  type        = string
  default     = "AzureMonitorWindowsAgent"
  description = "The name of the this resource."
}

variable "retention_in_days" {
  type        = number
  default     = 30
  description = "(Optional) The workspace data retention in days. Possible values are either 7 (Free Tier only) or range between 30 and 730."
}

variable "role_assignments" {
  type = map(object({
    role_definition_id_or_name             = string
    principal_id                           = string
    description                            = optional(string, null)
    skip_service_principal_aad_check       = optional(bool, false)
    condition                              = optional(string, null)
    condition_version                      = optional(string, null)
    delegated_managed_identity_resource_id = optional(string, null)
    principal_type                         = optional(string, null)
  }))
  default     = {}
  description = <<DESCRIPTION
A map of role assignments to create on this resource. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.

- `role_definition_id_or_name` - The ID or name of the role definition to assign to the principal.
- `principal_id` - The ID of the principal to assign the role to.
- `description` - The description of the role assignment.
- `skip_service_principal_aad_check` - If set to true, skips the Azure Active Directory check for the service principal in the tenant. Defaults to false.
- `condition` - The condition which will be used to scope the role assignment.
- `condition_version` - The version of the condition syntax. Valid values are '2.0'.

> Note: only set `skip_service_principal_aad_check` to true if you are assigning a role to a service principal.
DESCRIPTION
  nullable    = false
}

variable "sku" {
  type        = string
  default     = "PerGB2018"
  description = " (Optional) Specifies the SKU of the Log Analytics Workspace."
}

variable "workspace_name" {
  type        = string
  default     = null
  description = "The name of the Azure Log Analytics workspace."

  validation {
    condition     = var.create_data_collection_resources == true ? var.workspace_name != null : true
    error_message = "You must provide 'workspace_name' when 'create_data_collection_resources' is set to true."
  }
}

variable "workspace_tags" {
  type        = map(string)
  default     = {}
  description = "A mapping of tags to assign to the Azure Log Analytics workspace."
}

variable "x_path_queries" {
  type = list(string)
  default = [
    "Microsoft-Windows-SDDC-Management/Operational!*[System[(EventID=3000 or EventID=3001 or EventID=3002 or EventID=3003 or EventID=3004)]]",
    "microsoft-windows-health/operational!*"
  ]
  description = "A list of XPath queries for event logs."
}
