mock_provider "azapi" {}
mock_provider "azurerm" {}
mock_provider "modtm" {}
mock_provider "random" {}

run "uses_external_rule_without_creating_data_collection_resources" {
  command = plan

  variables {
    location                         = "eastus2"
    resource_group_name              = "rg-test"
    arc_setting_id                   = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.AzureStackHCI/clusters/test/ArcSettings/default"
    arc_server_ids                   = { test = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.HybridCompute/machines/test" }
    data_collection_rule_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Insights/dataCollectionRules/existing"
    create_data_collection_resources = false
    enable_telemetry                 = false
  }

  assert {
    condition = alltrue([
      length(azurerm_log_analytics_workspace.workspace) == 0,
      length(azurerm_monitor_data_collection_endpoint.dce) == 0,
      length(azurerm_monitor_data_collection_rule.dcr) == 0,
    ])
    error_message = "Using an existing rule must not create a workspace, DCE, or DCR."
  }

  assert {
    condition     = azurerm_monitor_data_collection_rule_association.association["test"].data_collection_rule_id == var.data_collection_rule_resource_id
    error_message = "The association must continue using the supplied existing rule."
  }
}

run "uses_location_for_new_data_collection_resources" {
  command = plan

  variables {
    location                         = "eastus2"
    resource_group_name              = "rg-test"
    arc_setting_id                   = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.AzureStackHCI/clusters/test/ArcSettings/default"
    arc_server_ids                   = {}
    create_data_collection_resources = true
    data_collection_endpoint_name    = "dce-test"
    data_collection_rule_name        = "dcr-test"
    workspace_name                   = "law-test"
    enable_telemetry                 = false
  }

  assert {
    condition = alltrue([
      azurerm_log_analytics_workspace.workspace[0].location == var.location,
      azurerm_monitor_data_collection_endpoint.dce[0].location == var.location,
      azurerm_monitor_data_collection_rule.dcr[0].location == var.location,
    ])
    error_message = "All created data collection resources must use the required location."
  }
}
