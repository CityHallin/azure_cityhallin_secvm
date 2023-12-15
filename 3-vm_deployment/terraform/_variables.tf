
#General
variable "project" {
  description = "Project name"
  type        = string
}

variable "region" {
  description = "Azure region location"
  type        = string
  default     = "northcentralus"
  validation {
    condition = contains([      
      "northcentralus",
      "westcentralus",
      "westus",
      "northeurope"
      ], var.region)
    error_message = "Regions limited due to Bastion Developer SKU offerings: https://learn.microsoft.com/en-us/azure/bastion/quickstart-developer-sku"
  } 
}

#NSG
variable "runner_ip_address" {
  description = "GitHub Runner IP address to allow through NSG"
  type        = string
  default     = ""
}

#Virtual Machine
variable "vm_size" {
  description = "VM size"
  type        = string
  default     = "Standard_B2ms"
}

variable "vm_username" {
  description = "Windows VM username"
  type        = string
  sensitive   = true
}

variable "vm_password" {
  description = "Windows VM password"
  type        = string
  sensitive   = true
}

variable "vm_image_publisher" {
  description = "Image Publisher"
  type        = string
  default     = "MicrosoftWindowsServer"
}

variable "vm_image_offer" {
  description = "Image Offer"
  type        = string
  default     = "WindowsServer"
}

variable "vm_image_sku" {
  description = "Image Sku"
  type        = string
  default     = "2022-datacenter-azure-edition"
  validation {
    condition = contains([      
      "2022-datacenter-azure-edition",
      "2019-Datacenter"
      ], var.vm_image_sku)
    error_message = "Not using a valid image for var.vm_image_sku."
  } 
}

variable "vm_image_version" {
  description = "Image version"
  type        = string
  default = "latest"
}
