data "template_file" "base_config" {
  template = <<EOF
        <FirstLogonCommands>
            <SynchronousCommand>
                <CommandLine>cmd /c "copy C:\AzureData\CustomData.bin C:\AzureData\ConfigureRemotingForAnsible.ps1"</CommandLine>
                <Description>Copy Azure Data</Description>
                <Order>11</Order>
            </SynchronousCommand>
            <SynchronousCommand>
                <CommandLine>powershell.exe -ExecutionPolicy Bypass -File C:\AzureData\ConfigureRemotingForAnsible.ps1 -DisableBasicAuth</CommandLine>
                <Description>Enable WinRM</Description>
                <Order>12</Order>
            </SynchronousCommand>
        </FirstLogonCommands>
    EOF
}

resource "azurerm_virtual_machine" "windows_desktop" {
    for_each = var.systems_map
    name                          = each.value["name"]
    location                      = var.location
    resource_group_name           = var.resource_group_name
    network_interface_ids         = [azurerm_network_interface.windows_desktop[each.value["name"]].id]
    vm_size                       = each.value["size"]
    
    delete_os_disk_on_termination = true
    delete_data_disks_on_termination = true

    storage_image_reference {
        publisher = "MicrosoftWindowsDesktop"
        offer     = each.value["os_version"] == "10" ? "Windows-10" : ( each.value["os_version"] == "11" ? "Windows-11" : null )
        # Use current latest SKU for each OS
        # List available ones with:
        #   az vm image list --all --publisher "MicrosoftWindowsDesktop" --offer "Windows-10"
        #   az vm image list --all --publisher "MicrosoftWindowsDesktop" --offer "Windows-11"
        sku       = each.value["os_version"] == "10" ? "win10-21h2-ent" : ( each.value["os_version"] == "11" ? "win11-22h2-ent" : null )
        version   = "latest"
    }

    storage_os_disk {
        name              = "${each.value["name"]}-disk1"
        caching           = "ReadWrite"
        create_option     = "FromImage"
        managed_disk_type = "StandardSSD_LRS"
    }

    os_profile {
        computer_name  = each.value["name"]
        admin_username = var.system_user
        admin_password = var.system_password
        custom_data    = file("Microsoft/Windows/Desktop/files/ConfigureRemotingForAnsible.ps1")
    }

    os_profile_windows_config {
        provision_vm_agent        = true
        enable_automatic_upgrades = false

        # Auto-Login
        additional_unattend_config {
            pass         = "oobeSystem"
            component    = "Microsoft-Windows-Shell-Setup"
            setting_name = "AutoLogon"
            content      = "<AutoLogon><Password><Value>${var.system_password}</Value></Password><Enabled>true</Enabled><LogonCount>1</LogonCount><Username>${var.system_user}</Username></AutoLogon>"
        }

        # Enable WinRM
        additional_unattend_config {
            pass         = "oobeSystem"
            component    = "Microsoft-Windows-Shell-Setup"
            setting_name = "FirstLogonCommands"
            content      = data.template_file.base_config.rendered
        }
    }
}

resource "azurerm_network_interface_security_group_association" "windows_desktop" {
    for_each = var.systems_map
    network_interface_id      = azurerm_network_interface.windows_desktop[each.value["name"]].id
    network_security_group_id = var.security_group_ids[each.value["network_id"]]
}
