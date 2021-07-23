# Azure Infra as Code Comparison

### Use Case

Create a Shared Image Gallery using Azure Image Builder.

I needed a custom VM but HashiCorp Packer says the Virtual Hard Disk (VHD) will be deprecated. Because the official Azure Docs for Packer recommend using Azure Image Builder instead, I figured why not? 😬

### Infrastructure as Code (IaC) Tooling

- [Bicep](./bicep)
- [Pulumi](./pulumi)
- [Terraform](./terraform)

