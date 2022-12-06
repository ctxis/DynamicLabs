locals {
    security_rules = {for key, value in var.security_rules: key => value}
}

resource "aws_security_group" "security_group" {
    for_each = local.networks
        vpc_id = aws_vpc.vpc.id
        name = "${terraform.workspace}-SG-${each.value.network_id}"
        tags = {
            name = "${terraform.workspace}-SG-${each.value.network_id}"
        }    
}

# Default rules that apply to all network templates

resource "aws_security_group_rule" "security_group_rule_ingress_from_management" {
    for_each = local.networks
        description       = "Allow all traffic from the management network"
        security_group_id = aws_security_group.security_group[each.value.network_id].id
        type              = "ingress"
        cidr_blocks       = [ aws_subnet.subnet_config_management.cidr_block ]
        protocol          = -1
        from_port         = 0
        to_port           = 0
}

resource "aws_security_group_rule" "security_group_rule_full_internet_access" {
    for_each = local.networks
        description       = "Allow full Internet access"
        security_group_id = aws_security_group.security_group[each.value.network_id].id
        type              = "egress"
        cidr_blocks       = ["0.0.0.0/0"]
        ipv6_cidr_blocks  = ["::/0"]
        protocol          = -1
        from_port         = 0
        to_port           = 0
}

resource "aws_security_group_rule" "security_group_rule_allow_internal_traffic" {
    for_each = local.networks
        description       = "Allow internal traffic"
        security_group_id = aws_security_group.security_group[each.value.network_id].id
        type              = "ingress"
        cidr_blocks       = [ aws_subnet.subnet_config[each.value.network_id].cidr_block ]
        protocol          = -1
        from_port         = 0
        to_port           = 0
}

resource "aws_security_group_rule" "security_group_user_defined_rule" {
    for_each = local.security_rules
        description       = "User-defined security rule"
        security_group_id = aws_security_group.security_group[each.value.network_id].id
        type              = each.value.type
        cidr_blocks       = each.value.cidr_blocks
        protocol          = each.value.protocol
        from_port         = each.value.from_port
        to_port           = each.value.to_port
}

# Default rules that apply only to the candidate network template

locals {
    candidate_networks = {
        for name, network in var.networks : name => network
        if network["network_template"] == "candidate"
    }
}

resource "aws_security_group_rule" "security_group_rule_candidate_rdp" {
    for_each = local.candidate_networks
        description       = "Allow RDP from the candidate IP ranges"
        security_group_id = aws_security_group.security_group[each.value.network_id].id
        type              = "ingress"
        cidr_blocks       = var.candidate_ip
        protocol          = "TCP"
        from_port         = 3389
        to_port           = 3389
}

resource "aws_security_group_rule" "security_group_rule_candidate_ssh" {
    for_each = local.candidate_networks
        description       = "Allow SSH from the candidate IP ranges"
        security_group_id = aws_security_group.security_group[each.value.network_id].id
        type              = "ingress"
        cidr_blocks       = var.candidate_ip
        protocol          = "TCP"
        from_port         = 22
        to_port           = 22
}

# Default rules that apply only to the internal permissive network template

locals {
    internal_permissive_networks = {
        for name, network in var.networks : name => network
        if network["network_template"] == "internal_permissive"
    }
}

resource "aws_security_group_rule" "security_group_rule_internal_permissive_networks" {
    for_each = local.internal_permissive_networks
        description       = "Allow inbound traffic from all other internal networks"
        security_group_id = aws_security_group.security_group[each.value.network_id].id
        type              = "ingress"
        cidr_blocks       = [ aws_vpc.vpc.cidr_block ]
        protocol          = -1
        from_port         = 0
        to_port           = 0
}

# Default rules that apply only to the internal segregated network template

locals {
    internal_segregated_networks = {
        for name, network in var.networks : name => network
        if network["network_template"] == "internal_segregated"
    }
}

# Management network

resource "aws_security_group" "security_group_management" {
    vpc_id = aws_vpc.vpc.id
    name = "${terraform.workspace}-SG-Management"
    tags = {
            name = "${terraform.workspace}-SG-Management"
    }

    # Ingress Ports.
    ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = var.candidate_ip
    }

    ingress {
        from_port   = 10080
        to_port     = 10080
        protocol    = "tcp"
        cidr_blocks = [var.address_space_lab, var.address_space_management]
    }

    #Egress Ports
    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port   = -1
        to_port     = -1
        protocol    = "icmp"
        cidr_blocks = ["0.0.0.0/0"]
    }
}