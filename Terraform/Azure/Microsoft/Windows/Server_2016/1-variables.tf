variable "location" {}
variable "resource_group_name" {}

variable "systems_map" {}
variable "network_tiers" {}

variable "subnet_ids" {}
variable "attacker_ip" {}

variable "system_user" {
    default = "Ansible"
}

variable "system_password" {
    default = "tX8Hf7kKXKKmI"
}