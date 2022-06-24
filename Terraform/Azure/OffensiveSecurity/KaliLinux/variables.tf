variable "location" {}
variable "resource_group_name" {}
variable system_user {
    default = "kali"
}
variable system_password {
    default = "toor"
}
variable "public_key" {}
variable "private_key" {}
variable "subnet_ids" {}
variable "systems_map" {}
variable "security_group_ids" {
}