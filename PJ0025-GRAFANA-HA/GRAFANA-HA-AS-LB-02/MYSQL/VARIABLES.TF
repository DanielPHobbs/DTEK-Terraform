###### MSDN ########
variable "subscription_id" {
  default = "e8930b88-433c-4dce-a2a7-18d1929510fe"
}


# client_id or app_id
variable "client_id" {
  default = "44c28321-5678-4d5a-974a-f675a95565d6"
}
variable "client_secret" {
  default = "m.Dy25sT1A0x--DS_7Yk5-6VVL028WC9M_"
}
# tenant_id or directory_id
variable "tenant_id" {
  default = "92832cfc-349a-4b12-af77-765b6f10b51f"
}

variable "resource_group" {
  description = "The name of the resource group in which to create the Resources."
  default = "dtek-grafana-rg02"
}

variable "location" {
  default = "WestEurope"
}