# Standalone MacOS

The standalone-macos lab template deploys a single MacOS instance.

MacOS instances are available only in AWS and manual steps are required before deploying the template:

* A dedicated mac-os instance must be manually created in AWS
* The lab template needs to be updated with the host id of the dedicated instance (dedicated_host_id parameter)

Before using this lab template make sure you read the information at [Using macOS instances with AWS](../../../Documentation/aws_macos_instances.md).

# Accessing the hosts

The macos host can be accessed via SSH with the private keys provided.

Apple Remote Desktop is accessible by forwarding port 5900 via SSH, for example with the following command:

```
ssh -i assets/lowpriv_id_rsa lowpriv@x.x.x.x -L5900:localhost:5900
```

Then a VNC client compatible with Apple Remote Desktop, such as [RealVNC Viewer](https://www.realvnc.com/), can be used to connect to the local port 5900.

Credentials for local users are defined in the lab template.