

provider "azurerm" {
subscription_id = var.subscription_id
client_id = var.client_id
client_secret = var.client_secret
tenant_id = var.tenant_id
features {}
version  = ">=2.0.0"
}

###### Create Resource Group #######
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group
  location = var.location
}

################ Access Secrets in MSDN Keyvault #######  Currently erroring *************

data "azurerm_key_vault" "existing" {
  name                = "MSDN-KeyVault"
  resource_group_name = "MSDN-KeyVaults"
}

data "azurerm_key_vault_secret" "dtek-VM-password" {
name = "DTEK-SRV-ADMIN-PASSWORD"
key_vault_id = data.azurerm_key_vault.existing.id
}

data "azurerm_key_vault_secret" "dtek-VM-User" {
name = "DTEK-ADMIN-USER"
key_vault_id = data.azurerm_key_vault.existing.id
}



################## Get VNET and SUBNET #########################

#refer to a subnet - 
data "azurerm_subnet" "subnet" {
  name                 = "DTEK-FRONTEND-SN1"
  virtual_network_name = "DTEK-PRODUCTION-Vnet1"
  resource_group_name  = "DTEKSVRAccessRG1"
}


######################## Create network interface ##############

resource "azurerm_network_interface" "grafvmnic" {
  count                     = var.grafvmcount
  name                      = "${var.prefix}-grafvmnic${count.index}"
  location                  = var.location
  resource_group_name       = azurerm_resource_group.rg.name
  #-network_security_group_id = azurerm_network_security_group.tfwebnsg.id

  ip_configuration {
    name      = "${var.prefix}-grafvmnic-config${count.index}"
    subnet_id = data.azurerm_subnet.subnet.id

    private_ip_address_allocation = "dynamic"
    #private_ip_address_allocation = "Static"
    #private_ip_address            = format("10.0.1.%d", count.index + 4)
  }

  tags = {
    environment = var.tag
  }
}
###################### Nic LB associations #############################

resource "azurerm_network_interface_backend_address_pool_association" "grafbpoolassc" {
  count                   = var.grafvmcount
  network_interface_id    = element(azurerm_network_interface.grafvmnic.*.id, count.index)
  ip_configuration_name   = "${var.prefix}-grafvmnic-config${count.index}"
  backend_address_pool_id = azurerm_lb_backend_address_pool.graflbbackendpool.id
}

/*   ### NAT rule Reference Only ####
resource "azurerm_lb_nat_rule" "graf_tcp" {
  resource_group_name            = azurerm_resource_group.rg.name
  loadbalancer_id                = azurerm_lb.graflb.id
  name                           = "RDP-VM-${count.index}"
  protocol                       = "tcp"
  frontend_port                  = "5000${count.index + 1}"
  backend_port                   = 3389
  frontend_ip_configuration_name = "LoadBalancerFrontEnd"
  count                          = var.grafvmcount
}

resource "azurerm_network_interface_nat_rule_association" "grafnatruleassc" {
  count                 = var.grafvmcount
  network_interface_id  = element(azurerm_network_interface.grafvmnic.*.id, count.index)
  ip_configuration_name = "${var.prefix}-grafvmnic-config${count.index}"
  nat_rule_id           = element(azurerm_lb_nat_rule.graf_tcp.*.id, count.index)
}
*/
############################## ASG config  #############################

resource "azurerm_application_security_group" "asg-grafana" {
  name                = "grafana"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_network_interface_application_security_group_association" "grafsecassc" {
  count                         = var.grafvmcount
  network_interface_id          = element(azurerm_network_interface.grafvmnic.*.id, count.index)
  #-ip_configuration_name         = "${var.prefix}-webnic-config${count.index}"
  application_security_group_id = azurerm_application_security_group.asg-grafana.id
}

############################## AS config  #############################

resource "azurerm_availability_set" "grafavset" {
  name                        = "${var.prefix}-grafavset"
  location                    = var.location
  resource_group_name         = azurerm_resource_group.rg.name
  managed                     = "true"
  platform_fault_domain_count = 2 # default 3 not working in some regions like Korea

  tags = {
    environment = var.tag
  }
}

############################ Create virtual machine ####################################

resource "azurerm_virtual_machine" "grafvm" {
  count                 = var.grafvmcount
  name                  = "${var.prefix}vm0${count.index}"
  location              = var.location
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.grafvmnic[count.index].id]
  vm_size               = var.vmsize
  availability_set_id   = azurerm_availability_set.grafavset.id

  storage_os_disk {
    name              = format("%s-VM-%03d-OSdisk", var.prefix, count.index + 1)
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"
  }

  ############ data disk section ###################
  storage_data_disk {
    name                = format("%s-VM-%03d-DATADisk", var.prefix, count.index + 1)
    disk_size_gb        = "10"
    managed_disk_type   = "Standard_LRS"
    create_option       = "Empty"
    lun                 = 0
  }

  storage_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }  

  os_profile {
    computer_name  = format("grafvm%03d", count.index + 1)

    ######  Keyvault variables #############
    admin_username = data.azurerm_key_vault_secret.dtek-VM-User.value
    admin_password = data.azurerm_key_vault_secret.dtek-VM-password.value
  }

  tags = {
    environment = var.tag
  }
}

#################### ADD VM extension [Convert to Azure Monitor] ##########

### To Do ####

###################Load Balancer resource Setup #####################

resource "azurerm_public_ip" "graflbpip" {
  name                = "${var.prefix}-graflbpip"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_lb" "graflb" {
  name                = "${var.prefix}graflb"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.graflbpip.id
  }
}

resource "azurerm_lb_backend_address_pool" "graflbbackendpool" {
  resource_group_name = azurerm_resource_group.rg.name
  loadbalancer_id     = azurerm_lb.graflb.id
  name                = "BackEndAddressPool"
}

resource "azurerm_lb_rule" "graf01_lb_rule" {
  resource_group_name            = azurerm_resource_group.rg.name
  loadbalancer_id                = azurerm_lb.graflb.id
  name                           = "GrafLBRule"
  protocol                       = "tcp"
  frontend_port                  = 443
  backend_port                   = 3000
  frontend_ip_configuration_name = "PublicIPAddress"
  enable_floating_ip             = false
  backend_address_pool_id        = azurerm_lb_backend_address_pool.graflbbackendpool.id
  idle_timeout_in_minutes        = 5
  probe_id                       = azurerm_lb_probe.graflb_probe.id
  depends_on                     = [azurerm_lb_probe.graflb_probe]
}

resource "azurerm_lb_probe" "graflb_probe" {
  resource_group_name = azurerm_resource_group.rg.name
  loadbalancer_id     = azurerm_lb.graflb.id
  name                = "tcpProbe"
  protocol            = "tcp"
  port                = 3000
  interval_in_seconds = 5
  number_of_probes    = 2
}




############## Output ###########################
output "graflb_pip" {
  value = azurerm_public_ip.graflbpip.*.ip_address
}



