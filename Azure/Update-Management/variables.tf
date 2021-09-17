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