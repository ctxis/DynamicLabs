variable resource_group_name {}
variable location {}
variable address_space {
    type = list(string)
}

variable "networks"{
  type = list(object({network_id=string, network_tier=string,network_name=string,address_space=list(string),public_ip=bool}))
  default = [
    {
      network_id    = "001"
      network_tier  = "T0"
      network_name  = "Management_Net"
      address_space = ["10.1.1.0/24"]
      public_ip     = false
    }
  ]
}