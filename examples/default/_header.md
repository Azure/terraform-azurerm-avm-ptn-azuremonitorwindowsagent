# Default example

This example targets an existing, registered Azure Stack HCI cluster. Set
`ARM_SUBSCRIPTION_ID` to the intended non-production subscription, and provide
`cluster_name`, `resource_group_name`, and `data_collection_rule_resource_id`
for resources in that subscription. The cluster's ArcSettings and the specified
Arc-enabled servers must already exist. Set `enable_insights = true` to deploy
the extension; the default is `false`.
