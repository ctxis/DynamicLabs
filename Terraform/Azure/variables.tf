variable location {
    type    = string
    default = "uksouth"
}

variable address_space_lab {
    type    = string
    default = "10.1.0.0/16"
}

variable address_space_management {
    type    = string
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
    default = "management_key.pub"
}

variable "candidate_ip" {
    default = ["0.0.0.0/0"]
}

variable "managment_server_network_id" {
    default = "MAN"
}

variable "management_server_private_ip" {
    default = "10.1.254.10"
}

variable "systems" {
    type = list(object({
        module=string,
	os_version=string,
        size=string,
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
        module                      = "microsoft_windows_server"
	os_version                  = "2019"
        size                        = "Standard_B1s"
        network_id                  = "001"
        hostname                    = null
        private_ip                  = null
        public_ip                   = false
        class                       = "GS"
        id                          = "001"
        features                    = []
    }]
}

variable "networks" {
    type = list(object({network_id=string, network_name=string,network_template=string,address_space=string}))
    default = [{
        network_id    = "1"
        network_name  = "Candidate"
        address_space = "10.1.1.0/24"
        network_template = "candidate"
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

variable "security_rules" {
    type = list(object({
        network_id                      = string,
        name                            = string,
        priority                        = string,
        direction                       = string,
        access                          = string,
        protocol                        = string,
        source_port_ranges              = list(string),
        destination_port_ranges         = list(string),
        source_address_prefixes         = list(string),
        destination_address_prefixes    = list(string),
    }))
}
