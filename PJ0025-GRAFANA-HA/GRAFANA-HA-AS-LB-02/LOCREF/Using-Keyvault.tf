data "azurerm_key_vault_secret" "dtek-VM-password" {
name = "DTEK-SRV-ADMIN-PASSWORD"
vault_uri = "https://msdn-keyvault.vault.azure.net/"
}

data "azurerm_key_vault_secret" "dtek-VM-User" {
name = "DTEK-ADMIN-USER"
vault_uri = "https://msdn-keyvault.vault.azure.net/"
}


output "vm-user" {
  value = data.azurerm_key_vault_secret.dtek-VM-User.value
output "vm-password" {
  value = data.azurerm_key_vault_secret.dtek-VM-password.value


/*

os_profile {
computer_name = "myvm"
admin_username = data.azurerm_key_vault_secret.dtek-VM-User.value
admin_password = data.azurerm_key_vault_secret.dtek-VM-password.value
}





###############################################################################

data "azurerm_key_vault_secret" "example" {
  name         = "secret-sauce"
  key_vault_id = data.azurerm_key_vault.existing.id
}

output "secret_value" {
  value = data.azurerm_key_vault_secret.example.value
}

*/