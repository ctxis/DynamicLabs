data "aws_ami" "ubuntu_focal" {
    most_recent = true
    filter {
        name   = "name"
        values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
    }
    filter {
        name   = "virtualization-type"
        values = ["hvm"]
    }
    owners = ["099720109477"]
}

resource "aws_instance" "ubuntu_20_04" {
    for_each = var.systems_map
    ami                         = data.aws_ami.ubuntu_focal.id 
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