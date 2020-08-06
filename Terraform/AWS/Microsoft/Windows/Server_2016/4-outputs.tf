output "system_details" {
  description = "List of public IP addresses assigned to the instances, if applicable"
  value = [ for system in var.systems_map : {
      "name"      = system["name"]
      "public_ip" = aws_instance.windows_server["${system["name"]}"].public_ip == null ? null : aws_instance.windows_server["${system["name"]}"].public_ip
      "private_ip" = aws_instance.windows_server["${system["name"]}"].public_ip == null ? null : aws_instance.windows_server["${system["name"]}"].private_ip
    }
  ]
}
output "public_systems" {
    description = "List publicly accessible systems."
    value = [for system in var.systems_map: {
        "name"      = system["name"]
        "public_ip" = aws_instance.windows_server["${system["name"]}"].public_ip == null ? null : aws_instance.windows_server["${system["name"]}"].public_ip
        "private_ip" = aws_instance.windows_server["${system["name"]}"].public_ip == null ? null : aws_instance.windows_server["${system["name"]}"].private_ip
        "Default username" = "alfa\\candidate"
        "Default password" = "alfa_ChangeMe!"
      } if contains(system["features"], "candidate")]
}