variable "systems" {
    type = list(object({
        module=string,
        os_version=string,
        size=string,
        dedicated_host_id=optional(string),
        network_id=string,
        hostname=string,
        private_ip=string,
        public_ip=bool,
        class=string,
        id=string,
        features=list(object({
            name=string,
            value=list(map(string))
        }))
    }))
    default = [{
        module      = "microsoft_windows_server"
        os_version  = "2022"
        size        = "t2.small"
        network_id  = "1"
        hostname    = null
        private_ip  = null
        public_ip   = false
        class       = "DC"
        id          = "001"
        features    = []
    }]
}