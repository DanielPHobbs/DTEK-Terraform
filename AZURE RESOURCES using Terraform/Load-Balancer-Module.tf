#https://registry.terraform.io/modules/Azure/loadbalancer/azurerm/1.0.0

module "mylb" {
  source   = "github.com/Azure/terraform-azurerm-loadbalancer"
  location = "North Central US"
  "remote_port" {
    ssh = ["Tcp", "22"]
  }
  "lb_port" {
    http = ["80", "Tcp", "80"]
    https = ["443", "Tcp", "443"]
  }
  "tags" {
    cost-center = "12345"
    source     = "terraform"
  }
}

#https://github.com/Azure/terraform-azurerm-loadbalancer
#Private Load Balancer

module "mylb" {
  source                                 = "Azure/loadbalancer/azurerm"
  location                               = "westus"
  type                                   = "private"
  frontend_subnet_id                     = "${module.network.vnet_subnets[0]}"
  frontend_private_ip_address_allocation = "Static"
  frontend_private_ip_address            = "10.0.1.6"

  "remote_port" {
    ssh = ["Tcp", "22"]
  }

  "lb_port" {
    http  = ["80", "Tcp", "80"]
    https = ["443", "Tcp", "443"]
  }

  "tags" {
    cost-center = "12345"
    source      = "terraform"
  }
}

module "network" {
  source              = "Azure/network/azurerm"
  resource_group_name = "myapp"
  location            = "westus"
  address_space       = "10.0.0.0/16"
  subnet_prefixes     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  subnet_names        = ["subnet1", "subnet2", "subnet3"]

  tags = {
    environment = "dev"
    costcenter  = "it"
  }
}

#https://github.com/deck15/terraform-azure-loadbalancer

resource "azurerm_resource_group" "rg" {
  name = "${var.resource_group_name}"
  location = "westus"

  tags = {
    environment = "nonprod"
    costcenter  = "12345"
    appname     = "myapp"
  }
}

module "mylb" {
  source  = "github.com/highwayoflife/terraform-azure-loadbalancer"
  type    = "Public"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  prefix              = "terraform-test"

  "remote_port" {
    ssh = ["Tcp", "22"]
  }

  "lb_port" {
    http = ["443", "Tcp", "443"]
  }
}