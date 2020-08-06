output "system_details" {
  description = "List of public IP addresses assigned to the instances, if applicable"
  value = [ for system in var.systems_map : {
      "name"      = system["name"]
      "user"      = "ec2-user"
      "public_ip" = aws_instance.kali["${system["name"]}"].public_ip == null ? null : aws_instance.kali["${system["name"]}"].public_ip
    }
  ]
}
