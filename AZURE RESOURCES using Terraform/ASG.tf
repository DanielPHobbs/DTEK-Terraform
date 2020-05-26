#https://www.terraform.io/docs/providers/azurerm/r/network_interface_application_security_group_association.html

resource "azurerm_resource_group" "example" {
  name     = "example-resources"
  location = "West Europe"
}

resource "azurerm_virtual_network" "example" {
  name                = "example-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_subnet" "example" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefix       = "10.0.1.0/24"
}

resource "azurerm_application_security_group" "example" {
  name                = "example-asg"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_network_interface" "example" {
  name                = "example-nic"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  ip_configuration {
    name                           = "testconfiguration1"
    subnet_id                      = azurerm_subnet.example.id
    private_ip_address_allocation  = "Dynamic"
    application_security_group_ids = [azurerm_application_security_group.example.id]
  }
}

resource "azurerm_network_interface_application_security_group_association" "example" {
  network_interface_id          = azurerm_network_interface.example.id
  application_security_group_id = azurerm_application_security_group.example.id
}