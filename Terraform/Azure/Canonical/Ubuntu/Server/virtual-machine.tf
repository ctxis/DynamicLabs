resource "azurerm_virtual_machine" "ubuntu_server" {
    for_each = var.systems_map
    name                          = each.value["name"]
    location                      = var.location
    resource_group_name           = var.resource_group_name
    network_interface_ids         = [azurerm_network_interface.ubuntu_server[each.value["name"]].id]
    vm_size                       = each.value["size"]
    
    delete_os_disk_on_termination = true
    delete_data_disks_on_termination = true

    storage_image_reference {
        publisher = "Canonical"
        offer     = each.value["os_version"] == "20.04" ? "0001-com-ubuntu-server-focal" : ( each.value["os_version"] == "22.04" ? "0001-com-ubuntu-server-jammy" : null ) 
        sku       = each.value["os_version"] == "20.04" ? "20_04-lts" : ( each.value["os_version"] == "22.04" ? "22_04-lts" : null )
        version   = "latest"
    }

    storage_os_disk {
        name              = "${each.value["name"]}-disk1"
        caching           = "ReadWrite"
        create_option     = "FromImage"
        managed_disk_type = "StandardSSD_LRS"
    }

    os_profile {
        computer_name = each.value["name"]
        admin_username = "ubuntu"
        admin_password = var.system_password
    }

    os_profile_linux_config {
        disable_password_authentication = true
        ssh_keys {
            key_data = var.public_key
            path = "/home/ubuntu/.ssh/authorized_keys"
        }
    }

}

resource "azurerm_network_interface_security_group_association" "ubuntu_server" {
    for_each = var.systems_map
    network_interface_id      = azurerm_network_interface.ubuntu_server[each.value["name"]].id
    network_security_group_id = var.security_group_ids[each.value["network_id"]]
}