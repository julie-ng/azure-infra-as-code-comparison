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

## Example Output

### Plan

```bash
$ terraform plan -out plan.tfplan

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # azurerm_resource_group.sig will be created
  + resource "azurerm_resource_group" "sig" {
      + id       = (known after apply)
      + location = "westeurope"
      + name     = "azure-sig-tf-rg"
    }

  # azurerm_shared_image_gallery.sig will be created
  + resource "azurerm_shared_image_gallery" "sig" {
      + description         = "Testing with Terraform"
      + id                  = (known after apply)
      + location            = "westeurope"
      + name                = "sig_terraform_test"
      + resource_group_name = "azure-sig-tf-rg"
      + tags                = {
          + "demo" = "azure-image-builder"
          + "iac"  = "terraform"
        }
      + unique_name         = (known after apply)
    }

Plan: 2 to add, 0 to change, 0 to destroy.

─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

Saved the plan to: plan.tfplan

To perform exactly these actions, run the following command to apply:
    terraform apply "plan.tfplan"

azure-image-builder-test/terraform dev [!?] took 17s
```

### Apply

```bash
$ terraform apply plan.tfplan
azurerm_resource_group.sig: Creating...
azurerm_resource_group.sig: Creation complete after 1s [id=/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/azure-sig-tf-rg]
azurerm_shared_image_gallery.sig: Creating...
azurerm_shared_image_gallery.sig: Creation complete after 1s [id=/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/azure-sig-tf-rg/providers/Microsoft.Compute/galleries/sig_terraform_test]

Apply complete! Resources: 2 added, 0 changed, 0 destroyed.

azure-image-builder-test/terraform dev [!?] took 15s
```