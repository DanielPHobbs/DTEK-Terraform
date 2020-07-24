resource "azurerm_resource_group" "example" {
  name     = "monitoring-resources"
  location = "West US"
}

resource "azurerm_log_analytics_workspace" "example" {
  name                = "loganalytics"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

# Example: LogToMetric Action for the named Computer
resource "azurerm_scheduled_query_rule_log" "example" {
  name                = format("%s-queryrule", var.prefix)
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  criteria {
    metric_name = "Average_% Idle Time"
    dimensions {
      name     = "Computer"
      operator = "Include"
      values   = ["targetVM"]
    }
  }
  data_source_id = azurerm_log_analytics_workspace.example.id
  description    = "Scheduled query rule LogToMetric example"
  enabled        = true
}

resource "azurerm_monitor_action_group" "example" {
  name                = "example-actiongroup"
  resource_group_name = azurerm_resource_group.example.name
  short_name          = "exampleact"

  webhook_receiver {
    name        = "callmyapi"
    service_uri = "http://example.com/alert"
  }
}

# Example: Creates alert using the new Scheduled Query Rules metric
resource "azurerm_monitor_metric_alert" "example" {
  name                = "example-metricalert"
  resource_group_name = azurerm_resource_group.example.name
  scopes              = [azurerm_log_analytics_workspace.example.id]
  description         = "Action will be triggered when Average_% Idle Time metric is less than 10."
  frequency           = "PT1M"
  window_size         = "PT5M"

  criteria {
    metric_namespace = "Microsoft.OperationalInsights/workspaces"
    metric_name      = azurerm_scheduled_query_rules_log.example.criteria[0].metric_name
    aggregation      = "Average"
    operator         = "LessThan"
    threshold        = 10
  }

  action {
    action_group_id = azurerm_monitor_action_group.example.id
  }
}


#scriptions/00000000-0000-0000-0000-000000000000/resourceGroups/group1/providers/Microsoft.Insights/scheduledQueryRules/myrulename