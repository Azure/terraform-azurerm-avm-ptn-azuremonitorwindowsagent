variable "cluster_name" {
  type        = string
  description = "The name of the HCI cluster. Must be the same as the name when preparing AD."

  validation {
    condition     = length(var.cluster_name) < 16 && length(var.cluster_name) > 0
    error_message = "value of cluster_name should be less than 16 characters and greater than 0 characters"
  }
}

variable "data_collection_endpoint_name" {
  type        = string
  description = "The name of the Azure Log Analytics data collection endpoint."
}

variable "data_collection_rule_id" {
  type        = string
  description = "The id of the Azure Log Analytics data collection rule."
}

variable "resource_group_name" {
  type        = string
  description = "The resource group name for the Azure Stack HCI cluster."
}

variable "workspace_name" {
  type        = string
  description = "The name of the Azure Log Analytics workspace."
}

variable "enable_insights" {
  type        = bool
  default     = false
  description = "Whether to enable Azure Monitor Insights."
}

variable "enable_telemetry" {
  type        = bool
  default     = true
  description = <<DESCRIPTION
This variable controls whether or not telemetry is enabled for the module.
For more information see <https://aka.ms/avm/telemetryinfo>.
If it is set to false, then no telemetry will be collected.
DESCRIPTION
}

variable "servers" {
  type = list(object({
    name        = string
    ipv4Address = string
  }))
  default = [
    {
      name        = "AzSHOST1",
      ipv4Address = "192.168.1.12"
    },
    {
      name        = "AzSHOST2",
      ipv4Address = "192.168.1.13"
    }
  ]
  description = "A list of servers with their names and IPv4 addresses."
}
