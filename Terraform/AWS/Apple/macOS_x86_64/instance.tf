data "aws_ami" "macos_bigsur_x86_64" {
    most_recent = true
    filter {
        name   = "name"
        values = ["amzn-ec2-macos-11.*"]
    }
    filter {
        name   = "virtualization-type"
        values = ["hvm"]
    }
    filter {
        name   = "architecture"
        values = ["x86_64_mac"]
    }    
    owners = ["amazon"]
}

data "aws_ami" "macos_monterey_x86_64" {
    most_recent = true
    filter {
        name   = "name"
        values = ["amzn-ec2-macos-12.*"]
    }
    filter {
        name   = "virtualization-type"
        values = ["hvm"]
    }
    filter {
        name   = "architecture"
        values = ["x86_64_mac"]
    }    
    owners = ["amazon"]
}

data "aws_ami" "macos_ventura_x86_64" {
    most_recent = true
    filter {
        name   = "name"
        values = ["amzn-ec2-macos-13.*"]
    }
    filter {
        name   = "virtualization-type"
        values = ["hvm"]
    }
    filter {
        name   = "architecture"
        values = ["x86_64_mac"]
    }    
    owners = ["amazon"]
}

data "aws_ami" "macos_sonoma_x86_64" {
    most_recent = true
    filter {
        name   = "name"
        values = ["amzn-ec2-macos-13.*"]
    }
    filter {
        name   = "virtualization-type"
        values = ["hvm"]
    }
    filter {
        name   = "architecture"
        values = ["x86_64_mac"]
    }    
    owners = ["amazon"]
}

resource "aws_instance" "macos_x86_64" {
    for_each = var.systems_map
    ami                         = each.value["os_version"] == "bigsur" ? data.aws_ami.macos_bigsur_x86_64.id : (each.value["os_version"] == "monterey" ? data.aws_ami.macos_monterey_x86_64.id : (each.value["os_version"] == "ventura" ? data.aws_ami.macos_ventura_x86_64.id : (each.value["os_version"] == "sonoma" ? data.aws_ami.macos_sonoma_x86_64.id : null ) ))
    instance_type               = each.value["size"]
    host_id                     = each.value["dedicated_host_id"]
    private_ip                  = each.value["private_ip"] == null ? null : each.value["private_ip"]
    key_name                    = var.key_name
    associate_public_ip_address = each.value["public_ip"]
    subnet_id                   = var.subnet_ids[each.value["network_id"]]
    vpc_security_group_ids      = [var.security_group_ids[each.value["network_id"]]]
    tags                        = {
        Name                    = each.value["name"]
    }
}
