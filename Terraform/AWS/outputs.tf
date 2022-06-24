output "management_server" {
    value = "${module.management_server.details}"
}

output "Lab_Systems" {
    value =  "${module.ansible_inventory.systems}"
}

output "Public_Lab_Systems" {
    value =  "${module.ansible_inventory.Public_Lab_Systems}"
}

output "WARNING" {
    value = {
        "1" = "The AD_CleanUp and Win_CleanUp features reset administrative passwords. If used, please scroll above to Ansible output or '~/<domain>/users/<username>' on the management system. Once reset, further Ansible re-runs will error until you manually update the password in the local ansible inventory."
    }
}

output "Administrative_Credentials" {
    value = {
        "DefaultManagementUsername" = "ubuntu"
        "DefaultManagementKey" = "Check ./SSH-Keys/ locally."
        "DefaultWindowsUsername" = "administrator"
        "DefaultPassword" = random_password.system_password.result
    }
    sensitive = true
}