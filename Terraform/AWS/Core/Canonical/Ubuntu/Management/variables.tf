variable aws_vpc_id {}
variable subnet_id_management {}
variable security_group_management {}
variable key_name {}
variable private_key {}
variable private_key_path {}
variable candidate_key_path {}
variable private_ip {
    default = "10.1.254.10"
}
variable public_ip {
    default = false
}
variable "ssh_mgmt_port" {
    default = 22
}
variable "nginx_port" {
    default = 10080
}
variable "ansible_inventory" {}

variable "force_ansible_redeploy" {
    description = "Force redeploying Ansible code to management server at every run. Useful during development."
    default = false
}

variable "ansible_tags" {
    description = "Ansible tags to execute. Useful during development to select a subset such as AD_User"
    default = "all"
}

variable "ansible_limit" {
    description = "Limit execution of ansible to specified hosts. Useful during development to apply changes to a specific host only"
    default = "all"
}

variable "assets_path" {
    description = "The location on the local filesystem of assets to copy to the management server"
    type = string
    default = null
}