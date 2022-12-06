/*
  VPC
*/
locals {
    networks = {
        for network in var.networks: "${network["network_id"]}" => network
    }
}

resource "aws_vpc" "vpc" {
    cidr_block            = var.address_space_lab
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
    tags = {
        Name = "${terraform.workspace}-${each.value["network_id"]}"
    }
}

resource "aws_route_table" "route_table" {
    for_each = local.networks
    vpc_id = aws_vpc.vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw.id
    }
    tags = {
        Name = "${terraform.workspace}-${each.value["network_id"]}-igw"
    }
}

resource "aws_route_table_association" "aws_route_table_association" {
    for_each = local.networks
    subnet_id = aws_subnet.subnet_config[each.key].id
    route_table_id = aws_route_table.route_table[each.key].id
}

resource "aws_subnet" "subnet_config_management" {
    vpc_id                  = aws_vpc.vpc.id
    cidr_block              = var.address_space_management
    tags = {
        Name = "${terraform.workspace}-ManagementSubnet"
    }
}

resource "aws_route_table" "route_table_management" {
    vpc_id = aws_vpc.vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw.id
    }
}

resource "aws_route_table_association" "aws_route_table_association_management" {
    subnet_id = aws_subnet.subnet_config_management.id
    route_table_id = aws_route_table.route_table_management.id
}