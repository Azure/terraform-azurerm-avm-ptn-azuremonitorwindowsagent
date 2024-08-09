# required AVM resources interfaces
resource "azurerm_management_lock" "this" {
  count = var.lock != null ? 1 : 0

  lock_level = var.lock.kind
  name       = coalesce(var.lock.name, "lock-${var.lock.kind}")
  scope      = azapi_resource.monitor_agent.id # TODO: Replace with your azurerm resource name
  notes      = var.lock.kind == "CanNotDelete" ? "Cannot delete the resource or its child resources." : "Cannot delete or modify the resource or its child resources."
}

resource "azurerm_role_assignment" "this" {
  for_each = var.role_assignments

  principal_id                           = each.value.principal_id
  scope                                  = azapi_resource.monitor_agent.id # TODO: Replace this dummy resource azurerm_resource_group.TODO with your module resource
  condition                              = each.value.condition
  condition_version                      = each.value.condition_version
  delegated_managed_identity_resource_id = each.value.delegated_managed_identity_resource_id
  role_definition_id                     = strcontains(lower(each.value.role_definition_id_or_name), lower(local.role_definition_resource_substring)) ? each.value.role_definition_id_or_name : null
  role_definition_name                   = strcontains(lower(each.value.role_definition_id_or_name), lower(local.role_definition_resource_substring)) ? null : each.value.role_definition_id_or_name
  skip_service_principal_aad_check       = each.value.skip_service_principal_aad_check
}

data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

resource "azurerm_log_analytics_workspace" "workspace" {
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  name                = var.workspace_name
}

resource "azurerm_monitor_data_collection_endpoint" "dce" {
  resource_group_name           = data.azurerm_resource_group.rg.name
  location                      = data.azurerm_resource_group.rg.location
  name                          = var.data_collection_endpoint_name
  public_network_access_enabled = true
}

resource "azurerm_monitor_data_collection_rule" "dcr" {
  data_collection_endpoint_id = azurerm_monitor_data_collection_endpoint.dce.id
  location                    = data.azurerm_resource_group.rg.location
  name                        = var.data_collection_rule_name
  resource_group_name         = data.azurerm_resource_group.rg.name
  data_flow {
    destinations       = [var.workspace_name]
    streams            = ["Microsoft-Perf"]
    built_in_transform = null
    transform_kql      = null
    output_stream      = null
  }
  data_flow {
    destinations       = ["2-90d1-e814dab6067e"]
    streams            = ["Microsoft-Event"]
    built_in_transform = null
    output_stream      = null
    transform_kql      = null
  }
  data_sources {
    performance_counter {
      counter_specifiers = [
        "\\Memory\\Available Bytes",
        "\\Network Interface(*)\\Bytes Total/sec",
        "\\Processor(_Total)\\% Processor Time",
        "\\RDMA Activity(*)\\RDMA Inbound Bytes/sec",
        "\\RDMA Activity(*)\\RDMA Outbound Bytes/sec"
      ]
      name                          = "perfCounterDataSource"
      sampling_frequency_in_seconds = 10
      streams                       = ["Microsoft-Perf"]
    }
    windows_event_log {
      name    = "eventLogsDataSource"
      streams = ["Microsoft-Event"]
      x_path_queries = [
        "Microsoft-Windows-SDDC-Management/Operational!*[System[(EventID=3000 or EventID=3001 or EventID=3002 or EventID=3003 or EventID=3004)]]",
        "microsoft-windows-health/operational!*"
      ]
    }
  }
  destinations {
    log_analytics {
      name                  = var.workspace_name
      workspace_resource_id = azurerm_log_analytics_workspace.workspace.id
    }
    log_analytics {
      name                  = "2-90d1-e814dab6067e"
      workspace_resource_id = azurerm_log_analytics_workspace.workspace.id
    }
  }
}

resource "azapi_resource" "monitor_agent" {
  type      = "Microsoft.AzureStackHCI/clusters/ArcSettings/Extensions@2023-08-01"
  parent_id = var.arcSettingId
  name      = "AzureMonitorWindowsAgent"
  body = {
    properties = {
      extensionParameters = {
        autoUpgradeMinorVersion = false
        enableAutomaticUpgrade  = true
        publisher               = "Microsoft.Azure.Monitor"
        type                    = "AzureMonitorWindowsAgent"
        settings                = {}
      }
    }
  }
}

resource "azurerm_monitor_data_collection_rule_association" "association" {
  for_each                    = toset(var.server_names)
  data_collection_endpoint_id = null
  data_collection_rule_id     = azurerm_monitor_data_collection_rule.dcr.id
  description                 = null
  name = "DCRA_${md5(
    "${data.azurerm_resource_group.rg.id}/providers/Microsoft.HybridCompute/machines/${each.value}/${azurerm_monitor_data_collection_rule.dcr.id}"
  )}"
  target_resource_id = "${data.azurerm_resource_group.rg.id}/providers/Microsoft.HybridCompute/machines/${each.value}"
}
