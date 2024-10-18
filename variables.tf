variable "prefix" {
  type = string
}

variable "location" {
  type = string
}

variable "base_cidr_space" {
  type    = string
  default = "10.0.0.0/16"
}

variable "admin_username" {
  description = "admin username"
  type        = string
  default     = "azureuser"
}

variable "admin_password" {
  description = "admin password"
  type        = string
}