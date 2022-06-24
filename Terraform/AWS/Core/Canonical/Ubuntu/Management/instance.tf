locals {
    server_name = length(terraform.workspace) < 7 ? "${terraform.workspace}Overlord" : "${substr(terraform.workspace,0,4)}${substr(terraform.workspace,-2,-1)}Overlord"
}

data "aws_ami" "ubuntu" {
    most_recent = true
    filter {
        name   = "name"
        values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
    }
    filter {
        name   = "virtualization-type"
        values = ["hvm"]
    }
    owners = ["099720109477"]
}

resource "aws_instance" "management" {
    ami                         = data.aws_ami.ubuntu.id
    instance_type               = "t2.micro"
    subnet_id                   = var.subnet_id_management
    key_name                    = var.key_name
    private_ip                  = var.private_ip
    associate_public_ip_address = true
    vpc_security_group_ids      = [var.security_group_management]

    tags = {
        Name = local.server_name
    }

    provisioner "file" {
        source      = "Core/Canonical/Ubuntu/Management/files/"
        destination = "./"
    }

    provisioner "file" {
        source      = "../../Ansible"
        destination = "./Ansible"
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
        host        = aws_instance.management.public_ip
    }
}

resource "null_resource" "ansible_assets" {
    # Executes only when var.assets_path is defined in the tfvars file
    # to synchronise the assets directory to the management server

    count = var.assets_path != null ? 1 : 0

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
        host        = aws_instance.management.public_ip
    }
}

resource "null_resource" "ansible_executioner" {
    depends_on = [ 
        aws_instance.management,
        null_resource.ansible_assets
     ]

    triggers = {
        ansible_inventory = var.ansible_inventory
        management_server = aws_instance.management.id
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
            "ansible-playbook -i ansible-inventory.yml ./Ansible/site.yml --tags ${var.ansible_tags} -vvvv"
        ]
    }
    
    connection {
        private_key = var.private_key
        user        = "ubuntu"
        host        = aws_instance.management.public_ip
    }
}