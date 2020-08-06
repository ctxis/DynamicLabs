provider "aws" { 
    access_key = var.AWS_ACCESS_KEY
    secret_key = var.AWS_SECRET_KEY
    region = var.AWS_REGION
}

terraform {
    required_version = ">= 0.12"
}

# ----------------------------------------------------------------------
# Setup SSH keys in AWS
# NB: Keys must currently be generated outside of terraform
#     and public key value inputted into tfvars
# ----------------------------------------------------------------------
resource "aws_key_pair" "candidate" {
    key_name   = "${terraform.workspace}_candidate"
    public_key = file("SSH-Keys/${var.public_key_file_candidate}")
}

resource "aws_key_pair" "management" {
    key_name   = "${terraform.workspace}_management"
    public_key = file("SSH-Keys/${var.public_key_file_management}")
}

# ----------------------------------------------------------------------
# Configure VPC and Subnets
# ----------------------------------------------------------------------
module "network" {
    source                    = "./Core/network/"
    availability_zone         = var.availability_zone
    address_space_vpc         = var.address_space_vpc
    address_space_management  = var.address_space_management
    networks                  = var.networks
}

# ----------------------------------------------------------------------
# Configure Management Server
# ----------------------------------------------------------------------
module "management_server" {
    source           = "./Core/Canonical/Ubuntu/18.04_Management/"
    aws_vpc_id       = module.network.lab_vpc_id
    network_id       = var.managment_server_network_id
    aws_subnet_ids   = module.network.subnet_ids
    private_ip       = var.management_server_private_ip
    aws_key_name     = "${terraform.workspace}_management"
    attacker_ip      = var.attacker_ip
    private_key      = "${file("SSH-Keys/${var.private_key_file_management}")}"
}

# ----------------------------------------------------------------------
# Split systems variable into individual maps for scaling systems
# ----------------------------------------------------------------------
module "dynamic_scaler" {
    source  = "./Core/DynamicScaler"
    systems = var.systems
}