output "management_server" {
    value="${module.management_server.server_details}"
}
output "win_server_2016" {
    value="${module.windows_server_2016.public_systems}"
}