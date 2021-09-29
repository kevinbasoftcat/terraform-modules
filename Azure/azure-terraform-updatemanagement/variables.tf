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
variable "emailreceivername" {
  type = string
  description = "Name for the email receiver for the update managament alerts"
  
}
variable "emailreceiveremail" {
  type = string
  description = "Email address to use for the update management alerts"
  
}