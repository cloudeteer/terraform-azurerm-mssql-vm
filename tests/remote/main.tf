locals {
  backup_policy_id = "${one(data.azurerm_resources.recovery_services_vault.resources[*].id)}/backupPolicies/EnhancedPolicy"
  key_vault_id     = one(data.azurerm_resources.key_vault.resources[*].id)
  subnet_id        = "${one(data.azurerm_resources.virtual_network.resources[*].id)}/subnets/DefaultSubnet"
}

data "azurerm_resources" "recovery_services_vault" {
  resource_group_name = "rg-tfmodtest-prd-euw-01"

  type = "Microsoft.RecoveryServices/vaults"

  required_tags = {
    service = "terraform-module-tests"
  }
}

data "azurerm_resources" "key_vault" {
  resource_group_name = "rg-tfmodtest-prd-euw-01"

  type = "Microsoft.KeyVault/vaults"

  required_tags = {
    service = "terraform-module-tests"
  }
}

data "azurerm_resources" "virtual_network" {
  resource_group_name = "rg-tfmodtest-prd-euw-01"

  type = "Microsoft.Network/virtualNetworks"

  required_tags = {
    service = "terraform-module-tests"
  }
}

resource "random_string" "tftest" {
  length  = 3
  special = false
  upper   = false
}

resource "azurerm_resource_group" "tftest" {
  name     = "rg-tftest-dev-euw-${random_string.tftest.result}"
  location = "westeurope"
  tags = {
    terraform-module = "terraform-azurerm-vm"
  }
}

module "tftest" {
  source = "../.."

  name                = "vm-tftest-dev-euw-${random_string.tftest.result}"
  location            = azurerm_resource_group.tftest.location
  resource_group_name = azurerm_resource_group.tftest.name

  backup_policy_id = local.backup_policy_id
  key_vault_id     = local.key_vault_id
  subnet_id        = local.subnet_id

  computer_name = "tftest"
}
