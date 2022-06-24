**WARNING: This project spins up intentionally vulnerable systems. Users spinning up their own labs using this code risk exposure at their own risk. After deployment, please test that the lab is not Internet-exposed.**

# DynamicLabs
v0.99 (beta)

## Setup
0. Download the project from https://github.com/ctxis/DynamicLabs.
1. Download the latest version of Terraform. (Last tested on v0.15.4)
   Windows: https://releases.hashicorp.com/terraform/0.15.4/terraform_0.15.4_windows_amd64.zip
   Linux: https://releases.hashicorp.com/terraform/0.15.4/terraform_0.15.4_linux_amd64.zip
2. (Optional) Install Terraform into your system path or /bin appropriately.
3. Select what template you want to deploy (from the /Templates directory). Alfa is a basic template that conists of an AD setup with basic weaknesses like Kerberoasting and MSA abuse.


## AWS Deployment
0. Ensure that your current directory is set to dynamic labs.
1. Create a new terraform workspace. (Use a short workspace name like 'DL1' upto 6 characters).
```terraform -chdir="./Terraform/AWS" workspace new <name>```
2. Initiate Terraform modules.
```terraform -chdir="./Terraform/AWS" init```
3. Clone the desired template's example file. 
```I.e. "./Templates/<type>/<name>/terraform-AWS.tfvars.example" to "./Templates/<type>/<name>/terraform-AWS.tfvars"```
```E.g. "copy ./Templates/demos/simple-AD/terraform-AWS.tfvars.example" to "./Templates/demos/simple-AD/terraform-AWS.tfvars"```
4. Edit the file to add in your AWS connection details and your source network range.
5. Begin deployment.
```I.e. terraform -chdir="./Terraform/AWS" apply -var-file="../../Templates/<type>/<name>/terraform-aws.tfvars"```
```E.g. terraform -chdir="./Terraform/AWS" apply -var-file="../../Templates/demos/simple-AD/terraform-aws.tfvars"```
6. Deployment should take 10-30 minutes to complete depending on the specific template chosen.
7. Once it completes, you can either SSH to Kali for the perspective of an unauthenticated internal network-based attacker, or the candidate system for an authenticated attacker that has compromised a low-privilege user. The Kali system uses the "ec2-user" and the candidate private SSH key. The Windows candidate system's credentials will be shown in Terraform output.

## Azure Deployment
0. Download and install Azure CLI (https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-windows?tabs=azure-cli).
1. Type "az login" and authenticate into Azure.
2. Ensure that your current directory is set to dynamic labs.
3. Create a new terraform workspace. (Use a short workspace name like 'DL1' upto 6 characters).
```terraform -chdir="./Terraform/Azure" workspace new <name>```
4. Initiate Terraform modules.
```terraform -chdir="./Terraform/Azure" init```
5. Clone the desired template's example file. 
```I.e. "./Templates/<type>/<name>/terraform-azure.tfvars.example" to "./Templates/<type>/<name>/terraform-azure.tfvars"```
```E.g. "copy ./Templates/demos/simple-AD/terraform-azure.tfvars.example" to "./Templates/demos/simple-AD/terraform-azure.tfvars"```
6. Edit the file to add in your source network range
7. Begin deployment.
```I.e. terraform -chdir="./Terraform/Azure" apply -var-file="../../Templates/<type>/<name>/terraform-azure.tfvars"```
```E.g. terraform -chdir="./Terraform/Azure" apply -var-file="../../Templates/demos/simple-AD/terraform-azure.tfvars"```
8. Deployment should take 20-40 minutes to complete depending on the specific template chosen.
9. Once it completes, you can either SSH to Kali for the perspective of an unauthenticated internal network-based attacker, or the candidate system for an authenticated attacker that has compromised a low-privilege user. The Kali system uses the "ec2-user" and the candidate private SSH key. The Windows candidate system's credentials will be shown in Terraform output.

## Current Contributors
- Rohan Durve (@Decode141)
- David Turco (@endle__)

## Past Contributors
- Alex Bourla
- Dominik Schelle

**WARNING: This project spins up intentionally vulnerable systems. Users spinning up their own labs using this code risk exposure at their own risk. After deployment, please test that the lab is not Internet-exposed.**