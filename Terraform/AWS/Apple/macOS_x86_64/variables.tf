variable "system_user" {
    default = "ec2-user"
}

variable "key_name" {}
variable "private_key_path" {}
variable "subnet_ids" {}
variable "systems_map" {}
variable "aws_vpc_id" {}
variable "security_group_ids" {}
variable "windows_system_user" {
    default = "Administrator"
}
variable "windows_system_password" {}
