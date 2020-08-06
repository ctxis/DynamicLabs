resource "tls_private_key" "private_key" {
  algorithm = "RSA"
  rsa_bits  = "4096"
}

resource "local_file" "private_key" {
  sensitive_content = tls_private_key.private_key.private_key_pem
  filename          = "${path.cwd}/${var.key_name}_key.pem"
  provisioner "local-exec" {
    command = "chmod 600 '${path.cwd}/${var.key_name}_key.pem'"
  }
}

resource "local_file" "public_key_openssh" {
  sensitive_content = tls_private_key.private_key.public_key_openssh
  filename          = "${path.cwd}/${var.key_name}_key.pub"
}

