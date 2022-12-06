variable "location" {}

variable "resource_group_name" {}

variable "systems_map" {}

variable "subnet_ids" {}

variable "public_key" {}

variable "private_key_path" {}

variable "system_user" {
    default = "ubuntu"
}

variable "system_password" {
    default = "Kdh^3h&19dmk"
}

variable "security_group_ids"{}