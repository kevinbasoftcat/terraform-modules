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
  location = var.location
}
resource "azurerm_virtual_network" "vNet" {
  name                                            = "${var.resourceprefix}-vNet-${random_string.randomstring.result}"
  location                                        = azurerm_resource_group.vNet.location
  resource_group_name                             = azurerm_resource_group.vNet.name
  address_space                                   = ["${var.vnetaddressprefix}"]
  dns_servers                                     = var.dns_servers

}
resource "azurerm_subnet" "subnet" {
  count = length(var.subnet_names)
  name                                           = var.subnet_names[count.index]
  resource_group_name                            = azurerm_resource_group.vNet.name
  virtual_network_name                           = azurerm_virtual_network.vNet.name
  address_prefixes                               = [var.subnet_prefixes[count.index]]
  service_endpoints                              = lookup(var.subnet_service_endpoints, var.subnet_names[count.index], null)
  enforce_private_link_endpoint_network_policies = lookup(var.subnet_enforce_private_link_endpoint_network_policies, var.subnet_names[count.index], false)
  enforce_private_link_service_network_policies  = lookup(var.subnet_enforce_private_link_service_network_policies, var.subnet_names[count.index], false)
}