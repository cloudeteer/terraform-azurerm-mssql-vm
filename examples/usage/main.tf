resource "azurerm_resource_group" "example" {
  name     = "rg-example-dev-euw-01"
  location = "westeurope"
}

resource "azurerm_virtual_network" "example" {
  name                = "vnet-example-dev-euw-01"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  address_space = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "example" {
  name                = "snet-example-dev-euw-01"
  resource_group_name = azurerm_resource_group.example.name

  address_prefixes     = ["10.0.2.0/24"]
  virtual_network_name = azurerm_virtual_network.example.name
}

resource "azurerm_recovery_services_vault" "example" {
  name                = "rsv-example-dev-euw-01"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  sku                 = "Standard"
  soft_delete_enabled = false
  storage_mode_type   = "GeoRedundant"
}

resource "azurerm_backup_policy_vm" "example" {
  name                = "bkpvm-example-dev-euw-01"
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
  name                = "kv-example-dev-euw-01"
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

module "example" {
  source = "cloudeteer/mssql-vm/azurerm"

  name                = "vm-example-dev-euw-01"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  backup_policy_id = azurerm_backup_policy_vm.example.id
  key_vault_id     = azurerm_key_vault.example.id
  subnet_id        = azurerm_subnet.example.id

  computer_name = "example"

  storage_configuration = {
    disk_type                      = "NEW" # COPY
    storage_workload_type          = "OLTP"
    system_db_on_data_disk_enabled = false

    data_settings = {
      luns              = [0]
      disk_size_gb      = 64
      default_file_path = "F:\\data"
    }
    log_settings = {
      luns              = [1]
      disk_size_gb      = 64
      default_file_path = "G:\\log"
    }
    temp_db_settings = {
      luns              = [2]
      disk_size_gb      = 64
      default_file_path = "H:\\tempdb"
    }
  }
}
