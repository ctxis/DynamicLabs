# DynamicLabs
v0.1 (alpha) (AWS Only Release)

WARNING: This project involves spinning up intentionally vulnerable systems. Users spinning up their own labs using this code risk exposure at their own risk.

## Setup
0. Download the project from https://github.com/ctxis/DynamicLabs.
1. Download Terraform v0.12 (https://releases.hashicorp.com/terraform/0.12.28/terraform_0.12.28_windows_amd64.zip).
2. Install Terraform into your system path or /bin appropriately.
3. Also, copy the Terraform Linux x64 binary to "~/dynamic-labs/Terraform/AWS/Core/Canonical/Ubuntu/18.04_Management/files" or "~/dynamic-labs/Terraform/Azure/Core/Canonical/Ubuntu/18.04_Management/files/".
4. Generate a pair of SSH keys and place them into "~/dynamic-labs/SSH-Keys/". Ensure that other users cannot read your SSH key.
5. Download a 3rd party provider for dynamic Ansible inventory generation from https://github.com/nbering/terraform-provider-ansible/releases/tag/v1.0.3. Place the binary into "%APPDATA%\terraform.d\plugins" on Windows or "~/.terraform.d/plugins" on Linux. E.g. AppData\Roaming\terraform.d\plugins\windows_amd64\terraform-provider-ansible_v1.0.3.exe

## Deployment Instructions for AWS
1. Ensure that your current directory is set to dynamic labs.
2. Create a new terraform workspace.
```terraform workspace new <name>```
3. Initiate Terraform modules.
```terraform init ./Terraform/AWS/```
4. Copy "./Templates/<type>/<name>/terrfaorm-AWS.tfvars.example" to "./Templates/<type>/<name>/terrfaorm-AWS.tfvars"
5. Edit the new file to add in your Azure connection details, your network range and SSH key names.
6. Begin deployment.
```terraform apply -auto-approve -var-file="./Templates/<type>/<name>/terraform-aws.tfvars" ./Terraform/AWS/```
7. Send over the Terraform state file to your management server.
```scp -r -i ./SSH-Keys/<mgmnt_key> ./terraform.tfstate.d/<workspace name>/terraform.tfstate ubuntu@<mgmnt_box_ip>:~/```
8. SSH onto the management server and kick-off resource configuration.
```
ssh -i ./SSH-Keys/<mgmnt_key> ubuntu@<mgmnt_box_ip>
#> ansible-playbook -i /etc/ansible/terraform.py ./Ansible/site.yml -vvvv
```

## Deployment Instructions for Azure
Will be updated over the weekend.

## Contributors
- Alex Bourla
- Rohan Durve (@Decode141)
- Dominik Schelle
