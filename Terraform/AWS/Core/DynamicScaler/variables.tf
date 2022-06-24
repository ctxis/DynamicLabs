variable "systems" {
    type = list(object({
        module=string,
        size=string,
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
        module      = "microsoft_windows_server_2016"
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