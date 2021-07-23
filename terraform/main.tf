# 1) Create Resource Group
resource "azurerm_resource_group" "sig" {
  name     = var.resource_group_name
  location = var.location
}

# 2) Create Shared Gallery
resource "azurerm_shared_image_gallery" "sig" {
  name                = var.gallery_name
  resource_group_name = azurerm_resource_group.sig.name
  location            = azurerm_resource_group.sig.location
  description         = "Testing with Terraform"
  tags                = var.tags
}
