data "azurerm_key_vault_secret" "dtek-VM-password" {
name = "DTEK-SRV-ADMIN-PASSWORD"
vault_uri = "https://msdn-keyvault.vault.azure.net/"
}

data "azurerm_key_vault_secret" "dtek-VM-User" {
name = "DTEK-ADMIN-USER"
vault_uri = "https://msdn-keyvault.vault.azure.net/"
}


os_profile {
computer_name = "myvm"
admin_username = "${data.azurerm_key_vault_secret.dtek-VM-User.value}"
admin_password = "${data.azurerm_key_vault_secret.dtek-VM-password.value}"
}
