output "details" {
    value = [ for system in var.systems_map : {
        "name"      = system["name"]
        "ansible_data" = {
            "custom_hostname" = system["name"]
            "ansible_connection" = "ssh"
            "ansible_user" = var.system_user
            "ansible_ssh_private_key_file" = "management_key.pem"
            "ansible_ssh_common_args" = "-o StrictHostKeyChecking=no"
            "ansible_become" = "true"
            "windows_system_user" = var.windows_system_user
            "windows_system_password" = format("\"%s\"",var.windows_system_password)
            "features" = jsonencode(system["features"])
        }
        "private_ip" = aws_instance.macos_x86_64["${system["name"]}"].private_ip
        "public_ip" = aws_instance.macos_x86_64["${system["name"]}"].public_ip == null ? null : aws_instance.macos_x86_64["${system["name"]}"].public_ip
        "features" = system.features
    }]
}
