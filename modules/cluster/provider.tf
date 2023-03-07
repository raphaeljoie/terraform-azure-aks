terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.20.0"
    }

    azuread = {
      source  = "hashicorp/azuread"
      version = ">= 2.15.0"
    }

    helm = {
      source = "hashicorp/helm"
      version = ">=2.9.0"
    }
  }
}
