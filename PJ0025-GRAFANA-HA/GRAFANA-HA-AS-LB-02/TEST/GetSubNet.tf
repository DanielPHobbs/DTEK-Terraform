provider "azurerm" {
        features {}
}

data "azurerm_subnet" "example" {
  name                 = "DTEK-FRONTEND-SN1"
  virtual_network_name = "DTEK-PRODUCTION-Vnet1"
  resource_group_name  = "DTEKSVRAccessRG1"
}

output "subnet_id" {
  value = data.azurerm_subnet.example.id
}

