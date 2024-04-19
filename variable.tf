#export TF_VAR_cidr="value"

variable "resource_group_name" {
  type        = string
  description = "resource group name"
  default     = "my-rg"
}

variable "azurerm_resource_group_location" {
  type    = string
  default = "Central India"

}

variable "admin_password" {
  default = "P@$$w0rd1234!"

}

variable "admin_username" {
  default = "adminuser"

}

variable "number_of_vm" {
  type = number

}