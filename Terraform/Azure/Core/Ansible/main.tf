resource "local_file" "AnsibleInventory" {
    content = templatefile("../inventory.tmpl",
        {
            features = var.features
            system_details = var.system_details
        }
    )
    filename = "../../${terraform.workspace}-ansible-inventory.yml"
}