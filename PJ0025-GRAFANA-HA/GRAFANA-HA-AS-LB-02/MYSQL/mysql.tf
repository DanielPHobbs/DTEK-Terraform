#https://www.terraform.io/docs/providers/azurerm/r/mysql_database.html
#https://azure.microsoft.com/en-gb/pricing/details/mysql/

provider "azurerm" {
subscription_id = var.subscription_id
client_id = var.client_id
client_secret = var.client_secret
tenant_id = var.tenant_id
features {}
version  = ">=2.0.0"
}

###  existing resource group  ###

data "azurerm_resource_group" "rg" {
    name = var.resource_group
    }
    terraform

data "azurerm_key_vault" "existing" {
  name                = "MSDN-KeyVault"
  resource_group_name = "MSDN-KeyVaults"
}

data "azurerm_key_vault_secret" "MySQL-password" {
name = "MySQL-admin-password"
key_vault_id = data.azurerm_key_vault.existing.id
}

data "azurerm_key_vault_secret" "MySQL-User" {
name = "MySQL-admin-account"
key_vault_id = data.azurerm_key_vault.existing.id
}

# Create mysql Instance 
resource "azurerm_mysql_server" "grafanasrv" {
  name                = "grafana-mysqlserver" #LowerOnly
  location            = var.location
  resource_group_name = data.azurerm_resource_group.rg.name
  
  administrator_login          = data.azurerm_key_vault_secret.MySQL-User.value 
  administrator_login_password = data.azurerm_key_vault_secret.MySQL-password.value

  sku_name   = "B_Gen5_2"
  storage_mb = 5120
  version    = "5.7"
  
  backup_retention_days             = 7
  geo_redundant_backup_enabled      = false
  auto_grow_enabled                 = true
  infrastructure_encryption_enabled = true
  public_network_access_enabled     = false
  ssl_enforcement_enabled           = true
  ssl_minimal_tls_version_enforced  = "TLS1_2"
}

resource "azurerm_mysql_database" "GrafanaDB" {
  name                = "grafanadb"
  resource_group_name = data.azurerm_resource_group.rg.name
  server_name         = azurerm_mysql_server.grafanasrv.name
  charset             = "utf8"
  collation           = "utf8_unicode_ci"
}


#use one of these 
resource "azurerm_mysql_firewall_rule" "grafanafw1" {
  name                = "grafanafw-r1"
  resource_group_name = data.azurerm_resource_group.rg.name
  server_name         = azurerm_mysql_server.grafanasrv.name
  #add the grafana subnet startand end addresses
  start_ip_address    = "10.10.30.0"
  end_ip_address      = "10.10.30.128"
}


/*
resource "azurerm_mysql_virtual_network_rule" "example" {
  name                = "grafana-mysql-vnet-rule"
  resource_group_name = "${data.azurerm_resource_group.rg.name}"
  server_name         = "${azurerm_mysql_server.grafanasrv.name}"
  subnet_id           = "${var.NWDeploySubNet.subnet_id}"
}
*/