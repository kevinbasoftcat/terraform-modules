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