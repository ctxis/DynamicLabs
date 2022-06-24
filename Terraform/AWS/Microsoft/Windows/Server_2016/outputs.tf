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
        "private_ip" = aws_instance.windows_server_2016["${system["name"]}"].private_ip
        "public_ip" = aws_instance.windows_server_2016["${system["name"]}"].public_ip == null ? null : aws_instance.windows_server_2016["${system["name"]}"].public_ip
        "features" = system.features
    }]
}