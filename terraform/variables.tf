variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "gallery_name" {
  type = string
}

variable "tags" {
  type = map(string)
  default = {
    iac  = "terraform"
    demo = "azure-image-builder"
  }
}
