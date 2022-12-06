locals {
    security_rules = {for key, value in var.security_rules: key => value}
}

resource "azurerm_network_security_group" "security_group" {
    for_each            = local.networks
    resource_group_name = var.resource_group_name
    name                = "${terraform.workspace}-SG-${each.value.network_id}"
    location            = var.location
}

#
# Default rules that apply to all network templates
#

# All networks inbound

resource "azurerm_network_security_rule" "security_group_rule_allow_all_inbound_from_same_subnet" {
    for_each                        = local.networks
        resource_group_name             = var.resource_group_name
        network_security_group_name     = azurerm_network_security_group.security_group[each.value.network_id].name
        name                            = "Allow All Inbound Traffic from Same Subnet"
        priority                        = 4094
        direction                       = "Inbound"
        access                          = "Allow"
        protocol                        = "*"
        source_port_range               = "*"
        destination_port_range          = "*"
        source_address_prefix           = each.value.address_space
        destination_address_prefix      = "*"
}

resource "azurerm_network_security_rule" "security_group_rule_allow_all_inbound_from_management" {
    for_each                        = local.networks
        resource_group_name             = var.resource_group_name
        network_security_group_name     = azurerm_network_security_group.security_group[each.value.network_id].name
        name                            = "Allow All Inbound Traffic from Management"
        priority                        = 4095
        direction                       = "Inbound"
        access                          = "Allow"
        protocol                        = "*"
        source_port_range               = "*"
        destination_port_range          = "*"
        source_address_prefixes         = azurerm_subnet.subnet_management.address_prefixes
        destination_address_prefix      = "*"
}

resource "azurerm_network_security_rule" "security_group_rule_drop_all_inbound" {
    # Invalidates the default rules
    for_each                        = local.networks
        resource_group_name             = var.resource_group_name
        network_security_group_name     = azurerm_network_security_group.security_group[each.value.network_id].name
        name                            = "Drop All Inbound Traffic"
        priority                        = 4096
        direction                       = "Inbound"
        access                          = "Deny"
        protocol                        = "*"
        source_port_range               = "*"
        destination_port_range          = "*"
        source_address_prefix           = "*"
        destination_address_prefix      = "*"
}

# All networks outbound

resource "azurerm_network_security_rule" "security_group_rule_allow_virtualnetwork_outbound" {
    for_each                        = local.networks
        resource_group_name             = var.resource_group_name
        network_security_group_name     = azurerm_network_security_group.security_group[each.value.network_id].name
        name                            = "Allow Outbound Traffic to Virtual Network"
        priority                        = 4094
        direction                       = "Outbound"
        access                          = "Allow"
        protocol                        = "*"
        source_port_range               = "*"
        destination_port_range          = "*"
        source_address_prefix           = "*"
        destination_address_prefix      = "VirtualNetwork"
}

resource "azurerm_network_security_rule" "security_group_rule_allow_internet_outbound" {
    for_each                        = local.networks
        resource_group_name             = var.resource_group_name
        network_security_group_name     = azurerm_network_security_group.security_group[each.value.network_id].name
        name                            = "Allow Outbound Traffic to the Internet"
        priority                        = 4095
        direction                       = "Outbound"
        access                          = "Allow"
        protocol                        = "*"
        source_port_range               = "*"
        destination_port_range          = "*"
        source_address_prefix           = "*"
        destination_address_prefix      = "Internet"
}

resource "azurerm_network_security_rule" "security_group_rule_drop_all_outbound" {
    # Invalidates the default rules
    for_each                        = local.networks
        resource_group_name             = var.resource_group_name
        network_security_group_name     = azurerm_network_security_group.security_group[each.value.network_id].name
        name                            = "Drop All Outbound Traffic"
        priority                        = 4096
        direction                       = "Outbound"
        access                          = "Deny"
        protocol                        = "*"
        source_port_range               = "*"
        destination_port_range          = "*"
        source_address_prefix           = "*"
        destination_address_prefix      = "*"
}


# Default rules that apply only to the candidate network template

locals {
    candidate_networks = {
        for name, network in var.networks : name => network
        if network["network_template"] == "candidate"
    }
}

resource "azurerm_network_security_rule" "security_group_rule_allow_candidate_inbound_to_rdp_and_ssh" {
    for_each = local.candidate_networks
        name                        = "Allow RDP and SSH from the Candidate A"
        resource_group_name         = var.resource_group_name
        network_security_group_name = azurerm_network_security_group.security_group[each.value.network_id].name
        priority                    = 4000
        direction                   = "Inbound"
        access                      = "Allow"
        protocol                    = "Tcp"
        source_port_range           = "*"
        destination_port_ranges     = ["22", "3389"]
        source_address_prefixes     = var.candidate_ip
        destination_address_prefix  = "*"
}

#
# Default rules that apply only to the internal permissive network template
#

locals {
    internal_permissive_networks = {
        for name, network in var.networks : name => network
        if network["network_template"] == "internal_permissive"
    }
}

resource "azurerm_network_security_rule" "security_group_rule_permissive_network_allow_virtualnetwork_inbound" {
    for_each                        = local.internal_permissive_networks
        resource_group_name             = var.resource_group_name
        network_security_group_name     = azurerm_network_security_group.security_group[each.value.network_id].name
        name                            = "Allow All Inbound Traffic from Virtual Network"
        priority                        = 4000
        direction                       = "Inbound"
        access                          = "Allow"
        protocol                        = "*"
        source_port_range               = "*"
        destination_port_range          = "*"
        source_address_prefix           = "VirtualNetwork"
        destination_address_prefix      = "*"
}


# Default rules that apply only to the internal segregated network template

locals {
    internal_segregated_networks = {
        for name, network in var.networks : name => network
        if network["network_template"] == "internal_segregated"
    }
}

# No default rules

# Custom security rules

resource "azurerm_network_security_rule" "security_group_custom_rule" {
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

# Management network

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
        source_address_prefixes    = [ var.address_space_lab ]
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
        source_address_prefixes    = [ var.address_space_lab ]
        destination_address_prefix = "*"
    }
}