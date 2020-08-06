module "kali" {
    source              = "./OffensiveSecurity/KaliLinux"
    network_tiers       = module.network.network_tiers
    attacker_ip         = var.attacker_ip
    systems_map         = module.dynamic_scaler.offensivesecurity_kalilinux_map
    candidate_key_name  = "${terraform.workspace}_candidate"
    subnet_ids          = module.network.subnet_ids
    aws_vpc_id          = module.network.lab_vpc_id
    private_key         = "${file("./SSH-Keys/${var.private_key_file_management}")}"
}