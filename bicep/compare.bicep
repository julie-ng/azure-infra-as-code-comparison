resource gallery 'Microsoft.Compute/galleries@2019-12-01' = {
  name: 'bicep_sig_just_gallery'
  location: resourceGroup().location
  tags:  {
    demo: 'azure-image-builder'
    iac: 'bicep'
  }
  properties: {
    description: 'Azure Image Builder Gallery'
    identifier: {}
  }
}

output galleryId string = gallery.id
