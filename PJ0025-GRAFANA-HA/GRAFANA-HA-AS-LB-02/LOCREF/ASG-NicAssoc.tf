resource "azurerm_resource_group" "application_security_group-rg" {
  name     = "ASG"
  location = "canadacentral"
}

###########Create ASG's ##############################

resource "azurerm_application_security_group" "application_security_group-asg-appservers" {
  name                = "AppServers"
  location            = azurerm_resource_group.application_security_group-rg.location
  resource_group_name = azurerm_resource_group.application_security_group-rg.name
}

resource "azurerm_application_security_group" "application_security_group-asg-dbservers" {
  name                = "DbServers"
  location            = azurerm_resource_group.application_security_group-rg.location
  resource_group_name = azurerm_resource_group.application_security_group-rg.name
}

########### Create AGS-GetNIC and assign ########################

resource "azurerm_application_security_group" "application_security_group-asg-grafana" {
  name                = "grafana"
  location            = azurerm_resource_group.application_security_group-rg.location
  resource_group_name = azurerm_resource_group.application_security_group-rg.name
}


data "azurerm_network_interface" "network_interface-asg-assign" {
  name                = "vm-nic01"
  resource_group_name = "resourceGroup01"
}

resource "azurerm_network_interface_application_security_group_association" "application_security_group_association" {
  network_interface_id          = data.azurerm_network_interface.network_interface-asg-assign.id
  ip_configuration_name         = "ipconfig1"
  application_security_group_id = azurerm_application_security_group.application_security_group-asg-grafana.id
}