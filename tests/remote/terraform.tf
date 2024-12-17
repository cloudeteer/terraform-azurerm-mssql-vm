terraform {
  required_version = "1.9.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.1.0"
    }

    random = {
      source  = "hashicorp/random"
      version = ">= 3.1"
    }

    time = {
      source  = "hashicorp/time"
      version = "0.12.0"
    }
  }
}
