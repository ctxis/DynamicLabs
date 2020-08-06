locals {
    networks = {
        for network in var.networks: "${network["network_id"]}" => network
    }
    public_networks     = [for network in var.networks: network if network.public_ip == true]
    public_networks_map = {
        for network in local.public_networks: "${network["network_id"]}" => network
    }
}

# Create virtual networks within the resource group
resource "azurerm_virtual_network" "networks" {
    name                = "Network"
    resource_group_name = var.resource_group_name
    location            = var.location
    address_space       = var.address_space
}

resource "azurerm_subnet" "subnets" {
    for_each = local.networks
    name                    = each.value["network_id"]
    resource_group_name     = var.resource_group_name
    virtual_network_name    = azurerm_virtual_network.networks.name
    address_prefixes        = each.value["address_space"]
}