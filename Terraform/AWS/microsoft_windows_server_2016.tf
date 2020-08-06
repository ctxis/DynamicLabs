module "windows_server_2016" {
    source        = "./Microsoft/Windows/Server_2016"
    region        = var.AWS_REGION
    systems_map   = module.dynamic_scaler.microsoft_windows_server_2016_map
    network_tiers = module.network.network_tiers
    attacker_ip   = var.attacker_ip
    subnet_ids    = module.network.subnet_ids
    aws_vpc_id    = module.network.lab_vpc_id 
}