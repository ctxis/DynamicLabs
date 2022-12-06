locals {
    public_systems     = [for system in var.systems_map: system if system.public_ip == true]
    public_systems_map = {
        for system in local.public_systems: "${system["name"]}" => system
    }
}

resource "azurerm_public_ip" "ubuntu_server" {
    for_each = local.public_systems_map
    name                    = each.value["name"]
    location                = var.location
    resource_group_name     = var.resource_group_name
    allocation_method       = "Dynamic"
    idle_timeout_in_minutes = 30
}

resource "azurerm_network_interface" "ubuntu_server" {
    for_each = var.systems_map
    name                    = each.value["name"]
    location                = var.location
    resource_group_name     = var.resource_group_name
    internal_dns_name_label = each.value["name"]

    ip_configuration {
        name                          = "primary"
        subnet_id                     = var.subnet_ids[each.value["network_id"]]
        private_ip_address_allocation = each.value["private_ip"] == null ? "Dynamic" : "Static"
        private_ip_address            = each.value["private_ip"] == null ? null : each.value["private_ip"]
        public_ip_address_id          = each.value["public_ip"] == true ? azurerm_public_ip.ubuntu_server[each.value["name"]].id : null
    }
}