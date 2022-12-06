# Default Lab Templates Documentation

The default lab templates shipped with Dynamic Labs are located in the ``Templates`` directory and are grouped according to the following types:

* ``exercises`` - Lab templates that include a single intentional vulnerability. Useful for practicing a single attack technique such as kerberoasting.
* ``attack-paths`` - Lab templates that include multiple vulnerabilities that can be chained to form a high impact attack path. Useful for self-studying or general training.
* ``demos`` - Lab templates that implement common environments, such as an Active Directory forests. Useful for research purposes or as a starting point in the [development of new lab templates](template_development.md). These templates do not include intentional vulnerabilities; however these environments are not hardened in any meaningful way and may include unintentional and potentially exploitable weaknesses.
* ``training`` - Larger templates used in internal training courses. Not available in the community version of Dynamic Labs.

## Exercises

| Lab Template Name | Description | Supported Clouds | Special Requirements |
| ----------------- | ----------- | ---------------- | -------------------- |
| kerberoasting-1   | Active Directory domain to practice the kerberoasting attack technique | AWS | none |
| msa-1             | Active Directory domain to practice abusing a misconfigured Managed Service Account | AWS | none |

## Attack Paths

| Lab Template Name | Description | Supported Clouds | Special Requirements |
| ----------------- | ----------- | ---------------- | -------------------- |
| Alfa              |  Active Directory domain with basic weaknesses like Kerberoasting and MSA abuse to chain in an attack path in order to gain Domain Admin privileges | AWS, Azure | none |

## Demos

| Lab Template Name | Description | Supported Clouds | Special Requirements |
| ----------------- | ----------- | ---------------- | -------------------- |
| simple-AD | Single Active Directory domain with one server | AWS, Azure | none |
| multi-AD | Single Forest with two Active Directory domains and one server | AWS, Azure | none |
| standalone-windows-server | Single standalone Windows Server | AWS, Azure | none |
| standalone-windows-workstation | Single standalone Windows Worstation | Azure | none |
| standalone-kali-linux | Single Kali-Linux host | AWS, Azure | Requires accepting the Kali AWS/Azure Marketplace license as a pre-requisite |
| standalone-ubuntu-server | Single Ubuntu host | AWS, Azure | none |

## Training

Refer to the individual templates in the ``Templates\training\`` directory.