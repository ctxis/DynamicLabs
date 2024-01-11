variable "AWS_ACCESS_KEY" {}
variable "AWS_SECRET_KEY" {}
variable "AWS_REGION" {
    default = "eu-west-1"
}

variable "AWS_AVAILABILITY_ZONE_ABC" {
    # The last letter of the availability zone.
    # e.g. for eu-west-1a that would be "a"
    default = "a"
}

variable address_space_lab {
    default = "10.1.0.0/16"
}

variable address_space_management {
    default = "10.1.254.0/24"
}

variable public_key_file_candidate {
    default = "candidate_key.pub"
}
variable private_key_file_candidate {
    default = "candidate_key.pem"
}
variable public_key_file_management {
    default = "management_key.pub"
}
variable private_key_file_management {
    default = "management_key.pem"
}

variable "candidate_ip" {}

variable "managment_server_network_id" {
    default = "MAN"
}

variable "management_server_private_ip" {
    default = "10.1.254.10"
}

variable "networks" {
    type = list(object({network_id=string, network_name=string,address_space=string,network_template=string}))
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

variable "systems" {
    type = list(object({
        module=string,
        os_version=string,
        size=string,
        dedicated_host_id=optional(string),
        network_id=string,
        hostname=string,
        private_ip=string,
        public_ip=bool,
        class=string,
        id=string,
        features=list(object({
            name=string,
            value=list(map(string))
        }))
    }))
    default = [{
        module      = "microsoft_windows_server"
        os_version  = 2022
        size        = "t2.small"
        network_id  = "1"
        hostname    = null
        private_ip  = null
        public_ip   = false
        class       = "DC"
        id          = "001"
        features  = []
    }]
}

variable "assets_path" {
    type = string
    default = null
}

# Use by adding to your terraform command:
#   -var="force_ansible_redeploy=true"
variable "force_ansible_redeploy" {
    description = "Force redeploying Ansible code to management server at every run. Useful during development."
    default = false
}

# Use by adding to your terraform command:
#   -var="ansible_tags=AD_User" 
variable "ansible_tags" {
    description = "Ansible tags to execute. Useful during development to select a subset such as AD_User"
    default = "all"
}

# Use by adding to your terraform command:
#   -var="ansible_limit=10.1.1.10" 
variable "ansible_limit" {
    description = "Limit execution of ansible to specified hosts. Useful during development to apply changes to a specific host only"
    default = "all"
}