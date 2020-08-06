variable "systems" {
    type = list(object({
        module=string,
        size=string,
        network_id=string,
        private_ip=string,
        class=string,
        id=string,
        features=list(string),
        attributes=list(object({
            name=string,
            value=list(object({
                name=string,
                value=string
            }))
        }))
    }))
    default = [{
        module      = "microsoft_windows_server_2016"
        size        = "t2.small"
        network_id  = "001"
        private_ip  = null
        class       = "DC"
        id          = "001"
        features    = []
        attributes  = []
    }]
}