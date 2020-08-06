output "server_details" {
  value= {
    "name"      = local.server_name
    "user"      = "ubuntu"
    "public_ip" = azurerm_public_ip.management.ip_address
  }
}