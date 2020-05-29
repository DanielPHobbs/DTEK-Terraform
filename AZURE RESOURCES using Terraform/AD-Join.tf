

#https://github.com/ghostinthewires/terraform-azurerm-ad-join
module "ad-join" {
  source  = "ghostinthewires/ad-join/azurerm"
  version = "1.0.0"
  # insert the 6 required variables here
variable "active_directory_domain" {
    type    = "string"
  }

variable "active_directory_username" {
    type    = "string"
  }

}