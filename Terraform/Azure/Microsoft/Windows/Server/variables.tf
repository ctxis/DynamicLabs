variable "location" {}
variable "resource_group_name" {}

variable "systems_map" {}

variable "subnet_ids" {}

variable "system_user" {
    default = "Ansible"
}

variable "system_password" {
}

variable "security_group_ids"{}