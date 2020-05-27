#https://www.terraform.io/docs/providers/azurerm/r/mysql_database.html

provider "azurerm" {
  features {}
}

# refer to an existing resource group
data "azurerm_resource_group" "rg" {
    name = "RG-GRAFANA1"
    }


# Create mysql Instance 
resource "azurerm_mysql_server" "grafanasrv" {
  name                = "Grafana-mysqlserver"
  location            = "${var.location}"
  resource_group_name = "${data.azurerm_resource_group.rg.name}"

  administrator_login          = "grafanamysqladmin"
  administrator_login_password = "H@Sh1CoR3!"

  sku_name   = "B_Gen5_2"


  storage_profile {
    storage_mb            = 5120
    backup_retention_days = 7
    geo_redundant_backup  = "Disabled"
  }

  auto_grow_enabled                 = true
  backup_retention_days             = 7
  geo_redundant_backup_enabled      = true
  infrastructure_encryption_enabled = true
  public_network_access_enabled     = false
  ssl_enforcement_enabled           = true
  ssl_minimal_tls_version_enforced  = "TLS1_2"
}

resource "azurerm_mysql_database" "GrafanaDB" {
  name                = "grafanadb"
  resource_group_name = "${data.azurerm_resource_group.rg.name}"
  server_name         = "${azurerm_mysql_server.grafanasrv.name}"
  charset             = "utf8"
  collation           = "utf8_unicode_ci"
}