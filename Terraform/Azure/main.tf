terraform {
    required_version = ">= 0.15"
}

# Configure the Azure Provider
# Please authenticate using the "az login" command.
provider "azurerm" {
  features {}
}

# ----------------------------------------------------------------------
# Resource Group Creation
# ----------------------------------------------------------------------
resource "azurerm_resource_group" "resource_group" {
    name     = terraform.workspace
    location = var.location
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

# ----------------------------------------------------------------------
# Create VPC and Subnets
# ----------------------------------------------------------------------
module "network" {
    source                      = "./Core/network/"
    resource_group_name         = azurerm_resource_group.resource_group.name
    location                    = azurerm_resource_group.resource_group.location
    address_space_lab           = var.address_space_lab
    address_space_management    = var.address_space_management
    networks                    = var.networks
    candidate_ip                = var.candidate_ip
    security_rules              = var.security_rules
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
    location            = azurerm_resource_group.resource_group.location
    resource_group_name = azurerm_resource_group.resource_group.name
    systems_map         = module.dynamic_scaler.microsoft_windows_server_map
    subnet_ids          = module.network.subnet_ids
    security_group_ids  = module.network.security_group_ids
    system_password     = random_password.system_password.result
}

module "windows_desktop" {
    source              = "./Microsoft/Windows/Desktop"
    location            = azurerm_resource_group.resource_group.location
    resource_group_name = azurerm_resource_group.resource_group.name
    systems_map         = module.dynamic_scaler.microsoft_windows_desktop_map
    subnet_ids          = module.network.subnet_ids
    security_group_ids  = module.network.security_group_ids
    system_password     = random_password.system_password.result
}

module "ubuntu_server" {
    source              = "./Canonical/Ubuntu/Server/"
    location            = azurerm_resource_group.resource_group.location
    resource_group_name = azurerm_resource_group.resource_group.name
    systems_map         = module.dynamic_scaler.canonical_ubuntu_server_map
    subnet_ids          = module.network.subnet_ids
    security_group_ids  = module.network.security_group_ids
    public_key          = fileexists("../../SSH-Keys/${var.public_key_file_management}") ? file("../../SSH-Keys/${var.public_key_file_management}") : module.management.public_key
    private_key_path    = fileexists("../../SSH-Keys/${var.private_key_file_management}") ? "../../SSH-Keys/${var.private_key_file_management}" : module.management.private_key_path
    system_password     = random_password.system_password.result
}

module "kali" {
    source              = "./OffensiveSecurity/KaliLinux"
    location            = azurerm_resource_group.resource_group.location
    resource_group_name = azurerm_resource_group.resource_group.name
    systems_map         = module.dynamic_scaler.offensivesecurity_kalilinux_map
    private_key         = fileexists("../../SSH-Keys/${var.private_key_file_candidate}") ? file("../../SSH-Keys/${var.private_key_file_candidate}") : module.candidate.private_key
    public_key          = fileexists("../../SSH-Keys/${var.public_key_file_candidate}") ? file("../../SSH-Keys/${var.public_key_file_candidate}") : module.candidate.public_key
    subnet_ids          = module.network.subnet_ids
    security_group_ids  = module.network.security_group_ids
    system_password     = random_password.system_password.result
}

# ----------------------------------------------------------------------
# Build Ansible Inventory 
# ----------------------------------------------------------------------
module "ansible_inventory" {
    source          = "./Core/Ansible"
    features        = module.dynamic_scaler.features
    system_details  = concat( module.windows_server.details,
                            module.windows_desktop.details, 
                            module.ubuntu_server.details,
                            module.kali.details )
}

# ----------------------------------------------------------------------
# Launch Management Server
# ----------------------------------------------------------------------
module "management_server" {
    source                      = "./Core/Canonical/Ubuntu/Management/"
    resource_group_name         = azurerm_resource_group.resource_group.name
    location                    = azurerm_resource_group.resource_group.location
    network_id                  = module.network.subnet_id_management
    security_group_id           = module.network.security_group_management
    private_ip                  = var.management_server_private_ip
    public_key                  = fileexists("../../SSH-Keys/${var.public_key_file_management}") ? file("../../SSH-Keys/${var.public_key_file_management}") : module.management.public_key
    private_key                 = fileexists("../../SSH-Keys/${var.private_key_file_management}") ? file("../../SSH-Keys/${var.private_key_file_management}") : module.management.private_key
    private_key_path            = fileexists("../../SSH-Keys/${var.private_key_file_management}") ? "../../SSH-Keys/${var.private_key_file_management}" : module.management.private_key_path
    candidate_key_path          = fileexists("../../SSH-Keys/${var.private_key_file_candidate}") ? "../../SSH-Keys/${var.private_key_file_candidate}" : module.candidate.private_key_path
    security_group_ids          = module.network.security_group_ids
    ansible_inventory           = module.ansible_inventory.ansible_inventory_yml
    ansible_tags                = var.ansible_tags
    ansible_limit               = var.ansible_limit
    force_ansible_redeploy      = var.force_ansible_redeploy
    assets_path                 = var.assets_path
    depends_on                  = [ module.windows_server, 
                                    module.windows_desktop, 
                                    module.ubuntu_server,
                                    module.kali ]
}
