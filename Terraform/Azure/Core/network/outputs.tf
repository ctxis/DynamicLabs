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

output "network_tiers" {
  description = "List of tiers corresponding to their subnet_id"
  value = {
     for subnet in var.networks :
         "${subnet["network_id"]}"
            => "${subnet["network_tier"]}"
  }
}