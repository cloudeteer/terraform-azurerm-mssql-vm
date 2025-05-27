locals {
  # Combine data disk configurations from the input variable var.data_disk and those generated from
  # var.storage_configuration for data, log, and tempdb settings.
  data_disks = concat(
    var.data_disks,
    [
      for item in try(var.storage_configuration.data_settings.luns, []) : {
        lun                  = item
        disk_size_gb         = var.storage_configuration.data_settings.disk_size_gb
        caching              = var.storage_configuration.data_settings.caching
        storage_account_type = var.storage_configuration.data_settings.storage_account_type
      }
    ],
    [
      for item in try(var.storage_configuration.log_settings.luns, []) : {
        lun                  = item
        disk_size_gb         = var.storage_configuration.log_settings.disk_size_gb
        caching              = var.storage_configuration.log_settings.caching
        storage_account_type = var.storage_configuration.log_settings.storage_account_type
      }
    ],
    [
      for item in try(var.storage_configuration.temp_db_settings.luns, []) : {
        lun                  = item
        disk_size_gb         = var.storage_configuration.temp_db_settings.disk_size_gb
        caching              = var.storage_configuration.temp_db_settings.caching
        storage_account_type = var.storage_configuration.temp_db_settings.storage_account_type
      }
    ],
  )

  # Calculate max_server_memory_mb based on percentage of total memory if provided, otherwise use the absolute value
  max_server_memory_mb = coalesce(
    (
      var.max_server_memory_percent != null
      ? floor(local.total_memory_mb * (var.max_server_memory_percent / 100))
      : null
    ),
    var.sql_instance.max_server_memory_mb
  )

  # Set Ops.Stack tag 'opsstack-memory-critical' to '95' as default for SQL Virtual Machines.
  # Can be overwritten by user.
  tags_virtual_machine = merge({ opsstack-memory-critical = "95" }, var.tags_virtual_machine)

  total_memory_mb = lookup(local.vm_size_memory_mapping, var.size, 3584)

  vm_size_memory_mapping = {
    "Standard_B2s"      = 4096  #   4 GB
    "Standard_B2ms"     = 8192  #   8 GB
    "Standard_D2s_v5"   = 8192  #   8 GB
    "Standard_D4s_v5"   = 16384 #  16 GB
    "Standard_DC2s_v2"  = 8192  #   8 GB
    "Standard_DS1_v2"   = 3584  # 3.5 GB
    "Standard_DS2_v2"   = 7168  #   7 GB
    "Standard_E4s_v5"   = 32768 #  32 GB
    "Standard_E4bds_v5" = 65536 #  64 GB
    "Standard_F2s_v2"   = 4096  #   4 GB
    "Standard_F4s_v2"   = 8192  #   8 GB
  }
}

#trivy:ignore:avd-azu-0039
module "azurerm_virtual_machine" {
  source  = "cloudeteer/vm/azurerm"
  version = "1.3.5"

  name                 = var.name
  location             = var.location
  resource_group_name  = var.resource_group_name
  tags                 = var.tags
  tags_virtual_machine = local.tags_virtual_machine

  admin_password             = var.admin_password
  admin_username             = var.admin_username
  backup_policy_id           = var.backup_policy_id
  computer_name              = var.computer_name
  create_public_ip_address   = var.create_public_ip_address
  data_disks                 = local.data_disks
  enable_automatic_updates   = var.enable_automatic_updates
  enable_backup_protected_vm = var.enable_backup_protected_vm
  encryption_at_host_enabled = var.encryption_at_host_enabled
  identity                   = var.identity
  image                      = var.image
  key_vault_id               = var.key_vault_id
  os_disk                    = var.os_disk
  patch_assessment_mode      = var.patch_assessment_mode
  patch_mode                 = var.patch_mode
  private_ip_address         = var.private_ip_address
  secure_boot_enabled        = var.secure_boot_enabled
  size                       = var.size
  store_secret_in_key_vault  = var.store_secret_in_key_vault
  subnet_id                  = var.subnet_id
  timezone                   = var.timezone
  vtpm_enabled               = var.vtpm_enabled
  zone                       = var.zone
}

resource "time_sleep" "wait_60_seconds" {
  count      = length(local.data_disks) == 0 ? 0 : 1
  depends_on = [module.azurerm_virtual_machine]

  create_duration = "60s"
}

resource "azurerm_mssql_virtual_machine" "this" {
  depends_on = [time_sleep.wait_60_seconds]

  virtual_machine_id = module.azurerm_virtual_machine.id
  tags               = var.tags

  r_services_enabled = var.r_services_enabled
  sql_license_type   = var.sql_license_type

  sql_connectivity_port            = var.sql_connectivity_port
  sql_connectivity_type            = var.sql_connectivity_type
  sql_connectivity_update_username = var.sql_connectivity_update_username
  sql_connectivity_update_password = var.sql_connectivity_update_password

  dynamic "sql_instance" {
    for_each = var.enable_sql_instance ? [true] : []
    content {
      adhoc_workloads_optimization_enabled = var.sql_instance.adhoc_workloads_optimization_enabled
      collation                            = var.sql_instance.collation
      instant_file_initialization_enabled  = var.sql_instance.instant_file_initialization_enabled
      lock_pages_in_memory_enabled         = var.sql_instance.lock_pages_in_memory_enabled
      max_dop                              = var.sql_instance.max_dop
      max_server_memory_mb                 = local.max_server_memory_mb
      min_server_memory_mb                 = var.sql_instance.min_server_memory_mb
    }
  }

  dynamic "storage_configuration" {
    for_each = var.storage_configuration != null ? [true] : []
    content {
      disk_type                      = var.storage_configuration.disk_type
      storage_workload_type          = var.storage_configuration.storage_workload_type
      system_db_on_data_disk_enabled = var.storage_configuration.system_db_on_data_disk_enabled

      dynamic "data_settings" {
        for_each = var.storage_configuration.data_settings != null ? [true] : []
        content {
          default_file_path = var.storage_configuration.data_settings.default_file_path
          luns              = var.storage_configuration.data_settings.luns
        }
      }

      dynamic "log_settings" {
        for_each = var.storage_configuration.log_settings != null ? [true] : []
        content {
          default_file_path = var.storage_configuration.log_settings.default_file_path
          luns              = var.storage_configuration.log_settings.luns
        }
      }

      dynamic "temp_db_settings" {
        for_each = var.storage_configuration.temp_db_settings != null ? [true] : []
        content {
          default_file_path = var.storage_configuration.temp_db_settings.default_file_path
          luns              = var.storage_configuration.temp_db_settings.luns

          data_file_count        = var.storage_configuration.temp_db_settings.data_file_count
          data_file_growth_in_mb = var.storage_configuration.temp_db_settings.data_file_growth_in_mb
          data_file_size_mb      = var.storage_configuration.temp_db_settings.data_file_size_mb
          log_file_growth_mb     = var.storage_configuration.temp_db_settings.log_file_growth_mb
          log_file_size_mb       = var.storage_configuration.temp_db_settings.log_file_size_mb
        }
      }
    }
  }
}
