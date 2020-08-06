output "server_details" {
  value= {
    "name"      = local.server_name
    "user"      = "ubuntu"
    "public_ip" = aws_instance.management.public_ip
  }
}
