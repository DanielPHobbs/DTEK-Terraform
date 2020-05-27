

#Add variables for Subnet & ResourceGroup

provider "azurerm" {
  tenant_id       = "${var.tenant_id}"
  subscription_id = "${var.subscription_id}"
  client_id       = "${var.client_id}"
  client_secret   = "${var.client_secret}"
}

#########################################################
# refer to an existing resource group

#data "azurerm_resource_group" "TestENVENV" {name = "RG-GRAFANA1"}

# create a new resource group
resource "azurerm_resource_group" "rg" {
        name = "${var.Grafana_RG_name}"
        location = "${var.location}"
}


#refer to an existing subnet - 
data "azurerm_subnet" "TestENV" {
  name                 = "${var.NWDeploySubNet}"
  virtual_network_name = "${var.NWDeployVNET}"
  resource_group_name  = "${var.NWDeployRG}"
}

#########################################################

resource "azurerm_network_interface" "TestENV" {
  name                = "${var.SrvName1}-nic"
  location            = "${data.azurerm_resource_group.TestENV.location}"
  resource_group_name = "${data.azurerm_resource_group.TestENV.name}"

  ip_configuration {
    name                          = "TestENVconfiguration1"
    subnet_id                     = "${data.azurerm_subnet.TestENV.id}"
    private_ip_address_allocation = "dynamic"
    public_ip_address_id          = "${azurerm_public_ip.TestENV.id}"
  }
}

resource "azurerm_virtual_machine" "web_server" {
  name                  = "${var.SrvName1}"
  location              = "${data.azurerm_resource_group.TestENV.location}"
  resource_group_name   = "${data.azurerm_resource_group.TestENV.name}"
  network_interface_ids = ["${azurerm_network_interface.TestENV.id}"]
  vm_size               = "Standard_B2s"

  storage_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }

  storage_os_disk {
    name              = "${var.SrvName1}-OS"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  # Uncomment this line to delete the OS disk automatically when deleting the VM
  delete_os_disk_on_termination = true

  # Uncomment this line to delete the data disks automatically when deleting the VM
  delete_data_disks_on_termination = true

  os_profile {
    computer_name      = "${var.SrvName1}"
    admin_username     = "${var.vm_username}"
    admin_password     = "${var.vm_password}"

  }

  os_profile_windows_config {
  }

tags = {
    environment = "${var.prefix}"
  }

}