resource "azurerm_scheduled_query_rule" "example" {
  name                   = format("%s-queryrule", var.prefix)
  location               = azurerm_resource_group.example.location
  resource_group_name    = azurerm_resource_group.example.name

  action_type              = "Alerting"
  azns_action {
    action_group           = []
    email_subject          = "Email Header"
    custom_webhook_payload = "{}"
  }
  data_source_id           = azurerm_application_insights.example.id
  description              = "Scheduled query rule Alerting Action example"
  enabled                  = true
  frequency                = 5
  query                    = "requests | where status_code >= 500 | summarize AggregatedValue = count() by bin(timestamp, 5m)"
  query_type               = "ResultCount"
  severity                 = 1
  time_window              = 30
  trigger {
    threshold_operator     = "GreaterThan"
    threshold              = 3
    metric_trigger {
      operator            = "GreaterThan"
      threshold           = 1
      metric_trigger_type = "Total"
      metric_column       = "timestamp"
    }
  }
}