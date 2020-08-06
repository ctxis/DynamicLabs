# Configure the Azure Provider
provider "azurerm" {
  features {}
}

terraform {
    required_version = ">= 0.12"
}

# Create a resource group
resource "azurerm_resource_group" "resource_group" {
    name     = terraform.workspace
    location = var.location
}

# ----------------------------------------------------------------------
# Configure VPC and Subnets
# ----------------------------------------------------------------------
module "network" {
    source                    = "../Azure/Core/network/"
    resource_group_name       = azurerm_resource_group.resource_group.name
    location                  = azurerm_resource_group.resource_group.location
    address_space             = var.address_space
    networks                  = var.networks
}

# ----------------------------------------------------------------------
# Configure Management Server
# ----------------------------------------------------------------------
module "management_server" {
    source           = "../Azure/Core/Canonical/Ubuntu/18.04_Management/"
    resource_group_name         = azurerm_resource_group.resource_group.name
    location                    = azurerm_resource_group.resource_group.location
    network_id                  = module.network.subnet_ids["999"]
    private_ip                  = var.management_server_private_ip
    public_key                  = "${file("SSH-Keys/${var.public_key_file_management}")}"
    private_key                 = "${file("SSH-Keys/${var.private_key_file_management}")}"
}

# ----------------------------------------------------------------------
# Split systems variable into individual maps for scaling systems
# ----------------------------------------------------------------------
module "dynamic_scaler" {
    source  = "../Azure/Core/DynamicScaler"
    systems = var.systems
}