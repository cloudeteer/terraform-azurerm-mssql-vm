locals {
  create_identity = (
    strcontains(try(var.azurerm_virtual_machine_identity.type, ""), "UserAssigned") &&
    length(try(coalescelist(var.azurerm_virtual_machine_identity.identity_ids, []), [])) == 0
  )
}

resource "azurerm_user_assigned_identity" "this" {
  count = local.create_identity ? 1 : 0

  name                = "id-${trimprefix(var.azurerm_virtual_machine_name, "vm-")}"
  location            = var.azurerm_virtual_machine_location
  resource_group_name = var.azurerm_virtual_machine_resource_group_name
  tags                = var.tags
}