variable "resource_group_location" {
  default     = "west europe"
  description = "Location of the resource group."
}

variable "resource_group_name_prefix" {
  default     = "dtek"
  description = "Prefix of the resource group name that's combined with a random ID so name is unique in your Azure subscription."
}