variable "subscription_id" {}
variable "client_id" {}
variable "client_secret" {}
variable "tenant_id" {}

variable "prefix" {default = "DtekAZ-TEST"}

#Add variables for Subnet & ResourceGroup

provider "azurerm" {
  tenant_id       = "${var.tenant_id}"
  subscription_id = "${var.subscription_id}"
  client_id       = "${var.client_id}"
  client_secret   = "${var.client_secret}"
}

#########################################################
# refer to a resource group
data "azurerm_resource_group" "test" {
  name = "nancyResourceGroup"
}

#refer to a subnet - 
data "azurerm_subnet" "test" {
  name                 = "mySubnet"
  virtual_network_name = "myVnet"
  resource_group_name  = "nancyResourceGroup"
}

#########################################################

resource "azurerm_network_interface" "test" {
  name                = "nic-test"
  location            = "${data.azurerm_resource_group.test.location}"
  resource_group_name = "${data.azurerm_resource_group.test.name}"

  ip_configuration {
    name                          = "testconfiguration1"
    subnet_id                     = "${data.azurerm_subnet.test.id}"
    private_ip_address_allocation = "dynamic"
    public_ip_address_id          = "${azurerm_public_ip.test.id}"
  }
}

resource "azurerm_virtual_machine" "web_server" {
  name                  = "${var.prefix}-SRV001"
  location              = "${data.azurerm_resource_group.test.location}"
  resource_group_name   = "${data.azurerm_resource_group.test.name}"
  network_interface_ids = ["${azurerm_network_interface.test.id}"]
  vm_size               = "Standard_B2s"

  storage_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }

  storage_os_disk {
    name              = "server-os"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  # Uncomment this line to delete the OS disk automatically when deleting the VM
  delete_os_disk_on_termination = true

  # Uncomment this line to delete the data disks automatically when deleting the VM
  delete_data_disks_on_termination = true

  os_profile {
    computer_name      = "${var.prefix}-SRV001"
    admin_username     = "${var.prefix}VMadmin"
    admin_password     = "Passw0rd1234"

  }

  os_profile_windows_config {
  }

tags = {
    environment = "staging"
  }

}