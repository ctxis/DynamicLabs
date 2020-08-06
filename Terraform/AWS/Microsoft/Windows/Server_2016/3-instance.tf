data "template_file" "base_config"{
  template = <<EOF
        <powershell>
        $admin = [adsi]("WinNT://./${var.system_user}, user")
        $admin.PSBase.Invoke("SetPassword", "${var.system_password}")
        $url =  "http://10.1.254.10:10080/ConfigureRemotingForAnsible.ps1"
        $file = "$env:temp\ConfigureRemotingForAnsible.ps1"
        Do {
              try {
                  (New-Object -TypeName System.Net.WebClient).DownloadFile($url, $file)
              } catch [System.Net.WebException],[System.IO.IOException] { continue }
              Start-Sleep -Seconds 1
          } While ((Test-Path $file) -eq $False)
        if (Test-Path $file) {
          powershell.exe -ExecutionPolicy ByPass -File $file -DisableBasicAuth
        }
        </powershell>
    EOF
}

resource "aws_instance" "windows_server" {
    for_each = var.systems_map
    ami                       = var.ami_map[var.region]
    instance_type             = each.value["size"]
    private_ip                = each.value["private_ip"] == null ? null : each.value["private_ip"]
    subnet_id                 = var.subnet_ids[each.value["network_id"]]
    vpc_security_group_ids    = ["${aws_security_group.default_ports.id}"]
    tags  = {
        Name = each.value["name"]
    }
    user_data                 = data.template_file.base_config.rendered
}

resource "ansible_host" "windows_server" {
    for_each = var.systems_map
    inventory_hostname = aws_instance.windows_server[each.value["name"]].private_ip
    groups = concat(each.value["features"])
    vars = {
        ansible_connection = "winrm"
        ansible_port = 5986
        ansible_winrm_transport = "ntlm"
        ansible_winrm_server_cert_validation = "ignore"
        ansible_user = var.system_user
        ansible_password = var.system_password
        custom_hostname = each.value["name"]
        attributes = jsonencode(each.value["attributes"])
    }
}