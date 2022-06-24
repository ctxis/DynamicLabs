variable "address_space_vpc" {}
variable "address_space_management" {}
variable "networks" {
    type = list(object({network_id=string, network_name=string,address_space=string}))
    default = [{
        network_id    = "MAN"
        network_name  = "Management"
        address_space = "10.1.254.0/24"
    }]
}

variable "security_rules" {
    type = list(object({
        network_id          = string,
        type                = string,
        cidr_blocks         = list(string),
        protocol            = string,
        from_port           = string,
        to_port             = string
    }))
}

variable "candidate_ip" {}
variable "candidate_network" {}