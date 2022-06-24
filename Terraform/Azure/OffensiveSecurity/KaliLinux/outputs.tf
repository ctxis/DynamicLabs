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
        "public_ip" = system["public_ip"] == true ? azurerm_public_ip.kali[system["name"]].ip_address : null
        "private_ip" = azurerm_network_interface.kali[system["name"]].private_ip_address
        "features"  = system.features
    }]
}