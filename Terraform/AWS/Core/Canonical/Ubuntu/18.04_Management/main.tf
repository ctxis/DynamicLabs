locals {
  server_name = "${terraform.workspace}-Overlord"
}

data "aws_ami" "ubuntu_bionic" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"]
}

resource "aws_security_group" "management" {
  vpc_id = var.aws_vpc_id
  name   = "${terraform.workspace}-TM"
  ingress {
    from_port   = var.ssh_mgmt_port
    to_port     = var.ssh_mgmt_port
    protocol    = "tcp"
    cidr_blocks = var.attacker_ip
  }
  ingress {
    from_port   = var.nginx_port
    to_port     = var.nginx_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "management" {
  ami                     = data.aws_ami.ubuntu_bionic.id
  instance_type           = "t2.micro"
  subnet_id               = var.aws_subnet_ids[var.network_id]
  key_name                = var.aws_key_name
  private_ip              = var.private_ip
  vpc_security_group_ids  = [aws_security_group.management.id]
  tags = {
    Name = local.server_name
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
    host        = aws_instance.management.public_ip
  }
}
