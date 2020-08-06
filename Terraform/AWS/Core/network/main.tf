locals {
  networks = {
    for network in var.networks: "${network["network_id"]}" => network
  }
  public_networks     = [for network in var.networks: network if network.public_ip == true]
  public_networks_map = {
    for network in local.public_networks: "${network["network_id"]}" => network
  }
}

/*
  VPC
*/
resource "aws_vpc" "vpc" {
    cidr_block            = var.address_space_vpc
    enable_dns_support    = true
    enable_dns_hostnames  = true
    tags = {
      Name = "${terraform.workspace}"
    }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "${terraform.workspace}-Gateway"
  }
}

resource "aws_subnet" "subnet_config" {
  for_each = local.networks
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = each.value["address_space"]
  map_public_ip_on_launch = each.value["public_ip"]
  availability_zone       = var.availability_zone
  tags = {
    Name = "${terraform.workspace}-${each.value["network_tier"]}-${each.value["network_id"]}"
  }
}

resource "aws_route_table" "subnet_config" {
    // Only add route to igw for public subnets
    for_each = local.public_networks_map

    vpc_id = aws_vpc.vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw.id
    }
    tags = {
        Name = "${terraform.workspace}-${each.value["network_tier"]}-${each.value["network_id"]}-igw"
    }
}

resource "aws_route_table_association" "subnet_config" {
    // Only add route to igw for public subnets
    for_each = local.public_networks_map
    subnet_id = aws_subnet.subnet_config[each.key].id
    route_table_id = aws_route_table.subnet_config[each.key].id
}
