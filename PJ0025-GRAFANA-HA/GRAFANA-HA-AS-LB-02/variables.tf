# azure service principal info
variable "subscription_id" {
  default = "add_here"
}

# client_id or app_id
variable "client_id" {
  default = "add_here"
}

variable "client_secret" {
  default = "add_here"
}

# tenant_id or directory_id
variable "tenant_id" {
  default = "add_here"
}


variable "resource_group" {
  description = "The name of the resource group in which to create the Resources."
  default = "dtek-grafana-rg02"
}

# admin password
variable "admin_username" {
  default = "azureuser"
}

variable "admin_keydata" {
  default = "add_here"
}

variable "admin_password" {
  default = "add_here"
}

# service variables
variable "prefix" {
  default = "DtekTFdemo"
}

variable "location" {
  default = "NorthEurope"
}

variable "vmsize" {
  default = "Standard_DS1_v2"
}

variable "webcount" {
  default = 1
}

variable "appcount" {
  default = 1
}

variable "tag" {
  default = "demo"
}
