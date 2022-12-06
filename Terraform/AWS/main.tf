terraform {
    required_version = ">= 0.15"
}

provider "aws" {
    region      = var.AWS_REGION
    access_key  = var.AWS_ACCESS_KEY
    secret_key  = var.AWS_SECRET_KEY
}

# ----------------------------------------------------------------------
# Setup default system password 
# ----------------------------------------------------------------------
resource "random_password" "system_password" {
    length              = 16
    special             = true
    override_special    = "!^.?_%@-+"
    upper               = true
    numeric             = true
    min_lower           = 1
    min_numeric         = 1
    min_special         = 1
    min_upper           = 1
}

# ----------------------------------------------------------------------
# Setup SSH keys
# ----------------------------------------------------------------------
module "management" {
    source = "./Core/sshkey-module"
    key_name = "${terraform.workspace}-management"
}

module "candidate" {
    source = "./Core/sshkey-module"
    key_name = "${terraform.workspace}-candidate"
}

resource "aws_key_pair" "candidate" {
    key_name   = "${terraform.workspace}_candidate"
    public_key = fileexists("../../SSH-Keys/${var.public_key_file_candidate}") ? file("../../SSH-Keys/${var.public_key_file_candidate}") : module.candidate.public_key
}

resource "aws_key_pair" "management" {
    key_name   = "${terraform.workspace}_management"
    public_key = fileexists("../../SSH-Keys/${var.public_key_file_management}") ? file("../../SSH-Keys/${var.public_key_file_management}") : module.management.public_key
}

# ----------------------------------------------------------------------
# Create VPC and Subnets
# ----------------------------------------------------------------------
module "network" {
    source                      = "./Core/network/"
    address_space_lab           = var.address_space_lab
    address_space_management    = var.address_space_management
    networks                    = var.networks
    security_rules              = var.security_rules
    candidate_ip                = var.candidate_ip
}

# ----------------------------------------------------------------------
# Transform var.systems into multiple image-specific maps.
# ----------------------------------------------------------------------
module "dynamic_scaler" {
    source  = "./Core/DynamicScaler"
    systems = var.systems
}

# ----------------------------------------------------------------------
# Include modules for all supported images
# ----------------------------------------------------------------------

module "windows_server" {
    source              = "./Microsoft/Windows/Server"
    systems_map         = module.dynamic_scaler.microsoft_windows_server_map
    subnet_ids          = module.network.subnet_ids
    aws_vpc_id          = module.network.lab_vpc_id
    security_group_ids  = module.network.security_group_ids
    system_password     = random_password.system_password.result
}

module "kali" {
    source                  = "./OffensiveSecurity/KaliLinux"
    systems_map             = module.dynamic_scaler.offensivesecurity_kalilinux_map
    key_name                = "${terraform.workspace}_candidate"
    subnet_ids              = module.network.subnet_ids
    aws_vpc_id              = module.network.lab_vpc_id
    security_group_ids      = module.network.security_group_ids
}

module "ubuntu_server" {
    source              = "./Canonical/Ubuntu/Server/"
    systems_map         = module.dynamic_scaler.canonical_ubuntu_server_map
    aws_vpc_id          = module.network.lab_vpc_id
    subnet_ids          = module.network.subnet_ids
    security_group_ids  = module.network.security_group_ids
    key_name            = "${terraform.workspace}_management"
    private_key_path    = fileexists("../../SSH-Keys/${var.private_key_file_management}") ? "../../SSH-Keys/${var.private_key_file_management}" : module.management.private_key_path
}

# ----------------------------------------------------------------------
# Build Ansible Inventory
# ----------------------------------------------------------------------
module "ansible_inventory" {
    source          = "./Core/Ansible"
    features        = module.dynamic_scaler.features
    system_details  = concat( module.windows_server.details, 
                            module.ubuntu_server.details,
                            module.kali.details )
}

# ----------------------------------------------------------------------
# Launch Management Server
# ----------------------------------------------------------------------
module "management_server" {
    source                      = "./Core/Canonical/Ubuntu/Management/"
    aws_vpc_id                  = module.network.lab_vpc_id
    subnet_id_management        = module.network.subnet_id_management
    security_group_management   = module.network.security_group_management
    private_ip                  = var.management_server_private_ip
    key_name                    = "${terraform.workspace}_management"
    private_key                 = fileexists("../../SSH-Keys/${var.private_key_file_management}") ? file("../../SSH-Keys/${var.private_key_file_management}") : module.management.private_key
    private_key_path            = fileexists("../../SSH-Keys/${var.private_key_file_management}") ? "../../SSH-Keys/${var.private_key_file_management}" : module.management.private_key_path
    candidate_key_path          = fileexists("../../SSH-Keys/${var.private_key_file_candidate}") ? "../../SSH-Keys/${var.private_key_file_candidate}" : module.candidate.private_key_path
    ansible_inventory           = module.ansible_inventory.ansible_inventory_yml
    ansible_tags                = var.ansible_tags
    ansible_limit               = var.ansible_limit
    force_ansible_redeploy      = var.force_ansible_redeploy
    assets_path                 = var.assets_path
}