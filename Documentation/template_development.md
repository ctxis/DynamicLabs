# Quick start

The easiest way to get started with the development of a lab template is to copy an existing template, such as the [simple-AD](../Templates/demos/simple-AD/) lab template, and to adapt it to the specific use case.

Templates have the following sections:

* [**Credentials**](#credentials-aws-templates-only) - cloud account credentials, depending on the cloud platform
* [**Attacker IP Ranges**](#attacker-ip-ranges) - restricting access to the lab systems
* [**Networking**](#networking) - defining the network segments of a lab
* [**Systems**](#systems) - defining the hosts and their configuration

# Credentials (AWS templates only)

AWS templates include the following user configurable variables at the top to fill with the AWS access key and secret:

```
############ / AWS Credentials
AWS_ACCESS_KEY          = ""
AWS_SECRET_KEY          = ""
AWS_REGION              = "eu-west-2"
```

Azure templates do not include configurable credentials as login is performed beforehand via the Azure CLI (see [Lab Deployment](lab_deployment.md)).

# Attacker IP Ranges

Access to the systems deployed by Dynamic Labs is restricted by IP addess. The Attacker IP range is used to restric access to both the management server and to the servers in the "candidate" network.

Every template has the following section where the attacker IP ranges are defined:

```
############ / Attacker IP Range
# Permitted to SSH and RDP to management network (ID 0) and candidate network (ID 1).
candidate_ip = ["XXX.XXX.XXX.XXX/XX"] # Replace with your IP.
```

> **WARNING**: Use a restrictive IP Range to prevent unauthorised access to the labs. Remember that the templates deploy intentonally vulnerable systems!

For example, specify a single IP address with:

```
candidate_ip = ["93.184.216.34/32"]
```

# Networking

The networking section defines the network segments where the lab systems will be placed.

For example, the following network configuration can be used for most labs:

```
address_space_lab         = "10.1.0.0/16"
address_space_management  = "10.1.254.0/24"

networks = [
    {
        network_id    = "1"
        network_name  = "INTERNAL"
        network_template = "internal_permissive"
        address_space = "10.1.1.0/24"
    },    
    {
        # Exposes RDP and SSH ports to the candidate IP ranges
        network_id    = "2"
        network_name  = "CANDIDATE_EXTERNAL"
        network_template = "candidate"
        address_space = "10.1.2.0/24"
    }
]

security_rules = []
```

First, two address spaces are defined:

* ``address_space_lab`` - is the overall address space for **ALL** lab networks, including the management network.
* ``address_space_management`` - is the address range where the management system is deployed. This must be included in the overall ``address_space_lab``.

Then the lab network segments are defined. Each network must include the following attributes:

* ``network_id`` - the network identifier. Must be unique.
* ``network_name`` - a user friendly network name
* ``network_template`` - defines the type of network between ``candidate``, ``internal_permissive``, ``internal_segregated``. See the [Network Templates](#network-templates) section below for the description of each network template.
* ``address_space`` - the address range for the network segment. This must be included in the overall lab range defined in ``address_space_lab``.

``security_rules`` are usually required only to model complex lab environments and their usage is described in the [Custom Security Network Rules](#custom-network-security-rules) section.

## Network templates

Network templates define a set of default network rules to be applied to the defined network segment and all systems included. 

The following network templates are implemented:

* ``candidate`` - The systems in candidate networks are reachable on ports 22 (SSH) and 3389 (RDP) from the Internet from the IP ranges defined in the ``candidate_ip`` variable (see [Attacker IP Ranges](#attacker-ip-ranges)). All labs should have a candidate network as an entry point to the lab.
* ``internal_permissive`` - Systems in the internal permissive networks are allowed inbound connections from all lab networks. These systems are **NOT** exposed to the Internet. Most simple labs use internal_permissive networks.
* ``internal_segregated`` - Systems in the internal segregated network are allowed inbound connections only from the systems in the same network segment. All other inbound connections are denied. Internal segregated networks are useful, for example, when creating a complex lab that includes a DMZ, a corporate internal network, and a payment systems internal network. All allowed inbound communications for each network will need to be explicitely defined using [Custom Network Security Rules](#custom-network-security-rules).

All network templates allow outbound Internet access, as several [System Features](#system-features) download and install the required software dependencies from the Internet.


[TODO: list available templates with a descrption and example use case]

## Custom Network Security rules

> NOTE: this feature is in "alpha" state and syntax changes are expected in future releases.

When [network templates](#network-templates) are not sufficent to model the desired environment, custom network security rules can be defined to allow communication between different systems. Custom network security rules are generally used in conjunction with the network template ``internal_segregated``.

Custom network security rules are required, for example, when modelling a DMZ and and internal network, where the expected attack path is for the candidate to break into a web application exposed from the DMZ and then to pivot from that host to an internal database system.

In the above example we could define the candidate, DMZ and internal networks as follows:

```
address_space =  ["10.0.0.0/8"]

networks = [
    # PARADOX.LAN
    {   
        network_id       = "1"
        network_name     = "DMZ"
        network_template = "internal_segregated"
        address_space    = "10.2.1.0/24"
    },
    # PARADOXDMZ.LAN
    {
        network_id       = "2"
        network_name     = "Internal" 
        network_template = "internal_segregated"
        address_space    = "10.8.3.0/24"
    },
    # Candidate Network (the starting point of the attack path)
    {
        network_id       = "3"
        network_name     = "Candidate"
        network_template = "candidate"
        address_space    = "10.10.10.0/24"
    }
]
```

Let's assume the 3 systems part of the attack path have the following IP addresses:

| System          | Network   | IP          |
|-----------------|-----------|-------------|
| Candidate Host  | Candidate | 10.10.10.10 |      
| Web Server      | DMZ       | 10.2.1.7    |
| Database Server | Internal  | 10.8.3.21   |

> Currently, the syntax for defining network security rules is dependent on the cloud platform. In a future version, the syntax will be simplified and made the same between platforms.

When using Azure, we can define the following two rules:

```
security_rules = [
    {
        network_id                      = 1
        name                            = "Allow HTTP from Candidate Network to Web Server"
        priority                        = 101
        direction                       = "Inbound"
        access                          = "Allow"
        protocol                        = "Tcp"
        source_port_ranges              = ["0-65535"]
        destination_port_ranges         = ["80"]
        source_address_prefixes         = ["10.10.10.0/24"]
        destination_address_prefixes    = ["10.2.1.7"]
    },
    {
        network_id                      = 2
        name                            = "Allow SQL Server port 1433 from Web Server to Database Server"
        priority                        = 103
        direction                       = "Inbound"
        access                          = "Allow"
        protocol                        = "*"
        source_port_ranges              = ["0-65535"]
        destination_port_ranges         = ["1433"]
        source_address_prefixes         = ["10.2.1.7"]
        destination_address_prefixes    = ["10.8.3.21"]
    },
```

Notice how each rule references the ``network_id``. 

When using AWS, we can define the following two rules, which results in a similar outcome despite the currently supported syntax being less flexible than Azure's:

```
security_rules = [
    {
        # Allow HTTP from Candidate Network to DMZ
        network_id          = "1",
        type                = "ingress",
        cidr_blocks         = ["10.10.10.0/24"],
        protocol            = "tcp",
        from_port           = "80",
        to_port             = "80"
    },
    {
        "Allow SQL Server port 1433 from Web Server to Internal Network"
        network_id          = "2",
        type                = "ingress",
        cidr_blocks         = ["10.2.1.7/32"],
        protocol            = "all",
        from_port           = "1433",
        to_port             = "1433"
    }
]
```

# Systems

Once the network layout is defined, we can add systems to each network.

For example:

```
systems = [
    {
        module      = "microsoft_windows_server"
        os_version  = "2022"
        size        = "t2.medium"
        network_id  = "1"
        hostname    = null
        private_ip  = "10.1.1.10"
        public_ip   = false
        class       = "DC"
        id          = "01"
        features    = [ ]
    }
]
```

The attributes are as follows:

* ``module`` - is the reference name for the operating system type to deploy (see table below for the list of supported operating systems)
* ``os_version`` - is the specific version to deploy for the selected operating system type (see table below for the list of supported operating system versions)
* ``size`` - is the size of the VM deployed. This attribute depends on the cloud platform and it is the main contributor to the running cost of a lab. For a list of available sizes refer to:
  * AWS - https://aws.amazon.com/ec2/instance-types/
  * Azure - https://learn.microsoft.com/en-us/azure/virtual-machines/sizes-b-series-burstable
* ``network_id`` - is the ID of the network where to place the system
* ``hostname`` - is the hostname of the system as a string. If set to ``null``, the name is autogenerated.
* ``private_ip`` - is the static IP address to assign to the system. It must be included in the network range associated with the network_id. If set to ``null`` the IP address will be automatically assigned using DHCP. Domain controllers and systems referenced by network security rules should always have a static IP address.
* ``public_ip`` - whether the host should be assigned a public IP address. For the system to be accessible externally, ``public_ip`` needs be set to ``true`` **AND** the system must be placed in a nework with the "candidate" template. Even so, access to the host is **restricted by design** to ports 22 (SSH) and 3389 (RDP) and access is allowed only from the ``candidate_ip`` ranges. This is to avoid inadvertently exposing vulnerable systems to the wider Internet. Generally only one system in a template is associated a public_ip. The system would generally be a Windows or a Kali VM used a starting point for the candidate.
* ``class`` and ``id`` - two arbitrary names to classify systems within a lab template. ``class + id`` must be a unique value for each systems. These are currently used to generate the system name when ``hostname`` is set to ``null``. ``class`` and ``id`` will be removed in a future version of Dynamic Labs.
* ``features`` - define the configuration of a system. This core concept is described in the next section, [System Features](#system-features). ``[ ]`` indicates a system with no features defined.

Notice that when specifying a ``null`` value, ``null`` must not be included in quotes.

When defining systems in Azure templates, the only difference is the specification of the "size" attribute, which uses Azure VM series names instead of AWS instance sizes, e.g.:

```
        size        = "Standard_B2s"
```

The recommended sizes to use in templates to keep the running costs of lab contained are:

* AWS:
  * t2.small (1 vCPU, 2 GB RAM)
  * t2.medium (2 vCPU, 4 GB RAM)
  * t2.large (2 vCPU, 8 GB RAM) - use only when needed
* Azure:
  * Standard_B1ms (1 vCPU, 2 GB RAM)
  * Standard_B2s (2 vCPUs, 4 GB RAM)
  * Standard_B2ms (2 vCPUs, 8 GB RAM) - use only when needed

The following table shows the list of supported Operating Systems for each supported cloud platform.

| Operating System    | Module Name                 | OS Version | AWS | Azure |
|---------------------|-----------------------------|------------|-----|-------|
| Windows Server 2016 | microsoft_windows_server    | 2016       | X   | X     |
| Windows Server 2019 | microsoft_windows_server    | 2019       | X   | X     |
| Windows Server 2022 | microsoft_windows_server    | 2022       | X   | X     |
| Windows 10 (21H2)   | microsoft_windows_desktop   | 10         |     | X     |
| Windows 11 (22H2)   | microsoft_windows_desktop   | 11         |     | X     |
| Ubuntu Server 20.04 | canonical_ubuntu_server     | 20.04      | X   | X     |
| Ubuntu Server 22.04 | canonical_ubuntu_server     | 22.04      | X   | X     |
| Kali Linux (latest) | offensivesecurity_kalilinux | latest     | X   | X     |

## System features

**System features** (also known as just **features**) are used to configure individual systems beyond a vanilla installation of the operating system.

System features are a core concept in Dynamic Labs and they define configuration states for each system, e.g. whether a machine is a domain controller or it's joined to a domain; the definition of system users; whether it hosts a web application or perhaps a database; wheter it's affected by a vulnerability; etc...

The following snippet shows an example on how to configure the domain controller for a new forest using the ``AD_Forest`` feature and two users with the ``AD_User`` feature. The user ``patricia.brown`` is then given ``Domain Admin`` privileges:

```
        features    = [
            {
                name = "AD_Forest"
                value = [
                    {name = "domain_name", value = "dynamic.lab"},
                    {name = "domain_netbios_name", value = "dynamiclab"}
                ]
            },
            {
                name = "AD_User"                
                value = [                
                    { name = "patricia.brown", password = "BestPasswordInTheWorld123!" },
                    { name = "john.doe", password = "SecondBestPasswordInTheWorld?" }
                ]
            },
            {
                name = "AD_Group_Membership"
                value = [
                    {name = "Domain Admins", value = "patricia.brown"}
                ]
            },
        ]
```

The following snippet shows an example on how to join a machine to the above domain:

```
        features    = [
            {
                name = "AD_Join"
                value = [
                    {name = "domain_name", value = "dynamic.lab"},
                    {name = "domain_dns_server", value = "10.1.1.10"},
                ]
            }
        ]
```

> **WARNING**: in a lab template, each feature type can only be specified once per system. If listed multiple times, the last definition will overwrite the previous ones. To specify multiple instances of the same feature type, list all instances in the value section, like it was done for the 2 users for the ``AD_User`` feature in the examples above.


Some features, such as ``Win_Dirtree_Copy`` that copies files from Dynamic Labs source tree to deployed systems, require the definition of an ``assets_path`` where the referenced files are stored. The ``assets_path`` variable can be defined in the template as follows:

```
############ Assets
assets_path = "Templates/<type>/<name>/assets/"
```

For a full list of supported system features and their usage, refer to [List of System Features](system_features.md)

# Debugging

The following are useful variables that you can use during the the development of new templates:

 * `ansible_tags` - Limit Ansible tags to execute. Useful during development to select the execution of a single feature such as `AD_User`
 * `ansible_limit`- Limit Ansible execution to the specified hosts. Useful during development to apply changes to a specific host only, such as `10.1.1.10`

The variables can be specified on the command line or directly inside the tfvars file.

You can specify the variables on the command line as shown below:

```
terraform apply -var-file=../../path/to/template.tfvars -var="ansible_tags=AD_User" -var="ansible_limit=10.1.1.10"
```

You can specify the variables in the tfvars file by adding the following lines:

```
############ / Dev Options
ansible_tags=AD_User
ansible_limit=10.1.1.10
```
Remember to remove or comment out the variables before publishing the Lab template