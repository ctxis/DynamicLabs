data "aws_ami" "kali" {
    owners = ["679593333241"]
    most_recent = true
    filter {
        name   = "name"
        values = ["kali-last-snapshot-amd64*"]
    }
    filter {
        name   = "virtualization-type"
        values = ["hvm"]
    }
}

resource "aws_instance" "kali" {
    for_each                    = var.systems_map
    ami                         = data.aws_ami.kali.id
    instance_type               = each.value["size"]
    key_name                    = var.key_name
    private_ip                  = each.value["private_ip"] == null ? null : each.value["private_ip"]
    associate_public_ip_address = each.value["public_ip"]
    subnet_id                   = var.subnet_ids[each.value["network_id"]]
    vpc_security_group_ids      = [var.security_group_ids[each.value["network_id"]]]
    tags  = {
        Name = each.value["name"]
    }
}
