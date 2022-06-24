output "management_server" {
    value = "${module.management_server.details}"
}

output "Lab_Systems" {
    value =  "${module.ansible_inventory.systems}"
}

output "WARNINGS" {
    value = {
        "1" = "If a public IP is blank, run terraform -chdir='./Terraform/Azure' show output",
        "2" = "The clean up features reset default password. If used, scroll above to Ansible output or '~/<domain>/users/<username>' on the management system."
    }
}

output "Public_Lab_Systems" {
    value =  "${module.ansible_inventory.Public_Lab_Systems}"
}

output "Administrative_Credentials" {
    value = {
        "DefaultManagementUsername" = "ubuntu"
        "DefaultManagementKey" = "Check ./SSH-Keys/ locally."
        "DefaultWindowsUsername" = "ansible"
        "DefaultPassword" = random_password.system_password.result
    }
    sensitive = true
}