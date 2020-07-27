#https://www.terraform.io/docs/providers/azurerm/r/application_gateway.html

#£0.0209 per gateway hour (~£15.235/month)

data "azurerm_resource_group" "rg" {
    name = "RG-GRAFANA1"
    }





resource "azurerm_subnet" "frontend" {
  name                 = "grafana-frontend"
  resource_group_name  = "${data.azurerm_resource_group.rg.name}"
  virtual_network_name = "${var.NWDeployVNET}"
  address_prefix       = "10.254.0.0/24"
}

resource "azurerm_subnet" "backend" {
  name                 = "grafana-backend"
  resource_group_name  = "${data.azurerm_resource_group.rg.name}"
  virtual_network_name = "${var.NWDeployVNET}"
  address_prefix       = "10.254.2.0/24" #/28
}

resource "azurerm_public_ip" "example" {
  name                = "grafana-pip"
  resource_group_name = "${data.azurerm_resource_group.rg.name}"
  location            = "${data.azurerm_resource_group.rg.location}"
  allocation_method   = "Dynamic"
}

# since these variables are re-used - a locals block makes this more maintainable
locals {
  backend_address_pool_name      = "${var.NWDeployVNET}-beap"
  frontend_port_name             = "${var.NWDeployVNET}-feport"
  frontend_ip_configuration_name = "${var.NWDeployVNET}-feip"
  http_setting_name              = "${var.NWDeployVNET}-be-htst"
  listener_name                  = "${var.NWDeployVNET}-httplstn"
  request_routing_rule_name      = "${var.NWDeployVNET}-rqrt"
  redirect_configuration_name    = "${var.NWDeployVNET}-rdrcfg"
}

resource "azurerm_application_gateway" "network" {
  name                = "grafana-appgateway"
  resource_group_name = "${data.azurerm_resource_group.rg.name}"
  location            = "${data.azurerm_resource_group.rg.location}"
  sku {
    name     = "Standard_Small"
    tier     = "Standard"
    capacity = 2
  }

  gateway_ip_configuration {
    name      = "grafana-gateway-ip-configuration"
    subnet_id = "${azurerm_subnet.frontend.id}"
  }

  frontend_port {
    name =  local.frontend_port_name
    port = 80
  }

  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.example.id
  }

  backend_address_pool {
    name = local.backend_address_pool_name
  }

  backend_http_settings {
    name                  = local.http_setting_name
    cookie_based_affinity = "Disabled"
    path                  = "/path1/"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 1
  }

  http_listener {
    name                           = local.listener_name
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = local.frontend_port_name
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = local.request_routing_rule_name
    rule_type                  = "Basic"
    http_listener_name         = local.listener_name
    backend_address_pool_name  = local.backend_address_pool_name
    backend_http_settings_name = local.http_setting_name
  }
}