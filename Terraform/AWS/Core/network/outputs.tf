###################################################################################################
# Outputs
####################################################################################################

output "lab_vpc_id" {
  value = aws_vpc.vpc.id
}

output "subnet_ids" {
  description = "List of IDs assigned to subnets"
  value = {
     for subnet in var.networks :
         "${subnet["network_id"]}"
            => aws_subnet.subnet_config["${subnet["network_id"]}"].id
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
