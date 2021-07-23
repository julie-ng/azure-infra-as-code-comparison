# Azure Image Builder with Terraform

For purpose of this Infrastructure as Code (IaC) comparison, this Terraform project uses local state.

### 1. Clone Repo

Clone this code to your local machine

```bash
git clone https://github.com/julie-ng/azure-infra-as-code-comparison
```

### 2. Change Directory

```bash
cd terraform
```

### 3. Customize Infrastructure (optional)

By default this project creates a shared image gallery in West Europe. To customize to your liking, open up the `gallery.auto.tfvars` file and customize 

```hcl
# gallery.auto.tfvars
gallery_name        = "sig_terraform_test"
location            = "westeurope"
resource_group_name = "azure-sig-tf-rg"
```


### 4. Run Terraform

And be sure to verify plan before running `terraform apply`

```
terraform init
terraform plan -out plan.tfplan
terraform apply plan.tfplan
```