provider "azurerm" {
  features { 
  }
}

resource "random_string" "randomstring" {
  length = 5
  special = false
  lower = true
  number = true
}

resource "azurerm_resource_group" "vNet" {
  name = var.rgname
  location = "UK South"
}

resource "azurerm_virtual_network" "vNet" {
  name = "${var.resourceprefix}-vNet-${random_string.randomstring.result}"
  location = azurerm_resource_group.vNet.location
  resource_group_name = azurerm_resource_group.vNet.name
  address_space = ["${var.vnetaddressprefix}"]
}

resource "azurerm_subnet" "vNetBastionSubnet" {
  name = "AzureBastionSubnet"
  resource_group_name = azurerm_resource_group.vNet.name
  virtual_network_name = azurerm_virtual_network.vNet.name
  address_prefixes = ["${var.bastionhostsubnet}"]
}

resource "azurerm_subnet" "vNetMonitoringSubnet" {
    name = "AzureMonitoringSubnet"
    resource_group_name = azurerm_resource_group.vNet.name
    virtual_network_name = azurerm_virtual_network.vNet.name
    address_prefixes = ["${var.monitoringsubnet}"]
}

resource "azurerm_network_security_group" "bastionNSG" {
    name = "${var.resourceprefix}-BastionNSG-${random_string.randomstring.result}"
    location = azurerm_resource_group.vNet.location
    resource_group_name = azurerm_resource_group.vNet.name

    dynamic "bastionnsgrules" {
        for_each = var.bastionnsgrules
        content {
                    name                        = bastionnsgrules.value["name"]
                    priority                    = bastionnsgrules.value["priority"]
                    direction                   = bastionnsgrules.value["direction"]
                    access                      = bastionnsgrules.value["access"]
                    protocol                    = bastionnsgrules.value["protocol"]
                    source_port_range           = bastionnsgrules.value["source_port_range "]
                    destination_port_range      = bastionnsgrules.value["destination_port_range"]
                    source_address_prefix       = bastionnsgrules.value["source_address_prefix"]
                    destination_address_prefix  = bastionnsgrules.value["destination_address_prefix"]
        }
    }
}