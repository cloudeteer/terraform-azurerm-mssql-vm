terraform {
  required_version = ">= 1.9"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.1"
    }

    time = {
      source  = "hashicorp/time"
      version = ">= 0.4"
    }
  }
}
