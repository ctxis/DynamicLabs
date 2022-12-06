# Dynamic Labs - Lab Deployment
## Quick Start

At a high level, deploying a lab environment involves the following steps:

1. Setup the environment:
   * Download Dynamic Labs
   * Download and setup the required software for your OS, such as Terraform and the AWS or Azure CLI
1. Choose a lab template to deploy
1. Satisfy the prerequisites (if any) for the chosen lab template, such as accepting the Terms and Conditions for specific VM images and ensuring cloud quotas are sufficient for the deployment.
1. Deploy the lab environment from template

Once finished, the lab environment can be destroyed.

## Prerequisites

### Environment setup

Dynamic Labs has been tested on both Linux and Windows. It's likely to work on other platforms such as Mac OS X, but this has not been tested.

1. Download the project from https://github.com/ctxis/DynamicLabs.
1. Download the latest version of Terraform for your platform from https://www.terraform.io/downloads (as a package or as a binary). (Last tested on v1.3.2)
1. (Optional) Install Terraform into your system path or /bin appropriately.
1. Depending on the cloud plaform of choice, install the [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) or the [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli)
1. Choose a lab template to deploy (from the [Templates](Templates) directory). For example, Alfa is a basic template that conists of an AD setup with basic weaknesses like Kerberoasting and MSA abuse.

### Terms and Conditions for specific images
When using lab templates that include images from AWS or Azure Marketplace, such as Kali Linux, accept their respective terms and conditions.

For example, for Kali Linux instances, accept the terms and conditions at:

* AWS - https://aws.amazon.com/marketplace/pp?sku=7lgvy7mt78lgoi4lant0znp5h
* Azure - https://azuremarketplace.microsoft.com/en-us/marketplace/apps/kali-linux.kali

### Cloud Usage Quotas
Although most lab templates fit within the default service quotas for AWS and Azure, when using large lab templates, service quotas might not be sufficient for the deployment of all hosts and might need increasing.

For example, to accomodate for large templates on Azure, it's recommended to adjust the vCPU limits for the Azure subscription as described below:

1. Select ``Subscription``
1. Select the subscription in use
1. Select ``Usage + quotas``
1. Request an increase of the ``Standard BS Family vCPUs`` (templates generally use VMs from the BS-series)
1. Request an increase of the ``Total Regional vCPUs`` (templates generally use VMs from the BS-series)

Taking into account the current large templates, it's recommended to set the limit no lower than 32 vCPUs for both the standard and regional values. 50 will provide some contingency to cater for changes to the templates.

For AWS refer to the official documentation at https://docs.aws.amazon.com/general/latest/gr/aws_service_limits.html

## AWS Deployment

1. Ensure that your current directory is set to dynamic labs.
1. Change directory to the AWS terraform section.

   ```cd Terraform/AWS```

1. To keep things nice and tidy, create a new terraform workspace. The workspace name is used to name cloud resources and avoid conflicts. It's recommended to use a short workspace up to 6 characters, for example 'Lab1').

   ```terraform workspace new <name>```

1. Initiate Terraform modules.

   ```terraform init```

1. Clone the desired template ``.example`` file to a ``.tfvars`` file, e.g:

   ```cp ../../Templates/demos/simple-AD/terraform-AWS.tfvars.example ../../Templates/demos/simple-AD/terraform-AWS.tfvars```

1. Edit the ``.tfvars`` file and fill:
   * the AWS connection details in the "Credentials" section
   * your **source network ranges** in the ``candidate_ip`` variable - this is required to restrict access to the lab. Only the defined IP ranges will be able to successfully deploy and connect to the lab. Please use a restrictive IP Range to prevent unauthorised access to the labs!
1. Begin deployment via Terraform with the following command:

   ```terraform apply -var-file="../../Templates/<type>/<name>/terraform-aws.tfvars"```

   For example:

   ```terraform apply -var-file="../../Templates/demos/simple-AD/terraform-aws.tfvars"```

1. Deployment should take 10-30 minutes to complete depending on the specific template chosen. In case of errors, try rerunning the "apply" command.

See [Accessing a deployed lab environment](#accessing-a-deployed-lab-environment) to start using a successfully deployed environment.

To destroy the lab:
1. Use the terraform destroy command:

   ```terraform destroy -var-file="../../Templates/<type>/<name>/terraform-aws.tfvars"```

   For example:

   ```terraform destroy -var-file="../../Templates/demos/simple-AD/terraform-aws.tfvars"```

## Azure Deployment

1. Ensure that your current directory is set to dynamic labs.
1. Change directory to the Azure terraform section.

   ```cd Terraform/Azure```

1. To keep things nice and tidy, create a new terraform workspace. The workspace name is used to name cloud resources and avoid conflicts. It's recommended to use a short workspace up to 6 characters, for example 'Lab1').

   ```terraform workspace new <name>```

1. Initiate Terraform modules.

   ```terraform init```

1. Clone the desired template's example file, e.g:

   ```cp ../../Templates/demos/simple-AD/terraform-azure.tfvars.example ../../Templates/demos/simple-AD/terraform-azure.tfvars```

1. Edit the ``.tfvars`` file and fill your **source network ranges** in the ``candidate_ip`` variable - this is required to restrict access to the lab. Only the defined IP ranges will be able to successfully deploy and connect to the lab. Please use a restrictive IP Range to prevent unauthorised access to the labs!

1. Authenticate into Azure using the command:

   ```az login```

1. Begin deployment via Terraform with the following command.

   ```terraform apply -var-file="../../Templates/<type>/<name>/terraform-azure.tfvars"```

   For example:

   ```terraform apply -var-file="../../Templates/demos/simple-AD/terraform-azure.tfvars"```

1. Deployment should take 20-40 minutes to complete depending on the specific template chosen. If you see any output errors try rerunning the "apply" command.

See [Accessing a deployed lab environment](#accessing-a-deployed-lab-environment) to start using a successfully deployed environment.

To destroy the lab:
1. Use the terraform destroy command:

   ```terraform destroy -var-file="../../Templates/<type>/<name>/terraform-azure.tfvars"```

   For example:

   ```E.g. terraform destroy -var-file="../../Templates/demos/simple-AD/terraform-azure.tfvars"```

Sometimes, when using Azure the destroy command doesn't complete successfully and not all resources are destroyed. To manually delete all resources it is sufficient to delete (via the Azure Portal) the resource group with the same name as the terraform workspace.


## Accessing a deployed lab environment

Once the lab environment is deployed, you can SSH or RDP to one of the public machines, to start using the environment. Each lab template should provide one initial access entry point. The template documentation and the terraform output contain the details for the deployed lab.