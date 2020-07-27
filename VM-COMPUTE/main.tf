
provider "azurestack" {
  arm_endpoint    = "${var.arm_endpoint}"
  subscription_id = "${var.subscription_id}"
  client_id       = "${var.client_id}"
  client_secret   = "${var.client_secret}"
  tenant_id       = "${var.tenant_id}"
}

# Create a resource group
resource "azurestack_resource_group" "rg" {
  name     = "${var.rg_name}"
  location = "${var.location}"

  tags = {
    environment = "${var.rg_tag}"
  }
}

resource "azurestack_network_security_group" "nsg" {
  name                = "${azurestack_resource_group.rg.name}-SecurityGroup"
  location            = "${azurestack_resource_group.rg.location}"
  resource_group_name = "${azurestack_resource_group.rg.name}"

  security_rule {
    name                        = "rdp"
    priority                    = "100"
    direction                   = "Inbound"
    access                      = "Allow"
    protocol                    = "tcp"
    source_port_range           = "*"
    destination_port_range      = "3389"
    source_address_prefix       = "*"
    destination_address_prefix  = "*"
  }

  tags = "${azurestack_resource_group.rg.tags}"
}

resource "azurestack_virtual_network" "virtual-network" {
  name                = "${azurestack_resource_group.rg.name}-VirtualNetwork"
  address_space       = ["10.0.0.0/16"]
  location            = "${azurestack_resource_group.rg.location}"
  resource_group_name = "${azurestack_resource_group.rg.name}"
}

resource "azurestack_subnet" "subnet1" {
  name                            = "${azurestack_resource_group.rg.name}-Subnet1"
  resource_group_name             = "${azurestack_resource_group.rg.name}"
  virtual_network_name            = "${azurestack_virtual_network.virtual-network.name}"
  address_prefix                  = "10.0.2.0/24"
  network_security_group_id       = "${azurestack_network_security_group.nsg.id}"
}

resource "azurestack_public_ip" "public-ip" {
  count                         = "${var.vm_count}"
  name                          = "public-ip-${count.index + 1}"
  location                      = "${azurestack_resource_group.rg.location}"
  resource_group_name           = "${azurestack_resource_group.rg.name}"
  public_ip_address_allocation  = "static"
}

resource "azurestack_network_interface" "nic" {
  name                                  = "${azurestack_resource_group.rg.name}-NIC${count.index + 1}"
  count                                 = "${var.vm_count}"
  location                              = "${azurestack_resource_group.rg.location}"
  resource_group_name                   = "${azurestack_resource_group.rg.name}"

  ip_configuration {
    name                            = "nic-ip-config1"
    subnet_id                       = "${azurestack_subnet.subnet1.id}"
    private_ip_address_allocation   = "dynamic"
    public_ip_address_id            = "${element(azurestack_public_ip.public-ip.*.id, count.index)}"
  }

  tags = "${azurestack_resource_group.rg.tags}"
}

resource "azurestack_virtual_machine" "vm" {
  count                 = "${var.vm_count}"
  name                  = "vm-${count.index + 1}"
  location              = "${azurestack_resource_group.rg.location}"
  resource_group_name   = "${azurestack_resource_group.rg.name}"
  network_interface_ids = ["${element(azurestack_network_interface.nic.*.id, count.index)}"]
  vm_size               = "${var.vm_size}"

  # Uncomment this line to delete the OS disk automatically when deleting the VM
  # delete_os_disk_on_termination = true

  # Uncomment this line to delete the data disks automatically when deleting the VM
  # delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "${element(split("/", var.vm_image_string), 0)}"
    offer     = "${element(split("/", var.vm_image_string), 1)}"
    sku       = "${element(split("/", var.vm_image_string), 2)}"
    version   = "${element(split("/", var.vm_image_string), 3)}"
  }

  storage_os_disk {
    name                = "vm-${count.index + 1}-OS-Disk"
    caching             = "ReadWrite"
    managed_disk_type   = "Standard_LRS"
    create_option       = "FromImage"
  }

  # Optional data disks
  storage_data_disk {
    name                = "vm-${count.index + 1}-Data-Disk"
    disk_size_gb        = "100"
    managed_disk_type   = "Standard_LRS"
    create_option       = "Empty"
    lun                 = 0
  }

  os_profile {
    computer_name  = "host${count.index + 1}"
    admin_username = "${var.admin_username}"
    admin_password = "${var.admin_password}"
  }

  os_profile_windows_config {
  }

  tags = "${azurestack_resource_group.rg.tags}"
}