resource "azurerm_resource_group" "example" {
  name     = "tf-test"
  location = "West Europe"
}

resource "azurerm_application_security_group" "example" {
  name                = "tf-appsecuritygroup"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  tags = {
    Hello = "World"
  }
}