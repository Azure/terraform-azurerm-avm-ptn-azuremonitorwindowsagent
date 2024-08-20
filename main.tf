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

data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
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
  name      = "AzureMonitorWindowsAgent"
  parent_id = var.arc_setting_id
}

resource "azurerm_monitor_data_collection_rule_association" "association" {
  for_each = toset(var.server_names)

  target_resource_id          = "${data.azurerm_resource_group.rg.id}/providers/Microsoft.HybridCompute/machines/${each.value}"
  data_collection_endpoint_id = null
  data_collection_rule_id     = var.data_collection_rule_id
  description                 = null
  name = "DCRA_${md5(
    "${data.azurerm_resource_group.rg.id}/providers/Microsoft.HybridCompute/machines/${each.value}/${var.data_collection_rule_id}"
  )}"
}
