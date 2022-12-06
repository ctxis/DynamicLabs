locals {
    networks = {
        for network in var.networks: "${network["network_id"]}" => network
    }
}

# Create virtual networks within the resource group
resource "azurerm_virtual_network" "networks" {
    name                = "${terraform.workspace}-Network"
    resource_group_name = var.resource_group_name
    location            = var.location
    address_space       = [ var.address_space_lab ]
}

resource "azurerm_subnet" "subnets" {
    for_each = local.networks
    name                    = "${terraform.workspace}-${each.value["network_id"]}"
    resource_group_name     = var.resource_group_name
    virtual_network_name    = azurerm_virtual_network.networks.name
    address_prefixes        = [ each.value["address_space"] ]
}

resource "azurerm_subnet" "subnet_management" {
    name                    = "${terraform.workspace}-Management"
    resource_group_name     = var.resource_group_name
    virtual_network_name    = azurerm_virtual_network.networks.name
    address_prefixes        = [ var.address_space_management ]
}