locals {
    server_name = "${terraform.workspace}-Overlord"
}

resource "azurerm_public_ip" "management" {
    name                    = local.server_name
    location                = var.location
    resource_group_name     = var.resource_group_name
    allocation_method       = "Dynamic"
    idle_timeout_in_minutes = 30
}

resource "azurerm_network_interface" "management" {
    name                = local.server_name
    location            = var.location
    resource_group_name = var.resource_group_name

    ip_configuration {
        name                          = "${local.server_name}-nic-config"
        subnet_id                     = var.network_id
        private_ip_address_allocation = "Static"
        private_ip_address            = var.private_ip
        public_ip_address_id          = azurerm_public_ip.management.id
    }
}

resource "azurerm_virtual_machine" "management" {
    name                  = local.server_name
    location              = var.location
    resource_group_name   = var.resource_group_name
    network_interface_ids = [azurerm_network_interface.management.id]
    vm_size               = "Standard_B1s"

    delete_os_disk_on_termination = true
    delete_data_disks_on_termination = true

    storage_image_reference {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "18.04-LTS"
        version   = "latest"
    }

    storage_os_disk {
        name              = "OSDisk1"
        caching           = "ReadWrite"
        create_option     = "FromImage"
        managed_disk_type = "Standard_LRS"
    }
    
    tags = {
        Name = local.server_name
    }

    os_profile {
        computer_name = local.server_name
        admin_username = "ubuntu"
    }

    os_profile_linux_config {
        disable_password_authentication = true
        ssh_keys {
            key_data = var.public_key
            path = "/home/ubuntu/.ssh/authorized_keys"
        }
    }

    provisioner "file" {
        source      = "Terraform/AWS/Core/Canonical/Ubuntu/18.04_Management/files/"
        destination = "./"
    }

    provisioner "file" {
        source      = "Ansible"
        destination = "./Ansible"
    }

    provisioner "remote-exec" {
        inline = [
        "sudo apt-add-repository ppa:ansible/ansible -y",
        "sudo apt update",
        "sudo apt install ansible -y",
        "ansible-playbook ./Ansible/roles/management-server.yml",
        "#ansible-playbook -i /etc/ansible/terraform.py ./Ansible/site.yml"
        ]
    }


    connection {
        private_key = var.private_key
        user        = "ubuntu"
        host        = azurerm_network_interface.management[local.server_name].public_ip_address
    }
}