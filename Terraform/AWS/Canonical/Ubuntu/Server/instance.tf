data "aws_ami" "ubuntu_20_04" {
    most_recent = true
    filter {
        name   = "name"
        values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
    }
    filter {
        name   = "virtualization-type"
        values = ["hvm"]
    }
    # Amazon
    owners = ["099720109477"] 
}

data "aws_ami" "ubuntu_22_04" {
    most_recent = true
    filter {
        name   = "name"
        values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
    }
    filter {
        name   = "virtualization-type"
        values = ["hvm"]
    }
    # Amazon
    owners = ["099720109477"]
}

resource "aws_instance" "ubuntu_server" {
    for_each = var.systems_map
    ami                         = each.value["os_version"] == "20.04" ? data.aws_ami.ubuntu_20_04.id : (each.value["os_version"] == "22.04" ? data.aws_ami.ubuntu_22_04.id : null)
    instance_type               = each.value["size"]
    private_ip                  = each.value["private_ip"] == null ? null : each.value["private_ip"]
    key_name                    = var.key_name
    associate_public_ip_address = each.value["public_ip"]
    subnet_id                   = var.subnet_ids[each.value["network_id"]]
    vpc_security_group_ids      = [var.security_group_ids[each.value["network_id"]]]
    tags                        = {
        Name                    = each.value["name"]
    }
}
