resource "tls_private_key" "private_key" {
  algorithm = "RSA"
  rsa_bits  = "4096"
}

resource "local_sensitive_file" "private_key" {
    content = tls_private_key.private_key.private_key_pem
    filename          = "../../SSH-Keys/${var.key_name}_key.pem"
}

resource "local_sensitive_file" "public_key_openssh" {
    content = tls_private_key.private_key.public_key_openssh
    filename          = "../../SSH-Keys/${var.key_name}_key.pub"
}