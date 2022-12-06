locals {
    server_name = length(terraform.workspace) < 7 ? "${terraform.workspace}Overlord" : "${substr(terraform.workspace,0,4)}${substr(terraform.workspace,-2,-1)}Overlord"
}

resource "azurerm_public_ip" "management" {
    name                    = local.server_name
    location                = var.location
    resource_group_name     = var.resource_group_name
    allocation_method       = "Static"
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

resource "azurerm_network_interface_security_group_association" "management" {
    network_interface_id      = azurerm_network_interface.management.id
    network_security_group_id = var.security_group_id
}

resource "azurerm_virtual_machine" "management" {
    name                  = local.server_name
    location              = var.location
    resource_group_name   = var.resource_group_name
    network_interface_ids = [azurerm_network_interface.management.id]
    vm_size               = "Standard_B1ms"

    delete_os_disk_on_termination = true
    delete_data_disks_on_termination = true

    storage_image_reference {
        publisher = "Canonical"
        offer     = "0001-com-ubuntu-server-jammy"
        sku       = "22_04-lts"
        version   = "latest"
    }

    storage_os_disk {
        name              = "${local.server_name}-OSDisk1"
        caching           = "ReadWrite"
        create_option     = "FromImage"
        managed_disk_type = "StandardSSD_LRS"
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
        source      = "Core/Canonical/Ubuntu/Management/files/"
        destination = "./"
    }

    provisioner "file" {
        source      = "../../Ansible"
        destination = "./Ansible"
    }
    
    provisioner "file" {
        source      = var.private_key_path
        destination = "./management_key.pem"
    }

    provisioner "remote-exec" {
        inline = [
            "set -o errexit",
            "sudo apt-add-repository ppa:ansible/ansible -y",
            "sudo apt update",
            "sudo apt install ansible -y",
            "ansible-galaxy collection install community.windows",
            "ansible-playbook ./Ansible/roles/management-server.yml",
            "sleep 2m",
        ]
    }

    connection {
        private_key = var.private_key
        user        = "ubuntu"
        host        = azurerm_public_ip.management.ip_address
    }
}

resource "null_resource" "ansible_assets" {
    # Executes only when var.assets_path is defined in the tfvars file
    # to synchronise the assets directory to the management server

    count = var.assets_path != null ? 1 : 0

    depends_on = [ azurerm_virtual_machine.management ]

    triggers = { 
        # Workaround to force recreation of the resource at every terraform execution
        timestamp = timestamp()
    }

    provisioner "remote-exec" {
        inline = [
            "rm -fr ./assets; mkdir ./assets"
        ]
    }

    provisioner "file" {
        source      = "${path.root}/../../${var.assets_path}"
        destination = "./assets/"
    }

    connection {
        private_key = var.private_key
        user        = "ubuntu"
        host        = azurerm_public_ip.management.ip_address
    }
}

resource "null_resource" "ansible_executioner" {
    depends_on = [
        azurerm_virtual_machine.management,
        null_resource.ansible_assets
    ]
    
    triggers = {
        ansible_inventory = var.ansible_inventory
        management_server = azurerm_virtual_machine.management.id
        # Workaround to force recreation of the resource at every terraform execution
        timestamp = var.force_ansible_redeploy ? timestamp() : null
    }

    provisioner "file" {
        source      = var.private_key_path
        destination = "./management_key.pem"
    }

    provisioner "file" {
        source      = var.candidate_key_path
        destination = "./candidate_key.pem"
    }
    
    provisioner "remote-exec" {
        inline = [
            "chmod 600 ./management_key.pem",
            "chmod 600 ./candidate_key.pem"
        ]
    }
    
    # Workaround to make sure that the Ansible code is always up-to-date
    provisioner "remote-exec" {
        inline = [
            "rm -fr ./Ansible"
        ]
    }

    provisioner "file" {
        source      = "../../Ansible"
        destination = "./Ansible"
    }

    provisioner "file" {
        content      = var.ansible_inventory
        destination  = "./ansible-inventory.yml"
    }

    provisioner "remote-exec" {
        inline = [
            "ansible-playbook -i ansible-inventory.yml -f 10 ./Ansible/site.yml --tags ${var.ansible_tags} --limit ${var.ansible_limit} -vvvv"
        ]
    }

    connection {
        private_key = var.private_key
        user        = "ubuntu"
        host        = azurerm_public_ip.management.ip_address
    }
}