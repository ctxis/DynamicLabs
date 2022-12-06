# ![Dynamic Labs](Documentation/images/logo_name_128.png)

> **DISCLAIMER**
>
> **Dynamic Labs deploys INTENTIONALLY VULNERABLE SYSTEMS. Use at your own risk. Although the code implements controls to reduce the likelihood of users inadvertently publicly exposing vulnerable systems, after deployment please ensure that the lab systems are not Internet-exposed. Always use a restrictive IP range in the ``candidate_ip`` configuration variable**

## Overview

Creating lab environments for testing and learning red teaming/simulated attack techniques can be hard and time consuming.

Dynamic Labs is an open source tool aimed at red teamers and pentesters for the quick deployment of flexible, transient and cloud-hosted lab environments.

Its simple configuration files abstract the complexities of building realistic corporate environments with common vulnerabilities.

For example, complex Active Directory multi-domain and multi-forest environments, user endpoints, Windows/Linux servers, databases, web applications, simple vulberabilities and convoluted attack paths can be deployed in minutes. 

Dynamic Labs ships with easily customisable lab templates, ready for deployment.

## Use cases

Dynamic Labs has been extensively tried and tested for the following use-cases:

* **Simulated attack engagements** - effective red teamers test their toolchains against "digital twin" environments before deploying against real client systems, to make sure they work, evade known defences and don’t cause problems. Dynamic Labs can be used to deploy such environments, unique for each engagement.
* **Self-education and research** - Pre-made lab templates can be deployed to learn specific attack techniques, e.g. kerberoasting. Instead, when a generic environment is needed for research purposes and for testing new techniques, Dynamic Labs can do the heavy lifting of deploying a typical environment (e.g. Active Directory forest) that can then be manually customised once deployed. A new lab template encompassing the customisations can then be created and shared for others to test, review and practice the same technique.
* **Formal training courses** - Dynamic Labs allows the definition of lab environments to be used in training courses. The lab template needs to be defined once, and then mutliple instances of the training environment can be deployed when needed. This way, for example, each attendee can have a dedicated environment.

## Usage

To deploy a lab, follow the [Lab Deployment Instructions](Documentation/lab_deployment.md)

## Lab Templates

The list and description of the available lab templates, as shipped with Dynamic Labs, can be found at [Lab Templates](Documentation/lab_templates.md)

Documentation on how to modify or create new lab templates is available at [Template Development](Documentation/template_development.md)

## Contributing

We accept pull requests for lab templates to be included by default with the community version of Dynamic Labs.

If you are interested in implementing new core features or bug fixes, refer to the [Development Documentation](Documentation/development.md)

## Roadmap

In no specific order:

* Increase the number of lab templates shipped with the community version
* Simplify the definition of custom network security rules in lab templates
* Increase the [supported system features](Documentation/system_features.md) for Linux and Windows
* Implement support for Google Cloud Platform

## Current Maintainer
- David Turco ([@endle__](https://twitter.com/endle__))

## Contributors
Curent:
- Rohan Durve ([@Decode141](https://twitter.com/Decode141))

Past:
- Alex Bourla
- Dominik Schelle
