variable "region" {}

variable "ami_map"{
    type = map
    default = {
        eu-central-1  = "ami-0e8ecd9d5c3d37a71"
        eu-west-2     = "ami-01de3128ed02d9e1c"
        eu-west-1     = "ami-0d3e6055f3c1699c6"
    }
}

variable "attacker_ip" {
    default = ["0.0.0.0/0"]
}

variable "victim_ip" {
    default = ["0.0.0.0/0"]
}

variable "system_user" {
    default = "Administrator"
}

variable "system_password" {
    default = "tX8Hf7kKXKKmI"
}

variable "subnet_ids" {}
variable "systems_map" {}
variable "aws_vpc_id" {}
variable "network_tiers" {}