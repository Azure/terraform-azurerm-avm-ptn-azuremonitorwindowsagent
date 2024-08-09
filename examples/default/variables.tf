variable "enable_telemetry" {
  type        = bool
  default     = true
  description = <<DESCRIPTION
This variable controls whether or not telemetry is enabled for the module.
For more information see <https://aka.ms/avm/telemetryinfo>.
If it is set to false, then no telemetry will be collected.
DESCRIPTION
}

variable "siteId" {
  description = "A unique identifier for the site."
  type        = string
}

variable "resource_group_name" {
  description = "The resource group name for the Azure Stack HCI cluster."
  type        = string
}

variable "workspaceName" {
  description = "The name of the Azure Log Analytics workspace."
  type        = string
}

variable "dataCollectionRuleName" {
  description = "The name of the Azure Log Analytics data collection rule."
  type        = string
}

variable "dataCollectionEndpointName" {
  description = "The name of the Azure Log Analytics data collection endpoint."
  type        = string
}

variable "enableInsights" {
  description = "Whether to enable Azure Monitor Insights."
  type        = bool
  default     = false
}

variable "enableAlerts" {
  description = "Whether to enable Azure Monitor Alerts."
  type        = bool
  default     = false
}

variable "clusterName" {
  type = string
  description = "The name of the HCI cluster. Must be the same as the name when preparing AD."
  validation {
    condition     = length(var.clusterName) < 16 && length(var.clusterName) > 0
    error_message = "value of clusterName should be less than 16 characters and greater than 0 characters"
  }
}

variable "servers" {
  type = list(object({
    name        = string
    ipv4Address = string
  }))
  description = "A list of servers with their names and IPv4 addresses."
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
}
