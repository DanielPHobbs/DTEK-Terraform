variable "subscription_id" {}
variable "client_id" {}
variable "client_secret" {}
variable "tenant_id" {}

variable "location" {}


variable "prefix" {}

######## Network #############

variable "NWDeploySubNet" {}
variable "NWDeployVNET" {}
variable "NWDeployRG" {}

###### GRAFANA Specific ######

variable "Grafana_RG_name"  {}

######### VM specific #########
variable "SrvName1" {}
variable "SrvName2" {}

variable "vm_username" {}
variable "vm_password" {}