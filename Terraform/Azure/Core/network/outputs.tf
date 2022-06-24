###################################################################################################
# Outputs
####################################################################################################
output "virtual_network_name" {
    value = azurerm_virtual_network.networks.name
}

output "subnet_ids" {
  description = "List of IDs assigned to subnets"
  value = {
    for subnet in var.networks :
        subnet["network_id"] => azurerm_subnet.subnets[subnet["network_id"]].id
  }
}

output "subnet_id_management" {
    value = azurerm_subnet.subnet_management.id
}

output "security_group_ids" {
    description = "List of security group ids"
    value = {
        for network in var.networks:
            "${network.network_id}" => azurerm_network_security_group.security_group[network.network_id].id
    }
}

output "security_group_management" {
    value = azurerm_network_security_group.security_group_management.id
}