# required AVM resources interfaces
resource "azurerm_management_lock" "this" {
  count = var.lock != null ? 1 : 0

  lock_level = var.lock.kind
  name       = coalesce(var.lock.name, "lock-${var.lock.kind}")
  scope      = azapi_resource.monitor_agent.id
  notes      = var.lock.kind == "CanNotDelete" ? "Cannot delete the resource or its child resources." : "Cannot delete or modify the resource or its child resources."
}

resource "azurerm_role_assignment" "this" {
  for_each = var.role_assignments

  principal_id                           = each.value.principal_id
  scope                                  = azapi_resource.monitor_agent.id
  condition                              = each.value.condition
  condition_version                      = each.value.condition_version
  delegated_managed_identity_resource_id = each.value.delegated_managed_identity_resource_id
  role_definition_id                     = strcontains(lower(each.value.role_definition_id_or_name), lower(local.role_definition_resource_substring)) ? each.value.role_definition_id_or_name : null
  role_definition_name                   = strcontains(lower(each.value.role_definition_id_or_name), lower(local.role_definition_resource_substring)) ? null : each.value.role_definition_id_or_name
  skip_service_principal_aad_check       = each.value.skip_service_principal_aad_check
}

resource "azurerm_log_analytics_workspace" "workspace" {
  count = var.create_data_collection_resources ? 1 : 0

  location                                = var.data_collection_resources_location
  name                                    = var.workspace_name
  resource_group_name                     = var.resource_group_name
  cmk_for_query_forced                    = var.cmk_for_query_forced
  immediate_data_purge_on_30_days_enabled = var.immediate_data_purge_on_30_days_enabled
  retention_in_days                       = var.retention_in_days
  sku                                     = var.sku
  tags                                    = var.workspace_tags
}

resource "azurerm_monitor_data_collection_endpoint" "dce" {
  count = var.create_data_collection_resources ? 1 : 0

  location                      = var.data_collection_resources_location
  name                          = var.data_collection_endpoint_name
  resource_group_name           = var.resource_group_name
  public_network_access_enabled = true
  tags                          = var.data_collection_endpoint_tags
}

resource "azurerm_monitor_data_collection_rule" "dcr" {
  count = var.create_data_collection_resources ? 1 : 0

  location                    = var.data_collection_resources_location
  name                        = var.data_collection_rule_name
  resource_group_name         = var.resource_group_name
  data_collection_endpoint_id = azurerm_monitor_data_collection_endpoint.dce[0].id
  tags                        = var.data_collection_rule_tags

  data_flow {
    destinations       = [var.workspace_name]
    streams            = ["Microsoft-Perf"]
    built_in_transform = null
    output_stream      = null
    transform_kql      = null
  }
  data_flow {
    destinations       = [var.data_collection_rule_destination_id]
    streams            = ["Microsoft-Event"]
    built_in_transform = null
    output_stream      = null
    transform_kql      = null
  }
  destinations {
    log_analytics {
      name                  = var.workspace_name
      workspace_resource_id = azurerm_log_analytics_workspace.workspace[0].id
    }
    log_analytics {
      name                  = var.data_collection_rule_destination_id
      workspace_resource_id = azurerm_log_analytics_workspace.workspace[0].id
    }
  }
  data_sources {
    performance_counter {
      counter_specifiers            = var.counter_specifiers
      name                          = "perfCounterDataSource"
      sampling_frequency_in_seconds = 10
      streams                       = ["Microsoft-Perf"]
    }
    windows_event_log {
      name           = "eventLogsDataSource"
      streams        = ["Microsoft-Event"]
      x_path_queries = var.x_path_queries
    }
  }
}

resource "azapi_resource" "monitor_agent" {
  type = "Microsoft.AzureStackHCI/clusters/ArcSettings/Extensions@2023-08-01"
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
  name      = var.name
  parent_id = var.arc_setting_id
}

resource "azurerm_monitor_data_collection_rule_association" "association" {
  for_each = var.arc_server_ids

  target_resource_id          = each.value
  data_collection_endpoint_id = null
  data_collection_rule_id     = var.create_data_collection_resources ? azurerm_monitor_data_collection_rule.dcr[0].id : var.data_collection_rule_resource_id
  description                 = null
  # Determines the value of the name based on the following conditions:
  # 1. If 'azurerm_monitor_data_collection_rule_association_name' is not empty, it will be used as the 'name'.
  # 2. Otherwise, if 'create_data_collection_resources' is true, the name will be generated using the MD5 hash of the resource group ID and the 'azurerm_monitor_data_collection_rule.dcr[0].id'.
  # 3. If 'create_data_collection_resources' is false, the name will be generated using the MD5 hash of the resource group ID and the 'data_collection_rule_resource_id' variable.
  name = var.azurerm_monitor_data_collection_rule_association_name != "" ? var.azurerm_monitor_data_collection_rule_association_name : (
  var.create_data_collection_resources ? "DCRA_${md5("${each.value}/${azurerm_monitor_data_collection_rule.dcr[0].id}")}" : "DCRA_${md5("${each.value}/${var.data_collection_rule_resource_id}")}")
}
