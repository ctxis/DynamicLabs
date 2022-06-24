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
            "${subnet["network_id"]}" => aws_subnet.subnet_config["${subnet["network_id"]}"].id
    }
}

output "subnet_id_management" {
    value = aws_subnet.subnet_config_management.id
}

output "security_group_ids" {
    description = "List of security group ids"
    value = {
        for network in var.networks:
            "${network.network_id}" => aws_security_group.security_group[network.network_id].id
    }
}

output "security_group_management" {
    value = aws_security_group.security_group_management.id
}