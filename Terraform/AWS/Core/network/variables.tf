variable "AWS_REGION" {}
variable "AWS_AVAILABILITY_ZONE_ABC" {}
variable "address_space_lab" {}
variable "address_space_management" {}
variable "networks" {
    type = list(object({network_id=string, network_name=string,network_template=string,address_space=string}))
    default = [{
        network_id    = "1"
        network_name  = "Candidate"
        address_space = "10.1.1.0/24"
        network_template = "candidate"
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