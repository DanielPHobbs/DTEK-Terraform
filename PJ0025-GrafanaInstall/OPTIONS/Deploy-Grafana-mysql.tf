provider "azurerm" {
  features {}
}

# refer to an existing resource group
data "azurerm_resource_group" "rg" {
    name = "RG-GRAFANA1"
    }


# Create mysql Instance 
resource "azurerm_mysql_server" "grafanaDB" {
  name                = "Grafana-mysqlserver"
  location            = "${var.location}"
  resource_group_name = "${data.azurerm_resource_group.rg.name}"

  administrator_login          = "mysqladminun"
  administrator_login_password = "H@Sh1CoR3!"

  sku_name   = "B_Gen5_2"
  storage_mb = 5120
  version    = "5.7"

  auto_grow_enabled                 = true
  backup_retention_days             = 7
  geo_redundant_backup_enabled      = true
  infrastructure_encryption_enabled = true
  public_network_access_enabled     = false
  ssl_enforcement_enabled           = true
  ssl_minimal_tls_version_enforced  = "TLS1_2"
}