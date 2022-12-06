locals {
    features = distinct(flatten([
        for system in var.systems: [
            for feature in system.features:
                feature.name
            ]
        ]))

    microsoft_windows_server_systems = [
        for system in var.systems : merge(
                system,
                {
                    "name" = system["hostname"] != null ? "${system["hostname"]}" : (length(terraform.workspace) < 7 ? "${terraform.workspace}${system["class"]}${system["network_id"]}${system["id"]}" : "${substr(terraform.workspace,0,4)}${substr(terraform.workspace,-2,-1)}${system["class"]}${system["network_id"]}${system["id"]}"),
                    "features" = "${system["features"]}",
                }
            )
        if system["module"] == "microsoft_windows_server"
    ]

    microsoft_windows_server_map = {
        for system in local.microsoft_windows_server_systems :
            "${system["name"]}" => system
    }

    microsoft_windows_desktop_systems = [
        for system in var.systems : merge(
                system,
                {
                    "name" = system["hostname"] != null ? "${system["hostname"]}" : (length(terraform.workspace) < 7 ? "${terraform.workspace}${system["class"]}${system["network_id"]}${system["id"]}" : "${substr(terraform.workspace,0,4)}${substr(terraform.workspace,-2,-1)}${system["class"]}${system["network_id"]}${system["id"]}"),
                    "features" = "${system["features"]}",
                }
            )
        if system["module"] == "microsoft_windows_desktop"
    ]

    microsoft_windows_desktop_map = {
        for system in local.microsoft_windows_desktop_systems :
            "${system["name"]}" => system
    }

    canonical_ubuntu_server_systems = [
        for system in var.systems : merge(
                system,
                {
                    "name" = system["hostname"] != null ? "${system["hostname"]}" : (length(terraform.workspace) < 7 ? "${terraform.workspace}${system["class"]}${system["network_id"]}${system["id"]}" : "${substr(terraform.workspace,0,4)}${substr(terraform.workspace,-2,-1)}${system["class"]}${system["network_id"]}${system["id"]}"),
                    "features" = "${system["features"]}",
                }
            )
        if system["module"] == "canonical_ubuntu_server"
    ]

    canonical_ubuntu_server_map = {
        for system in local.canonical_ubuntu_server_systems :
            "${system["name"]}" => system
    }

    offensivesecurity_kalilinux_systems = [
        for system in var.systems : merge(
                system,
                {
                    "name" = system["hostname"] != null ? "${system["hostname"]}" : (length(terraform.workspace) < 7 ? "${terraform.workspace}${system["class"]}${system["network_id"]}${system["id"]}" : "${substr(terraform.workspace,0,4)}${substr(terraform.workspace,-2,-1)}${system["class"]}${system["network_id"]}${system["id"]}"),
                    "features" = "${system["features"]}",
                }
            )
        if system["module"] == "offensivesecurity_kalilinux"
    ]

    offensivesecurity_kalilinux_map = {
        for system in local.offensivesecurity_kalilinux_systems :
            "${system["name"]}" => system
    }
}
