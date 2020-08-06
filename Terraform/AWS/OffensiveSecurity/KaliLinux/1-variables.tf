variable candidate_key_name {}

variable "AMI"{
  default = "ami-071d0c011e7ab12f5"
}

variable "attacker_ip" {
  default = ["0.0.0.0/0"]
}

variable "victim_ip" {
  default = ["0.0.0.0/0"]
}

variable "subnet_ids" {}
variable "aws_vpc_id" {}
variable "systems_map" {}
variable "network_tiers" {}
variable "private_key" {}