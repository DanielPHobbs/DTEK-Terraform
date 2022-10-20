provider "azurerm" {
  features {}
}

resource "azurerm_automation_runbook" "example" {
  name                = "${var.prefix}-Get-AzureVMTutorial"
  location            = "${var.location}"
  resource_group_name = "${var.prefix}-resources"
  automation_account_name = "${var.prefix}-autoacc"
  log_verbose         = "true"
  log_progress        = "true"
  description         = "This is an example runbook"
  runbook_type        = "PowerShellWorkflow"
}

resource "azurerm_automation_schedule" "one-time" {
  name                    = "${var.prefix}-one-time"
  resource_group_name     = "${var.prefix}-resources"
  automation_account_name = "${var.prefix}-autoacc"
  frequency               = "OneTime"

  // The start_time defaults to now + 7 min
}

resource "azurerm_automation_schedule" "hour" {
  name                    = "${var.prefix}-hour"
  resource_group_name     = "${var.prefix}-resources"
  automation_account_name = "${var.prefix}-autoacc"
  frequency               = "Hour"
  interval                = 2

  // Timezone defaults to UTC
}

  // Schedules the example runbook to run on the hour schedule
resource "azurerm_automation_job_schedule" "example" {
  resource_group_name     = "${var.prefix}-resources"
  automation_account_name = "${var.prefix}-autoacc"
  runbook_name            = "${var.prefix}-Get-AzureVMTutorial"
  schedule_name           = "${var.prefix}-hour"
}
