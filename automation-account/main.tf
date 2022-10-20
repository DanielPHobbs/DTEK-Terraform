provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "${var.prefix}-automation-resources"
  location = var.location
}

resource "azurerm_automation_account" "example" {
  name                = "${var.prefix}-autoacc"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  sku_name            = "Basic"
  
}

