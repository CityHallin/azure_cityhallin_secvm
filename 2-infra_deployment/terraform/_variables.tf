
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

variable "backend_resource_group_name" {
  description = "Backend Resource Group Name"
  type        = string
}

variable "backend_storage_account_name" {
  description = "Backend Stroage Account Name"
  type        = string
}

variable "kv_github_pat" {
  description = "PAT for GitHub account"
  type        = string
  sensitive   = true
}

variable "kv_iot_claim" {
  description = "IoT Device claim that will be sent to function for auth"
  type        = string
  sensitive   = true
}

#GitHub
variable "github_owner" {
  description = "Github repo owner"
  type        = string
  sensitive   = true
}

variable "github_repo_name" {
  description = "Github repo name"
  type        = string
  sensitive   = true
}

#IoT Hub
#Needed for Shell script
variable "spn_client_id" {
  description = "App Registration Client ID"
  type        = string
  sensitive   = true
}

variable "spn_client_secret" {
  description = "App Registration Client Secret"
  type        = string
  sensitive   = true
}
