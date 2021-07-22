# Azure Image Builder Test

This repo documents a _failed_ attempt to try to automate the Azure Image Builder with Infrastructure as Code (IaC) using Azure native Bicep template language.

## How to Use

### First - Clone Repo

First clone this repository

```bash
git clone https://github.com/julie-ng/azure-image-builder-test
```

### Option 1 - Azure CLI per Official Docs

1. Requirement - Visual Studio Code with [Azure CLI Tools Extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode.azurecli) installed.
2. Open the [`image-builder.azcli`](./image-builder.azcli) file
3. Run each command line by line…

Alternatively without Visual CLI Tools: confirm the feature is enabled and then copy Parts 1-8 into a `.sh` file and run that file.


### Option 2 - Bicep

The multitude of shell commands in the official docs is just nasty.  In my opinion, this would be better as Infrastructure as Code (IaC). I tried 🤷‍♀️, but no luck.

First create a resource group, optionally replacing `westeurope` with a region of your preference.

```bash
az group create --name azure-image-builder-rg --location westeurope
```

Then try the Bicep Infrastructure as Code example

```bash
az deployment group create -f ./image-builder.bicep -g azure-image-builder-rg
```

## Errors and Frustrations 😫🤬

Maybe you will have better luck than me, but I had the following problems:

1. Random Errors, which are formatted in nasty JSON not meant for human eyes 😵‍💫 (good luck below)
2. What in the world is the `runOutputname` for? The official docs are self referential, i.e. is a "run output name" 🙄
  
Example Errors

> `{"status":"Failed","error":{"code":"DeploymentFailed","message":"At least one resource deployment operation failed. Please list deployment operations for details. Please see https://aka.ms/DeployOperations for usage details.","details":[{"code":"Conflict","message":"{\r\n  \"code\": \"Conflict\",\r\n  \"message\": \"Update/Upgrade of image templates is currently not supported. Please change the name of the template you are submitting. If you have previously tried to submit a template and it failed to provision, you must delete it first and then resubmit. For more information, go to https://aka.ms/azvmimagebuilderts.\"\r\n}"},{"code":"BadRequest","message":"{\r\n  \"error\": {\r\n    \"code\": \"RoleAssignmentUpdateNotPermitted\",\r\n    \"message\": \"Tenant ID, application ID, principal ID, and scope are not allowed to be updated.\"\r\n  }\r\n}"}]}}`

And another one

> `{"status":"Failed","error":{"code":"DeploymentFailed","message":"At least one resource deployment operation failed. Please list deployment operations for details. Please see https://aka.ms/DeployOperations for usage details.","details":[{"code":"Conflict","message":"{\r\n  \"code\": \"Conflict\",\r\n  \"message\": \"Update/Upgrade of image templates is currently not supported. Please change the name of the template you are submitting. If you have previously tried to submit a template and it failed to provision, you must delete it first and then resubmit. For more information, go to https://aka.ms/azvmimagebuilderts.\"\r\n}"},{"code":"BadRequest","message":"{\r\n  \"error\": {\r\n    \"code\": \"RoleAssignmentUpdateNotPermitted\",\r\n    \"message\": \"Tenant ID, application ID, principal ID, and scope are not allowed to be updated.\"\r\n  }\r\n}"}]}}`

### Why are the error outputs not formatted?

I thought about throwing the commands into a node.js file just so I can format the output for easier debugging. 

But this is not possible because of the nested JSON output. For example `JSON.parse()` chokes on the `message:` key because it contains more JSON as string.

> `"message": "{\r\n  \"code\": \"Conflict\",\r\n  \"message\": \"Update/Upgrade of image templates is currently not supported. Please change the name of the template you are submitting. If you have previously tried to submit a template and it failed to provision, you must delete it first and then resubmit. For more information, go to https://aka.ms/azvmimagebuilderts.\"\r\n}"
`

After trying to grab the nested bits via regular expressions and to parse first, I gave up. 

## Use Case

Why did I even try this? Image a customer has multiple workloads, including containers in Kubernetes. Certain components however must run in custom Virtual images.

#### Challenge - VHDs will be deprecated

Customer is using HashiCorp Packer to prepare Virtual Machine image. But it displays a [warning message from that Azure Virtual Hard disks will be deprecated (eventually)](https://www.packer.io/docs/builders/azure/arm#azure-arm-builder-specific-options).

In the official Azure Doc [How to use Packer to create Linux virtual machine images in Azure](https://docs.microsoft.com/azure/virtual-machines/linux/build-image-with-packer) it recommends:
> Azure now has a service, Azure Image Builder, for defining and creating your own custom images. Azure Image Builder is built on Packer, so you can even use your existing Packer shell provisioner scripts with it. To get started with Azure Image Builder, see [Create a Linux VM with Azure Image Builder](https://docs.microsoft.com/azure/virtual-machines/linux/image-builder).


### Using Azure Image Builder

The [Create a Linux VM with Azure Image Builder](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/image-builder) link has a lot of complex code, for example:

```
curl https://raw.githubusercontent.com/Azure/azvmimagebuilder/master/quickquickstarts/1_Creating_a_Custom_Linux_Shared_Image_Gallery_Image/helloImageTemplateforSIG.json -o helloImageTemplateforSIG.json
sed -i -e "s/<subscriptionID>/$subscriptionID/g" helloImageTemplateforSIG.json
sed -i -e "s/<rgName>/$sigResourceGroup/g" helloImageTemplateforSIG.json
sed -i -e "s/<imageDefName>/$imageDefName/g" helloImageTemplateforSIG.json
sed -i -e "s/<sharedImageGalName>/$sigName/g" helloImageTemplateforSIG.json
sed -i -e "s/<region1>/$location/g" helloImageTemplateforSIG.json
sed -i -e "s/<region2>/$additionalregion/g" helloImageTemplateforSIG.json
sed -i -e "s/<runOutputName>/$runOutputName/g" helloImageTemplateforSIG.json
sed -i -e "s%<imgBuilderId>%$imgBuilderId%g" helloImageTemplateforSIG.json
```

In my opinion this is **bad practice** and should instead be done using Infrastructure as Code templates, ideally in a single command, for example:

```bash
az deployment group create -f ./image-builder.bicep -g azure-image-builder-rg
```


## Misc.

### Packer Message about VHD deprecation

Example output with my test use case to create a build agent.

```bash
$ packer build azure-devops-agent.pkr.hcl
azure-arm.ubuntu-agent: output will be in this color.

==> azure-arm.ubuntu-agent: Running builder ...
==> azure-arm.ubuntu-agent: Getting tokens using client secret
==> azure-arm.ubuntu-agent: Getting tokens using client secret
    azure-arm.ubuntu-agent: Creating Azure Resource Manager (ARM) client ...
==> azure-arm.ubuntu-agent: Warning: You are using Azure Packer Builder to create VHDs which is being deprecated, consider using Managed Images. Learn more https://www.packer.io/docs/builders/azure/arm#azure-arm-builder-specific-options
```

## References

- [Create a Linux image and distribute it to a Shared Image Gallery by using Azure CLI](https://docs.microsoft.com/azure/virtual-machines/linux/image-builder)
