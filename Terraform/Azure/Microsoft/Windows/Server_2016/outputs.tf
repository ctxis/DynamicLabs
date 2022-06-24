output "details" {
    value = [ for system in var.systems_map : {
        "name"      = system["name"]
        "ansible_data" = {
            "custom_hostname" = system["name"]
            "ansible_connection" = "winrm"
            "ansible_port" = "5986"
            "ansible_winrm_transport" = "ntlm"
            "ansible_winrm_server_cert_validation" = "ignore"
            "ansible_user" = var.system_user
            "ansible_password" = var.system_password
            "features" = jsonencode(system["features"])
        }        
        "public_ip" = system["public_ip"] == true ? azurerm_public_ip.windows_server_2016[system["name"]].ip_address : null
        "private_ip" = azurerm_network_interface.windows_server_2016[system["name"]].private_ip_address
        "features" = system["features"]
    }]
}