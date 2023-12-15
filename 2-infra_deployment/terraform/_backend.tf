terraform {

  backend "azurerm" {}

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.84.0"
    }

  }

  required_version = ">= 1.6.5"
}

provider "azurerm" {
  features {}
}

#Get Tenant and environment info
data "azurerm_client_config" "current" {}