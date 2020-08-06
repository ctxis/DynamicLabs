###################################################################################################
# Outputs
####################################################################################################

output "system_details" {
  description = "List of public IP addresses assigned to the instances, if applicable"
  value = [ for system in var.systems_map : {
      "name"      = system["name"]
      "public_ip" = azurerm_public_ip.windows_server_2016[system["name"]].ip_address == null ? null : azurerm_public_ip.windows_server_2016[system["name"]].ip_address
      "private_ip" = azurerm_public_ip.windows_server_2016[system["name"]].ip_address == null ? null : azurerm_network_interface.windows_server_2016[system["name"]].private_ip_address
    }
  ]
}
output "public_systems" {
    description = "List publicly accessible systems."
    value = [for system in var.systems_map: {
        "name"      = system["name"]
        "public_ip" = azurerm_public_ip.windows_server_2016[system["name"]].ip_address == null ? null : azurerm_public_ip.windows_server_2016[system["name"]].ip_address
        "private_ip" = azurerm_public_ip.windows_server_2016[system["name"]].ip_address == null ? null : azurerm_network_interface.windows_server_2016[system["name"]].private_ip_address
        "Default username" = "alfa\\candidate"
        "Default password" = "alfa_ChangeMe!"
      } if contains(system["features"], "candidate")]
}