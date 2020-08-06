locals {
    microsoft_windows_server_2016_systems = [
        for system in var.systems : merge(
                system,
                {
                    "name" = "${terraform.workspace}-${system["network_id"]}${system["class"]}${system["id"]}",
                    "features" = "${system["features"]}",
                    "attributes" = "${system["attributes"]}",
                }
            )
        if system["module"] == "microsoft_windows_server_2016"
    ]

    microsoft_windows_server_2016_map = {
        for system in local.microsoft_windows_server_2016_systems :
            "${system["name"]}" => system
    }

    offensivesecurity_kalilinux_systems = [
        for system in var.systems : merge(
                system,
                {
                    "name" = "${terraform.workspace}-${system["network_id"]}${system["class"]}${system["id"]}",
                    "features" = "${system["features"]}",
                    "attributes" = "${system["attributes"]}",
                }
            )
        if system["module"] == "offensivesecurity_kalilinux"
    ]

    offensivesecurity_kalilinux_map = {
        for system in local.offensivesecurity_kalilinux_systems :
            "${system["name"]}" => system
    }
}