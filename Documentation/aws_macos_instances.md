# Using macOS instances with AWS

## Costs

MacOS instances use dedicated hosts which are charged for a minimum of 24h from allocation.

**MacOS dedicated hosts are expensive!** - Make sure you understand the cost implications. Dedicated hosts are charged while allocated, even if no instances are run on it.

## Allocate a dedicated host

For DynamicLabs to launch macOS instances, an available dedicated host must be allocated in the AWS account/region.

If you receive an error like the following, then no allocated instances are available:

```
│ Error: creating EC2 Instance: InsufficientHostCapacity: You do not have a host with a matching configuration and sufficient capacity. Either target a host resource group that can automatically allocate hosts on your behalf, or manually allocate a new host to your account and then try again.
│ 	status code: 400, request id: 826810a4-e6ba-4704-874d-xxxxxxxxxxxx
│ 
│   with module.macos_arm64.aws_instance.macos_arm64["macGS101"],
│   on Apple/macOS_arm64/instance.tf line 53, in resource "aws_instance" "macos_arm64":
│   53: resource "aws_instance" "macos_arm64" {
│ 
╵
```

If the dedicated host is not in an "Available" state, you might receive the following error message:

```
│ Error: creating EC2 Instance: InsufficientCapacityOnHost: Dedicated host h-xxxxxxxxxx has insufficient capacity to launch the instances in this request.
│ 	status code: 400, request id: 490a8256-77d4-4cd7-80ad-xxxxxxxxxxxx
│ 
│   with module.macos_arm64.aws_instance.macos_arm64["macGS101"],
│   on Apple/macOS_arm64/instance.tf line 53, in resource "aws_instance" "macos_arm64":
│   53: resource "aws_instance" "macos_arm64" {

```

This can happen after an instance is destroyed due to the background tasks happening on the host as described here https://aws.amazon.com/blogs/compute/understanding-the-lifecycle-of-amazon-ec2-dedicated-hosts/.
In this case **it can take up to 50 minutes for the host to be available again**. In the AWS console the state will show as `pending`.

The dedicated host id for MacOS system instances needs to be passed to Dynamic Labs in the lab template as the option "dedicated_host_id".

Note that when deploying the template, **MacOS instances can take several minutes before they are deployed**. This can be monitored in the AWS console. The state of the EC2 instances will be `initializing``. Wait for the state to be running and the re-run the Dynamic Labs deployment step.

### Using AWS console

To allocate a MacOS dedicated host using the AWS console follow the steps below:

1. Ensure that the region matches the region in the template (e.g. eu-west-1)
1. Allocate a dedicated host:
   1. Navigate to EC2 > Dedicated Hosts
   1. Select Allocate Dedicated Hosts
   1. Use the following options:
      * `Name tag` - choose a name
      * `Instance family` - mac2 for arm64 and mac1 for x86_64
      * `Instance type` - mac2.metal or mac1.metal depending on the instance familiy 
      * `Availability Zone` - any
      * `Instance auto-placement` - Enabled
      * `Host maintenance` - Disabled
      * `Quantity` - as needed by your lab template
   1. Select Allocate

Make note of the "Host Id" value.

### Using AWS cli 

Alternatively you can use the AWS cli to allocate a MacOS dedicated host.

For example with the following command:

```
aws ec2 allocate-hosts \
--instance-type mac2.metal \
--availability-zone eu-west-1a --auto-placement on \
--quantity 1 --region eu-west-1
```

Ensure that:
* the selected region matches the region in the lab template
* the instance type matches the architecture of the systems defined in the lab template (mac2.metal for arm64 and mac1.metal for x86_64)

## Declaring a MacOS host

The MacOS host can be added as a system in the lab template.

The option `dedicated_host_id` **must be specified** for MacOS instances.
Currently AWS "Auto Placement" doesn't seem to work with Terraform and an explicit value must be specified.

```
systems = [

[...]

    {
        module            = "apple_macos_arm64"
        os_version        = "ventura"
        size              = "mac2.metal"
        network_id        = "1"
        hostname          = null
        private_ip        = null
        public_ip         = true
        class             = "MC"
        id                = "01"
        dedicated_host_id = "h-xxxxxxxxxxxxxxxxx"
        features          = [
            {
                name = "AD_Join_MacOS"
                value = [
                    {name = "domain_name", value = "dynamic.lab"},
                    {name = "domain_dns_server", value = "10.1.1.10"},
                ]
            },
            {
                name = "MacOS_User"
                value = [
                    { name = "macadmin", 
                      password = "ApfelStrudelWithRaisins123",
                      groups = "admin" }
                ]
            },
            {
                name = "MacOS_Authorized_Keys"
                value = [
                    { 
                       user = "macadmin",
                       type = "asset",
                       key_path = "macadmin_id_rsa.pub"
                    }
                ]
            },
            {
                name = "MacOS_Remote_Desktop",
                value = [ ]
            }
        ]
    }
]

```

### Connecting to a MacOS Host

When a MacOS host is deployed in a "candidate" network, only SSH is exposed to the candidate IP ranges. Apple Remote Desktop (VNC on port 5900) is not.
To connect to a MacOS host via Apple Remote Desktop (when enabled with the `MacOS_Remote_Desktop` feature), use SSH to the host itself or to the management server to redirect port 5900, e.g.:

```
# SSH to the management server public IP at x.x.x.x and redirect port 5900 from macOS host with internal IP y.y.y.y
ssh -i management_key.pem ubuntu@x.x.x.x -L5900:y.y.y.y:5900

# SSH directly to macOS host public IP z.z.z.z and redirect local port 5900
ssh -i macuser_key.pem macuser@z.z.z.z -L5900:localhost:5900
```

Then connect to localhost port 5900 using a VNC client compatible with Apple Remote Desktop, such as [RealVNC Viewer](https://www.realvnc.com/).





