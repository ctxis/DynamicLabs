locals {
    security_rules = {for key, value in var.security_rules: key => value}
}

resource "azurerm_network_security_group" "security_group" {
    for_each            = local.networks
    resource_group_name = var.resource_group_name
    name                = "${terraform.workspace}-SG-${each.value.network_id}"
    location            = var.location
}

resource "azurerm_network_security_rule" "security_group_rule" {
    for_each                        = local.security_rules
    resource_group_name             = var.resource_group_name
    network_security_group_name     = azurerm_network_security_group.security_group[each.value.network_id].name
    name                            = "${terraform.workspace}-SR-${each.value.name}"
    priority                        = each.value.priority
    direction                       = each.value.direction
    access                          = each.value.access
    protocol                        = each.value.protocol
    source_port_ranges              = each.value.source_port_ranges
    destination_port_ranges         = each.value.destination_port_ranges
    source_address_prefixes         = each.value.source_address_prefixes
    destination_address_prefixes    = each.value.destination_address_prefixes
}

resource "azurerm_network_security_rule" "security_group_rule_candidate" {
    name                        = "${terraform.workspace}-SR-AllowCandidateRDP"
    resource_group_name         = var.resource_group_name
    network_security_group_name = azurerm_network_security_group.security_group[var.candidate_network].name
    priority                    = 102
    direction                   = "Inbound"
    access                      = "Allow"
    protocol                    = "Tcp"
    source_port_range           = "*"
    destination_port_ranges     = ["22", "3389"]
    source_address_prefixes     = var.candidate_ip
    destination_address_prefix  = "*"
}

resource "azurerm_network_security_group" "security_group_management" {
    name                = "${terraform.workspace}-SG-Management"
    resource_group_name = var.resource_group_name
    location            = var.location

    security_rule {
        name                       = "AllowSSH"
        priority                   = 100
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefixes    = var.candidate_ip
        destination_address_prefix = "*"
    }

    security_rule {
        name                       = "AllowWeb"
        priority                   = 101
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "10000"
        source_address_prefixes    = var.address_space
        destination_address_prefix = "*"
    }

    security_rule {
        name                       = "AllowOutbound"
        priority                   = 1000
        direction                  = "Outbound"
        access                     = "Allow"
        protocol                   = "*"
        source_port_range          = "*"
        destination_port_range     = "*"
        source_address_prefixes    = var.address_space
        destination_address_prefix = "*"
    }
}