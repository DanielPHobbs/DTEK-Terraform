# azure service principal info for TEST
/*
variable "subscription_id" {
  default = "e06039fe-83f5-44e4-9b42-fde133a6c1d6"
}

# client_id or app_id
variable "client_id" {
  default = "44c28321-5678-4d5a-974a-f675a95565d6"
}

variable "client_secret" {
  default = "2fc66261-daa4-4834-bba0-babdd5444087"
}
*/
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

variable "SubNetName" {
  default = "DTEK-FRONTEND-SN1"
}
  
  variable "VNetRG" {
  default = "DTEKSVRAccessRG1"
}

variable "VNetName" {
  default = "DTEK-PRODUCTION-Vnet1"
}

# service variables
variable "prefix" {
  default = "GrafHA"
}

variable "location" {
  default = "WestEurope"
}

variable "vmsize" {
  default = "Standard_B1ms"
}

variable "grafvmcount" {
  default = 2
}

variable "tag" {
  default = "GrafHA"
}
