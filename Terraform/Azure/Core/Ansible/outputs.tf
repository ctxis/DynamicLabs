output "systems" {
    value = [for system in var.system_details: {
        "name"      = system.name
        "private_ip" = system.private_ip == null ? null : system.private_ip
    }]
}

output "Public_Lab_Systems" {
    value = [for system in var.system_details: {
        "name"      = system.name
        "public_ip" = system.public_ip == null ? null : system.public_ip
        "private_ip" = system.private_ip == null ? null : system.private_ip
    } if system.public_ip != null ]
}

output "ansible_inventory_yml" {
    value = local_file.AnsibleInventory.content
}