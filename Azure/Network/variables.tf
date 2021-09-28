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
    description = "Please enter a valid network CIDR block to use for the vNet."
    default = "10.0.0.0/16"
}

variable "subnet_prefixes" {
  description = "The address prefix to use for the subnet."
  type        = list(string)
  default     = ["10.0.1.0/24"]
}
variable "subnet_names" {
  description = "A list of public subnets inside the vNet."
  type        = list(string)
  default     = ["subnet1", "subnet2", "subnet3"]
}