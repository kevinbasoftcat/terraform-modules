variable "location" {
  type = string
  description = "Locaton to use for the deployment of resources"
}
variable "rgname" {
    type = string
    description = "Resource group name to deploy the Update Management resources into" 
}
variable "resourceprefix" {
    type = string
    description = "Prefix to use when naming each of the resources please ensure this is only 3 characters long"
    validation {
      condition = length (var.resourceprefix) == 3
      error_message = "The resource prefix must be only 3 characters long."
    }
}
variable "bastionsubnetid" {
    type = string
    description = "Please provide the subnet id for the Bastion to be deployed to"
}

variable "bastionnsgrules" {
    description = "NSG rules used for Azure Bastion Host"
    type = list(map(string))
    default = [
    {
        name                        = "AllowHttpsInBound"
        priority                    = "100"
        direction                   = "Inbound"
        access                      = "Allow"
        protocol                    = "Tcp"
        source_port_ranges           = "*"
        destination_port_ranges      = "443"
        source_address_prefix       = "Internet"
        destination_address_prefix  = "*"
    },
    {
        name                        = "AllowGatewayManagerInBound"
        priority                    = "110"
        direction                   = "Inbound"
        access                      = "Allow"
        protocol                    = "Tcp"
        source_port_ranges          = "*"
        destination_port_ranges     = "443,4443"
        source_address_prefix       = "GatewayManager"
        destination_address_prefix  = "*"
    },
    {
        name                        = "AllowLoadBalancerInBound"
        priority                    = "120"
        direction                   = "Inbound"
        access                      = "Allow"
        protocol                    = "Tcp"
        source_port_ranges          = "*"
        destination_port_ranges     = "443"
        source_address_prefix       = "AzureLoadBalancer"
        destination_address_prefix  = "*"
    },
    {
        name                        = "AllowBastionHostCommunicationInBound"
        priority                    = "130"
        direction                   = "Inbound"
        access                      = "Allow"
        protocol                    = "*"
        source_port_ranges          = "*"
        destination_port_ranges     = "8080,5701"
        source_address_prefix       = "VirtualNetwork"
        destination_address_prefix  = "VirtualNetwork"
    },
    {
        name                        = "DenyAllInBound"
        priority                    = "1000"
        direction                   = "Inbound"
        access                      = "Deny"
        protocol                    = "*"
        source_port_ranges          = "*"
        destination_port_ranges     = "*"
        source_address_prefix       = "*"
        destination_address_prefix  = "*"
    },
    {
        name                        = "AllowSshRdpOutBound"
        priority                    = "100"
        direction                   = "Outbound"
        access                      = "Allow"
        protocol                    = "Tcp"
        source_port_ranges          = "*"
        destination_port_ranges     = "22,3389"
        source_address_prefix       = "*"
        destination_address_prefix  = "VirtualNetwork"
    },
    {
        name                        = "AllowAzureCloudCommunicationOutBound"
        priority                    = "110"
        direction                   = "Outbound"
        access                      = "Allow"
        protocol                    = "Tcp"
        source_port_ranges          = "*"
        destination_port_ranges     = "443"
        source_address_prefix       = "*"
        destination_address_prefix  = "AzureCloud"
    },
    {
        name                        = "AllowBastionHostCommunicationOutBound"
        priority                    = "120"
        direction                   = "Outbound"
        access                      = "Allow"
        protocol                    = "*"
        source_port_ranges          = "*"
        destination_port_ranges     = "8080,5701"
        source_address_prefix       = "VirtualNetwork"
        destination_address_prefix  = "VirtualNetwork"
    },
    {
        name                        = "AllowGetSessionInformationOutBound"
        priority                    = "130"
        direction                   = "Outbound"
        access                      = "Allow"
        protocol                    = "*"
        source_port_ranges          = "*"
        destination_port_ranges     = "80,443"
        source_address_prefix       = "*"
        destination_address_prefix  = "Internet"
    },
    {
        name                        = "DenyAllOutBound"
        priority                    = "1000"
        direction                   = "Outbound"
        access                      = "Deny"
        protocol                    = "*"
        source_port_ranges          = "*"
        destination_port_ranges     = "*"
        source_address_prefix       = "*"
        destination_address_prefix  = "*"
    },
    ]
  
}