terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>2.69.0"
    }
  }
}

provider "azurerm" {
  features {}
}
