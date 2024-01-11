# Commented out to prevent errors if the agreement is already in place
# resource "azurerm_marketplace_agreement" "kali" {
#    publisher = "kali-linux"
#    offer     = "kali-linux"
#    plan      = "hourly"
#}

resource "random_password" "kali_password" {
  length      = 16
  special     = true
  min_lower   = 1
  min_upper   = 1
  min_numeric = 1
  min_special = 1
}

resource "azurerm_virtual_machine" "kali" {
    for_each = var.systems_map
    name                          = each.value["name"]
    location                      = var.location
    resource_group_name           = var.resource_group_name
    network_interface_ids         = [azurerm_network_interface.kali[each.value["name"]].id]
    vm_size                       = each.value["size"]
    
    delete_os_disk_on_termination = true
    delete_data_disks_on_termination = true
    # depends_on = [ azurerm_public_ip.kali ]

    # The kali machine from publisher "kali-linux" is no longer available
    # thus, a Debian machine was used to replace Kali
    storage_image_reference {
        publisher = "kali-linux"
        offer     = "kali"
        sku       = "kali-${each.value["os_version"]}"
        version   = "latest"
    }

    plan {
        name      = "kali-${each.value["os_version"]}"
        publisher = "kali-linux"
        product   = "kali"
    }

    storage_os_disk {
        name              = "${each.value["name"]}-disk1"
        #caching           = "ReadWrite"
        create_option     = "FromImage"
        # To try speed up the upgrade process use faster storage
        # managed_disk_type = "StandardSSD_LRS"
    }

    os_profile {
        computer_name = each.value["name"]
        admin_username = var.system_user
        admin_password = var.system_password
    }

    os_profile_linux_config {
        disable_password_authentication = true
        ssh_keys {
            key_data = var.public_key
            path = "/home/kali/.ssh/authorized_keys"
        }
    }
    
    # The verision of Kali Linux in Azure is ancient, 2019.2 at the time of writing
    # This installs an updated repo key
#    provisioner "remote-exec" {
#        inline = [
#            "wget -q -O - https://archive.kali.org/archive-key.asc  | sudo apt-key add",
#        ]
#    }
    
    connection {
        private_key = var.private_key
        user        = var.system_user
        host        = azurerm_public_ip.kali[each.value["name"]].ip_address
    }
}

resource "azurerm_network_interface_security_group_association" "kali" {
    for_each = var.systems_map
    network_interface_id      = azurerm_network_interface.kali[each.value["name"]].id
    network_security_group_id = var.security_group_ids[each.value["network_id"]]
}
