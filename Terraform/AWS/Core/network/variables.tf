variable availability_zone {}
variable address_space_vpc {}
variable address_space_management {}
variable public_ip {
  default = false
}
variable "networks"{
  type = list(object({network_id=string, network_tier=string,network_name=string,address_space=string,public_ip=bool}))
  default = [
    {
      network_id    = "001"
      network_tier  = "T0"
      network_name  = "Management_Net"
      address_space = "10.1.1.0/24"
      public_ip     = false
    }
  ]
}
