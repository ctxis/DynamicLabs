output "details" {
    description = "List of public IP addresses assigned to the instances, if applicable"
    value = [ for system in var.systems_map : {
        "name"      = system["name"]
        "user"      = var.system_user
        "ansible_data" = {
            "custom_hostname" = system["name"]
            "ansible_connection" = "ssh"
            "ansible_user" = var.system_user
            "ansible_ssh_private_key_file" = "candidate_key.pem"
            "ansible_ssh_common_args" = "-o StrictHostKeyChecking=no"
            "ansible_become" = "true"
            "features" = jsonencode(system["features"])
        }
        "public_ip" = aws_instance.kali["${system["name"]}"].public_ip == null ? null : aws_instance.kali["${system["name"]}"].public_ip
        "private_ip" = aws_instance.kali["${system["name"]}"].private_ip
        "features" = system["features"]
    }]
}
