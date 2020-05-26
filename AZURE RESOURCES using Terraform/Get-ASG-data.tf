#https://www.terraform.io/docs/providers/azurerm/d/application_security_group.html

data "azurerm_application_security_group" "example" {
  name                = "tf-appsecuritygroup"
  resource_group_name = "my-resource-group"
}

output "application_security_group_id" {
  value = data.azurerm_application_security_group.example.id
}