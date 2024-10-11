terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  subscription_id                 = ""
  resource_provider_registrations = "none" # This is only required when the User, Service Principal, or Identity running Terraform lacks the permissions to register Azure Resource Providers.
  features {}
}

# Create a resource group
resource "azurerm_resource_group" "example" {
  name     = "rg-mssql-module-test"
  location = "Germany West Central"
}

# Create a virtual network within the resource group
resource "azurerm_virtual_network" "example" {
  name                = "vnet-mssql-module-test"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "example" {
  address_prefixes     = azurerm_virtual_network.example.address_space
  name                 = "snet-mssql-module-test"
  resource_group_name  = azurerm_virtual_network.example.resource_group_name
  virtual_network_name = azurerm_virtual_network.example.name
}

resource "azurerm_recovery_services_vault" "example" {
  name                = "rsv-example-dev-we-01"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  sku                 = "Standard"
  soft_delete_enabled = false
  storage_mode_type   = "GeoRedundant"
}

resource "azurerm_backup_policy_vm" "example" {
  name                = "bkpvm-example-dev-we-01"
  resource_group_name = azurerm_resource_group.example.name

  policy_type         = "V2"
  recovery_vault_name = azurerm_recovery_services_vault.example.name
  timezone            = "UTC"

  backup {
    frequency = "Daily"
    time      = "23:00"
  }

  retention_daily {
    count = 30
  }
}

data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "example" {
  name                = "kv-example-dev-we-03"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  purge_protection_enabled = false
  sku_name                 = "standard"
  tenant_id                = data.azurerm_client_config.current.tenant_id

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    secret_permissions = ["Backup", "Delete", "Get", "List", "Purge", "Recover", "Restore", "Set"]
  }
}

module "mssql_azure_vm" {
  source = "../../"

  backup_policy_id = azurerm_backup_policy_vm.example.id
  key_vault_id        = azurerm_key_vault.example.id
  location            = azurerm_resource_group.example.location
  name                = "example"
  resource_group_name = azurerm_resource_group.example.name
  subnet_id           = azurerm_subnet.example.id
  image               = "MicrosoftSQLServer:SQL2019-WS2019:Standard:latest"
}