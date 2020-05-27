module "mysql" {
  source = "foreverXZC/mysql/azurerm"
  db_name = "mydatabase"
  location = "westeurope"
  admin_username = "azureuser"
  password = "P@ssw0rd12345!"
}