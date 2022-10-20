provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "${var.prefix}-logAnalytics"
  location = var.location
}

resource "azurerm_log_analytics_workspace" "example" {
  name                = "${var.prefix}-la-workspace"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  sku                 = "PerGB2018"
}
