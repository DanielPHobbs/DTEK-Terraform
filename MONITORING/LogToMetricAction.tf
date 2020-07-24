resource "azurerm_scheduled_query_rule" "example3" {
  name                   = format("%s-queryrule3", var.prefix)
  location               = azurerm_resource_group.example.location
  resource_group_name    = azurerm_resource_group.example.name

  action_type            = "LogToMetricAction"
  criteria               = [{
      metric_name        = "Average_% Idle Time"
      dimensions         = [{
        name             = "dimension"
        operator         = "GreaterThan"
        values           = ["latency"]
      }]
  }]
  data_source_id         = azurerm_application_insights.example.id
  description            = "Scheduled query rule LogToMetric example"
  enabled                = true
}