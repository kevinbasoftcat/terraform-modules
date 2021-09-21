variable "rgname" {
    type = string
    description = "Resource group name to deploy the Update Management resources into" 
}
variable "vnetaddressprefix" {
    type = string
    description = "Please enter a valid network CIDR block to use for the vNet. This must be a CIDR notation of /24 or larger"
}
variable "bastionhostsubnet" {
    type = string
    description = "Please enter a valid network CIDR block to use for the Bastion subnet"
}
variable "monitoringsubnet" {
    type = string
    description = "Please enter a valid network CIDR block to use for the Monitoring subnet"
}
