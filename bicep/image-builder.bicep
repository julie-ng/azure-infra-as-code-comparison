// Step 1 - create a Resource Group in Azure CLI (because Bicep cannot create RGs 🤷‍♀️)
// az group create --name azure-image-builder-rg --location westeurope

// --------
// Defaults
// --------
// For purpose of this demo, we will just built-in 'Contributor' Role.
// per https://docs.microsoft.com/en-us/azure/role-based-access-control/built-in-roles

param roleDefId string = 'b24988ac-6180-42a0-ab88-20f7382dd24c'

param defaultSourceImage object = {
  type: 'PlatformImage'
  publisher: 'Canonical'
  offer: 'UbuntuServer'
  sku: '18.04-LTS'
  version: 'latest'
}

// ------
// Config
// ------

// Azure Resources
param galleryName string  = 'contoso_gallery2'
param imageName string = 'contoso-server2'
param identityName string = 'contoso-imagebuilder-mi2'
param imageTemplateConfig object = {
  name: 'contoso-server-template3'
}

param tags object = {
  demo: 'shared-image-gallery'
  iac: 'bicep'
  public: 'false'
}

// https://docs.microsoft.com/en-us/azure/virtual-machines/linux/cli-ps-findimage#terminology
param imageIdentifiers object = {
  publisher: 'contoso'
  offer: 'contosoServer'
  sku: 'stable'
}

// https://docs.microsoft.com/en-us/azure/virtual-machines/linux/image-builder-json#properties-distribute
param runOutputName string = 'demo-run' // no idea what this should be
param timestamp string = utcNow()

// ------------------------
// Managed Identity for AIB
// ------------------------

resource mi 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: identityName
  location: resourceGroup().location
  tags: tags
}

resource miRbac 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid('Contributor', resourceGroup().id)
  scope: resourceGroup()
  properties: {
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', roleDefId)
    principalId: mi.properties.principalId
  }
}

// --------------------
// Shared Image Gallery
// --------------------

// 1) Create Gallery
// az sig create…
resource gallery 'Microsoft.Compute/galleries@2019-12-01' = {
  name: galleryName
  location: resourceGroup().location
  tags: tags
  properties: {
    description: 'Azure Image Builder Gallery'
    identifier: {}
  }
}

// 2) Create Image Definition
// az sig image-definition create…
// Example https://github.com/Azure/azure-quickstart-templates/tree/master/quickstarts/microsoft.compute/sig-image-definition-create
resource demoImage 'Microsoft.Compute/galleries/images@2019-12-01' = {
  name: '${galleryName}/${imageName}'
  location: resourceGroup().location
  tags: tags
  properties: {
    description: 'Test Image for Demo'
    osType: 'Linux' // Required
    osState: 'Generalized' // Required
    identifier: {
      publisher: imageIdentifiers.publisher
      offer: imageIdentifiers.offer
      sku: imageIdentifiers.sku
    }
  }
}

// 3) Create Image Template Resource

resource imageTemplate 'Microsoft.VirtualMachineImages/imageTemplates@2020-02-14' = {
  name: imageTemplateConfig.name
  location: resourceGroup().location
  tags: tags
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${mi.id}': {}
    }
  }
  properties: {
    buildTimeoutInMinutes: 10
    vmProfile: {
      vmSize: 'Standard_D2_v2'
      osDiskSizeGB: 127
    }
    source: defaultSourceImage
    customize: [
      {
        type: 'Shell'
        name: 'HelloWorld'
        inline: [
          'sudo apt-get update'
        ]
      }
    ]
    distribute: [
      {
        type: 'SharedImage'
        galleryImageId: demoImage.id
        runOutputName: '${runOutputName}-${timestamp}'
        artifactTags: {
          demo: 'shared-image-gallery'
          baseosimg: 'ubuntu1804'
        }
        replicationRegions: []
      }
    ]
  }
}

// 4) Invoke Action
// az resource invoke-action \
//      --resource-group $sigResourceGroup \
//      --resource-type  Microsoft.VirtualMachineImages/imageTemplates \
//      -n helloImageTemplateforSIG01 \
//      --action Run
param actionResourceType string = 'Microsoft.VirtualMachineImages/imageTemplates'
resource runBuildImage 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: 'BuildVMImage'
  location: resourceGroup().location
  kind: 'AzureCLI'
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${mi.id}': {}
    }
  }
  properties: {
    scriptContent: 'az resource invoke-action --action Run --resource-type ${actionResourceType} --name ${imageTemplateConfig.name} --resource-group ${resourceGroup().name}'
    retentionInterval: 'P1D' // not required per Docs, but per Intellisene 🙄
    azCliVersion: '2.26.0' // not required per Docs, but per Intellisene 🙄
  }
  dependsOn: [
    imageTemplate
  ]
}

// -------
// Outputs
// -------

output galleryId string = gallery.id

output managedIdentity object = {
  name:       identityName
  id:         mi.id
  clientId:   mi.properties.clientId
  assignment: miRbac.id
}

output imageId string = demoImage.id
