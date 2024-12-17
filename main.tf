locals {
  vm_size_memory_mapping = {
    "Standard_B2s"      = 4096  # 4 GB
    "Standard_B2ms"     = 8192  # 8 GB
    "Standard_D2s_v5"   = 8192  # 8 GB
    "Standard_D4s_v5"   = 16384 # 16 GB
    "Standard_DC2s_v2"  = 8192  # 8 GB
    "Standard_DS1_v2"   = 3584  # 3.5 GB
    "Standard_DS2_v2"   = 7168  # 7 GB
    "Standard_E4s_v5"   = 32768 # 32 GB
    "Standard_E4bds_v5" = 65536 # 64 GB
    "Standard_F2s_v2"   = 4096  # 4 GB
    "Standard_F4s_v2"   = 8192  # 8 GB
  }

  total_memory_mb = lookup(local.vm_size_memory_mapping, var.size, 3584)
  max_server_memory_mb = coalesce(
    (var.max_server_memory_percent != null ? floor(local.total_memory_mb * (var.max_server_memory_percent / 100)) : null), # Use percentage-based calculation if provided
    var.sql_instance_max_server_memory_mb                                                                                  # Use absolute MB if percentage is not provided
  )

  is_manual_schedule_enabled = false

  data_disks = concat(
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
    ]
  )
}

#trivy:ignore:avd-azu-0039
module "azurerm_virtual_machine" {
  source  = "cloudeteer/vm/azurerm"
  version = "0.0.20"

  data_disks = local.data_disks

  admin_password                                         = var.admin_password
  admin_username                                         = var.admin_username
  allow_extension_operations                             = var.allow_extension_operations
  backup_policy_id                                       = var.backup_policy_id
  bypass_platform_safety_checks_on_user_schedule_enabled = var.bypass_platform_safety_checks_on_user_schedule_enabled
  computer_name                                          = var.computer_name
  create_public_ip_address                               = var.create_public_ip_address
  enable_automatic_updates                               = var.enable_automatic_updates
  enable_backup_protected_vm                             = var.enable_backup_protected_vm
  encryption_at_host_enabled                             = var.encryption_at_host_enabled
  extensions                                             = var.extensions
  hotpatching_enabled                                    = var.hotpatching_enabled
  identity                                               = var.identity
  image                                                  = var.image
  key_vault_id                                           = var.key_vault_id
  location                                               = var.location
  name                                                   = var.name
  os_disk                                                = var.os_disk
  patch_assessment_mode                                  = var.patch_assessment_mode
  patch_mode                                             = var.patch_mode
  private_ip_address                                     = var.private_ip_address
  resource_group_name                                    = var.resource_group_name
  secure_boot_enabled                                    = var.secure_boot_enabled
  size                                                   = var.size
  store_secret_in_key_vault                              = var.store_secret_in_key_vault
  subnet_id                                              = var.subnet_id
  tags                                                   = var.tags
  tags_virtual_machine                                   = var.tags_virtual_machine
  timezone                                               = var.timezone
  vtpm_enabled                                           = var.vtpm_enabled
  zone                                                   = var.zone
}


resource "time_sleep" "wait_60_seconds" {
  count      = length(local.data_disks) == 0 ? 0 : 1
  depends_on = [module.azurerm_virtual_machine]

  create_duration = "60s"
}

resource "azurerm_mssql_virtual_machine" "this" {
  depends_on = [time_sleep.wait_60_seconds]

  virtual_machine_id = module.azurerm_virtual_machine.id

  r_services_enabled    = var.r_services_enabled
  sql_connectivity_port = var.sql_connectivity_port
  sql_connectivity_type = var.sql_connectivity_type
  sql_license_type      = var.sql_license_type
  tags                  = var.tags

  dynamic "auto_backup" {
    for_each = var.enable_auto_backup && local.is_manual_schedule_enabled ? [true] : []
    content {
      encryption_enabled              = var.auto_backup_encryption_enabled
      encryption_password             = var.auto_backup_encryption_password
      retention_period_in_days        = var.auto_backup_retention_period_in_days
      storage_account_access_key      = var.auto_backup_storage_account_access_key
      storage_blob_endpoint           = var.auto_backup_storage_blob_endpoint
      system_databases_backup_enabled = var.auto_backup_system_databases_backup_enabled

      manual_schedule {
        days_of_week                    = var.days_of_week
        full_backup_frequency           = var.auto_backup_manual_schedule_full_backup_frequency
        full_backup_start_hour          = var.auto_backup_manual_schedule_full_backup_start_hour
        full_backup_window_in_hours     = var.auto_backup_manual_schedule_full_backup_window_in_hours
        log_backup_frequency_in_minutes = var.auto_backup_manual_schedule_log_backup_frequency_in_minutes
      }
    }
  }

  dynamic "auto_backup" {
    for_each = var.enable_auto_backup && !local.is_manual_schedule_enabled ? [true] : []
    content {
      encryption_enabled              = var.auto_backup_encryption_enabled
      encryption_password             = var.auto_backup_encryption_password
      retention_period_in_days        = var.auto_backup_retention_period_in_days
      storage_account_access_key      = var.auto_backup_storage_account_access_key
      storage_blob_endpoint           = var.auto_backup_storage_blob_endpoint
      system_databases_backup_enabled = var.auto_backup_system_databases_backup_enabled
    }
  }

  dynamic "auto_patching" {
    for_each = var.enable_auto_patching ? [true] : []
    content {
      day_of_week                            = var.auto_patching_day_of_week
      maintenance_window_duration_in_minutes = var.auto_patching_maintenance_window_duration_in_minutes
      maintenance_window_starting_hour       = var.auto_patching_maintenance_window_starting_hour
    }
  }

  #   dynamic "key_vault_credential" {
  #     for_each = var.enable_key_vault_credential ? [true] : []
  #     content {
  #       key_vault_url            = var.key_vault_credential_key_vault_url
  #       name                     = var.key_vault_credential_name
  #       service_principal_name   = var.key_vault_credential_service_principal_name
  #       service_principal_secret = var.key_vault_credential_service_principal_secret
  #     }
  #   }

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

  dynamic "sql_instance" {
    for_each = var.enable_sql_instance ? [true] : []
    content {
      adhoc_workloads_optimization_enabled = var.sql_instance_adhoc_workloads_optimization_enabled
      collation                            = var.sql_instance_collation
      instant_file_initialization_enabled  = var.sql_instance_instant_file_initialization_enabled
      lock_pages_in_memory_enabled         = var.sql_instance_lock_pages_in_memory_enabled
      max_dop                              = var.sql_instance_max_dop
      max_server_memory_mb                 = local.max_server_memory_mb
      min_server_memory_mb                 = var.sql_instance_min_server_memory_mb
    }
  }
}
