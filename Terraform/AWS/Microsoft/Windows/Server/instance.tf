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
          powershell.exe -ExecutionPolicy ByPass -File $file
        }
      </powershell>
    EOF
}

data "aws_ami" "windows_server_2016" {
    most_recent = true
    owners = ["amazon"]
    filter {
        name   = "name"
        values = ["Windows_Server-2016-English-Full-Base-*"]
    }
    filter {
        name   = "virtualization-type"
        values = ["hvm"]
    }
}

data "aws_ami" "windows_server_2019" {
    most_recent = true
    owners = ["amazon"]
    filter {
        name   = "name"
        values = ["Windows_Server-2019-English-Full-Base-*"]
    }
    filter {
        name   = "virtualization-type"
        values = ["hvm"]
    }
}

data "aws_ami" "windows_server_2022" {
    most_recent = true
    owners = ["amazon"]
    filter {
        name   = "name"
        values = ["Windows_Server-2022-English-Full-Base-*"]
    }
    filter {
        name   = "virtualization-type"
        values = ["hvm"]
    }
}

resource "aws_instance" "windows_server" {
    for_each = var.systems_map
    ami                         = each.value["os_version"] == "2016" ? data.aws_ami.windows_server_2016.id : (each.value["os_version"] == "2019" ? data.aws_ami.windows_server_2019.id : (each.value["os_version"] == "2022" ? data.aws_ami.windows_server_2022.id : null))
    instance_type               = each.value["size"]
    private_ip                  = each.value["private_ip"] == null ? null : each.value["private_ip"]
    associate_public_ip_address = each.value["public_ip"]
    subnet_id                   = var.subnet_ids[each.value["network_id"]]
    vpc_security_group_ids      = [var.security_group_ids[each.value["network_id"]]]
    tags                        = {
        Name                    = each.value["name"]
    }
    user_data                   = data.template_file.base_config.rendered
}
