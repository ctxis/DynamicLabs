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

resource "aws_security_group_rule" "security_group_rule" {
    for_each = local.security_rules
    security_group_id = aws_security_group.security_group[each.value.network_id].id
    type = each.value.type
    cidr_blocks = each.value.cidr_blocks
    protocol = each.value.protocol
    from_port = each.value.from_port
    to_port = each.value.to_port
}

resource "aws_security_group_rule" "security_group_rule_candidate" {
    security_group_id = aws_security_group.security_group[var.candidate_network].id
    type = "ingress"
    cidr_blocks = var.candidate_ip
    protocol = "TCP"
    from_port = 3389
    to_port = 3389
}

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
        cidr_blocks = [var.address_space_vpc, var.address_space_management]
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