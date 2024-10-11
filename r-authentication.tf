locals {
  admin_password = (
    coalesce(var.admin_password, one(random_password.this[*].result))
  )

  create_password = var.admin_password == null
}

resource "random_password" "this" {
  count  = local.create_password ? 1 : 0
  length = 24
}

#trivy:ignore:avd-azu-0017
#trivy:ignore:avd-azu-0013

resource "azurerm_key_vault_secret" "this" {
  for_each = var.store_secret_in_key_vault ? [1] : []


  name         = "${var.name}-${var.admin_username}-${lower(each.key)}"
  content_type = "Password"
  key_vault_id = var.key_vault_id
  value        = local.admin_password
}