resource "azurerm_virtual_machine_extension" "SQL-localPS" {
    count                = "${var.server_count}"
    name                 = "${local.prefix}${count.index + 1}-localPS"
    location             = "${var.location}"
    resource_group_name  = "${azurerm_resource_group.rg1.name}"
    virtual_machine_name = "${local.prefix}${count.index + 1}"
    depends_on           = ["azurerm_virtual_machine_extension.sql-am"]
    publisher            = "Microsoft.Compute"
    type                 = "CustomScriptExtension"
    type_handler_version = "1.9"
    settings             = <<SETTINGS
      {
          "fileUris": ["https://${var.storage_name}.blob.core.windows.net/scripts/sql-install.ps1"],
          "commandToExecute": "powershell -ExecutionPolicy Unrestricted -file sql-install.ps1"      
      }
  SETTINGS
  }