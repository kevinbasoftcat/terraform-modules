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
        for_each = [for s in var.bastionnsgrules : {
                name                        = s.name
                priority                    = s.priority
                direction                   = s.direction
                access                      = s.access
                protocol                    = s.protocol
                source_port_ranges          = split(",", replace(s.source_port_ranges, "*", "0-65535"))
                destination_port_ranges     = split(",", replace(s.destination_port_ranges, "*", "0-65535"))
                source_address_prefix       = s.source_address_prefix
                destination_address_prefix  = s.destination_address_prefix
        }]
        content {
                name                        = bationnsgrules.value.name
                priority                    = bationnsgrules.value.priority
                direction                   = bationnsgrules.value.direction
                access                      = bationnsgrules.value.access
                protocol                    = bationnsgrules.value.protocol
                source_port_ranges          = bationnsgrules.value.source_port_ranges
                destination_port_ranges     = bationnsgrules.value.destination_port_ranges
                source_address_prefix       = bationnsgrules.value.source_address_prefix
                destination_address_prefix  = bationnsgrules.value.destination_address_prefix
                description                 = bationnsgrules.value.description
        }
    }
}