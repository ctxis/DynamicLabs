module "windows_server_2016" {
    source              = "../Azure/Microsoft/Windows/Server_2016"
    location            = azurerm_resource_group.resource_group.location
    resource_group_name = azurerm_resource_group.resource_group.name
    systems_map         = module.dynamic_scaler.microsoft_windows_server_2016_map
    network_tiers       = module.network.network_tiers
    attacker_ip         = var.attacker_ip
    subnet_ids          = module.network.subnet_ids
}