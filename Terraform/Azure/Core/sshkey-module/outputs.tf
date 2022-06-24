output "private_key" {
  description = "A string of the TLS private key data in PEM format"
  value       = tls_private_key.private_key.private_key_pem
}

output "public_key" {
  description = "A string of the TLS public key data in OpenSSH authorized_keys format"
  value       = tls_private_key.private_key.public_key_openssh
}

output "private_key_path" {
        description = "Path to the TLS private key file"
    value       = "../../SSH-Keys/${var.key_name}_key.pem"
}

output "public_key_path" {
    description = "Path to the TLS public key file"
    value       = "../../SSH-Keys/${var.key_name}_key.pub"
}