#https://www.terraform.io/docs/providers/azurerm/r/mysql_database.html

#https://azure.microsoft.com/en-gb/pricing/details/mysql/

provider "azurerm" {
  # The "feature" block is required for AzureRM provider 2.x. 
  # If you are using version 1.x, the "features" block is not allowed.
  version = "~>2.0"
  features {}
  
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

   #{pricing tier}_{compute generation}_{vCores} £0.060/hour GB/month	£0.089
  sku_name   = "B_Gen5_2"


  storage_profile {
    storage_mb            = 2048
    backup_retention_days = 7
    geo_redundant_backup  = "Disabled"
  }

  auto_grow_enabled                 = true
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


#use one of these 
resource "azurerm_mysql_firewall_rule" "grafanafw1" {
  name                = "grafanafw-r1"
  resource_group_name = "${data.azurerm_resource_group.rg.name}"
  server_name         = "${azurerm_mysql_server.grafanasrv.name}"
  #add the grafana subnet startand end addresses
  start_ip_address    = "40.112.0.0"
  end_ip_address      = "40.112.255.255"
}
resource "azurerm_mysql_virtual_network_rule" "example" {
  name                = "grafana-mysql-vnet-rule"
  resource_group_name = "${data.azurerm_resource_group.rg.name}"
  server_name         = "${azurerm_mysql_server.grafanasrv.name}"
  subnet_id           = "${var.NWDeploySubNet.subnet_id}"
}
