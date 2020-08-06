# Local SSH Key Module

This Terraform module creates a RSA 4096 bit TLS key that can be used for SSH connections.

It drops it in the working directory with the provided ```key_name``` and sets file permissions to ```600```.

This module effectively wraps around [tls_private_key](https://www.terraform.io/docs/providers/tls/r/private_key.html)

## Usage

```terraform
module "admin-sshkey" {
  source = "./Terraform/local/sshkey-module"
  key_name = "12345_rtadmin_UserX"
}
```
