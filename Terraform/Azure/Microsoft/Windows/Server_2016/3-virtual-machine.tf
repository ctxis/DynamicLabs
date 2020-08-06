data "template_file" "first_logon" {
    template = <<EOF
    <FirstLogonCommands>
        <SynchronousCommand>
            <CommandLine>powershell.exe -ExecutionPolicy ByPass -Encoded "JHVybCA9ICAiaHR0cDovLzEwLjEuMjU0LjEwOjEwMDgwL0NvbmZpZ3VyZVJlbW90aW5nRm9yQW5zaWJsZS5wczEiCiAgICAgICAgJGZpbGUgPSAiJGVudjp0ZW1wXENvbmZpZ3VyZVJlbW90aW5nRm9yQW5zaWJsZS5wczEiCiAgICAgICAgRG8gewogICAgICAgICAgICAgIHRyeSB7CiAgICAgICAgICAgICAgICAgIChOZXctT2JqZWN0IC1UeXBlTmFtZSBTeXN0ZW0uTmV0LldlYkNsaWVudCkuRG93bmxvYWRGaWxlKCR1cmwsICRmaWxlKQogICAgICAgICAgICAgIH0gY2F0Y2ggW1N5c3RlbS5OZXQuV2ViRXhjZXB0aW9uXSxbU3lzdGVtLklPLklPRXhjZXB0aW9uXSB7IGNvbnRpbnVlIH0KICAgICAgICAgICAgICBTdGFydC1TbGVlcCAtU2Vjb25kcyAxCiAgICAgICAgICB9IFdoaWxlICgoVGVzdC1QYXRoICRmaWxlKSAtZXEgJEZhbHNlKQogICAgICAgIGlmIChUZXN0LVBhdGggJGZpbGUpIHsKICAgICAgICAgIHBvd2Vyc2hlbGwuZXhlIC1FeGVjdXRpb25Qb2xpY3kgQnlQYXNzIC1GaWxlICRmaWxlIC1EaXNhYmxlQmFzaWNBdXRoCiAgICAgICAgfQ==" -file C:\Deploy.PS1</CommandLine
            ><Description>RunScript</Description>
            <Order>12</Order>
        </SynchronousCommand>
    </FirstLogonCommands>
    EOF
}

resource "azurerm_virtual_machine" "windows_server_2016" {
    for_each = var.systems_map
    name                          = each.value["name"]
    location                      = var.location
    resource_group_name           = var.resource_group_name
    network_interface_ids         = [azurerm_network_interface.windows_server_2016[each.value["name"]].id]
    vm_size                       = each.value["size"]
    
    delete_os_disk_on_termination = true
    delete_data_disks_on_termination = true

    storage_image_reference {
        publisher = "MicrosoftWindowsServer"
        offer     = "WindowsServer"
        sku       = "2016-Datacenter-smalldisk"
        version   = "latest"
    }

    storage_os_disk {
        name              = "${each.value["name"]}-disk1"
        caching           = "ReadWrite"
        create_option     = "FromImage"
        managed_disk_type = "Standard_LRS"
    }

    os_profile {
        computer_name  = each.value["name"]
        admin_username = var.system_user
        admin_password = var.system_password
    }

    os_profile_windows_config {
        provision_vm_agent        = true
        enable_automatic_upgrades = false

        additional_unattend_config {
            pass         = "oobeSystem"
            component    = "Microsoft-Windows-Shell-Setup"
            setting_name = "AutoLogon"
            content      = "<AutoLogon><Password><Value>${var.system_user}</Value></Password><Enabled>true</Enabled><LogonCount>1</LogonCount><Username>${var.system_password}</Username></AutoLogon>"
        }

        additional_unattend_config {
            pass = "oobeSystem"
            component = "Microsoft-Windows-Shell-Setup"
            setting_name = "FirstLogonCommands"
            content = data.template_file.first_logon.rendered
        }
    }
}

resource "ansible_host" "windows_server_2016" {
    for_each = var.systems_map
    inventory_hostname = azurerm_network_interface.windows_server_2016[each.value["name"]].private_ip_address
    groups = concat(each.value["features"])
    vars = {
        ansible_connection = "winrm"
        ansible_port = 5986
        ansible_winrm_transport = "ntlm"
        ansible_winrm_server_cert_validation = "ignore"
        ansible_user = var.system_user
        ansible_password = var.system_password
        custom_hostname = each.value["name"]
        attributes = jsonencode(each.value["attributes"])
    }
}