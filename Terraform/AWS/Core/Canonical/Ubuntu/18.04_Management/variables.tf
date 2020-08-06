variable aws_vpc_id {}
variable aws_subnet_ids {}
variable network_id {}
variable aws_key_name {}
variable private_key {}
variable private_ip {
    default = "10.1.254.10"
}
variable "ssh_mgmt_port" {
  default = 22
}
variable "nginx_port" {
  default = 10080
}
variable "attacker_ip" {
  default = ["0.0.0.0/0"]
}
