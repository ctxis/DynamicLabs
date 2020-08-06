resource "aws_instance" "kali" {
    for_each = var.systems_map
    ami                       = var.AMI
    instance_type             = each.value["size"]
    key_name                  = var.candidate_key_name
    private_ip                = each.value["private_ip"] == null ? null : each.value["private_ip"]
    subnet_id                 = var.subnet_ids[each.value["network_id"]]
    vpc_security_group_ids    =["${aws_security_group.default_ports_kali.id}"]
    tags  = {
        Name = each.value["name"]
    }
}

resource "ansible_host" "kali" {
    for_each = var.systems_map
    inventory_hostname = aws_instance.kali[each.value["name"]].private_ip
    vars = {
        ansible_user = "ec2_user"
        ansible_ssh_private_key_file = var.private_key
        custom_hostname = each.value["name"]
        attributes = jsonencode(each.value["attributes"])
    }
}