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