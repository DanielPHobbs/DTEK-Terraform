provider "azurerm" {
  version = "1.38.0"
}

#create resource group
resource "azurerm_resource_group" "rg" {
    name     = "TerraformTest-Rg1"
    location = "WestEurope"
    tags      = {
      Environment = "Terraform Demo"
    }
}

#Create virtual network
resource "azurerm_virtual_network" "vnet" {
    name                = "vnet-test-NE-001"
    address_space       = ["10.0.0.0/18"]
    location            = "northeurope"
    resource_group_name = azurerm_resource_group.rg.name
}

# Create subnet
resource "azurerm_subnet" "subnet" {
  name                 = "snet-test-NE-001 "
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefix       = "10.1.0.0/24"
}

# Create public IP
resource "azurerm_public_ip" "publicip" {
  name                = "pip-vmterraform-test-NE-001"
  location            = "northeurope"
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
}

################## change to RDP #######################
# Create network security group and rule
resource "azurerm_network_security_group" "nsg" {
  name                = "nsg-VMstandard-001 "
  location            = "northeurope"
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {  //Here opened https port
    name                       = "HTTPS"  
    priority                   = 1000  
    direction                  = "Inbound"  
    access                     = "Allow"  
    protocol                   = "Tcp"  
    source_port_range          = "*"  
    destination_port_range     = "443"  
    source_address_prefix      = "*"  
    destination_address_prefix = "*"  
  }  
  security_rule {   //Here opened WinRMport
    name                       = "winrm"  
    priority                   = 1010  
    direction                  = "Inbound"  
    access                     = "Allow"  
    protocol                   = "Tcp"  
    source_port_range          = "*"  
    destination_port_range     = "5985"  
    source_address_prefix      = "*"  
    destination_address_prefix = "*"  
  }  
  security_rule {   //Here opened https port for outbound
    name                       = "winrm-out"  
    priority                   = 100  
    direction                  = "Outbound"  
    access                     = "Allow"  
    protocol                   = "*"  
    source_port_range          = "*"  
    destination_port_range     = "5985"  
    source_address_prefix      = "*"  
    destination_address_prefix = "*"  
  }  
  security_rule {   //Here opened remote desktop port
    name                       = "RDP"  
    priority                   = 110  
    direction                  = "Inbound"  
    access                     = "Allow"  
    protocol                   = "Tcp"  
    source_port_range          = "*"  
    destination_port_range     = "3389"  
    source_address_prefix      = "*"  
    destination_address_prefix = "*"  
  }  
}

# Create network interface
resource "azurerm_network_interface" "nic" {
  name                      = "nic-01-vmterraform-test-001 "
  location                  = "northeurope"
  resource_group_name       = azurerm_resource_group.rg.name
  network_security_group_id = azurerm_network_security_group.nsg.id

  ip_configuration {
    name                          = "niccfg-vmterraform"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "dynamic"
    public_ip_address_id          = azurerm_public_ip.publicip.id
  }
}

resource "azurerm_managed_disk" "datadisk" {  //Here defined data disk structure
  name                 = "WinvmTF-datadisk"  
  location             = "northeurope" 
  resource_group_name  = azurerm_resource_group.rg.name 
  storage_account_type = "Standard_LRS"  
  create_option        = "Empty"  
  disk_size_gb         = "5"  
}  

# Create virtual machine
resource "azurerm_virtual_machine" "vm" {
  name                  = "WinvmTF"
  location              = " northeurope "
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.nic.id]
  vm_size               = "Standard_B1ms"

  storage_os_disk {
    name              = "WinvmTF -ServerOs"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }



storage_data_disk {  //Here defined actual data disk by referring to above structure
    name            = azurerm_managed_disk.datadisk.name  
    managed_disk_id = azurerm_managed_disk.datadisk.id  
    create_option   = "Attach"  
    lun             = 1  
    disk_size_gb    = azurerm_managed_disk.datadisk.disk_size_gb  
  }  
  

  storage_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }  


  os_profile {
    computer_name  = "Winvmterraform"
    admin_username = "terrauser"
    admin_password = "Password1234!"
  }


tags = {
    environment = "TerraformTest"
  }
}
