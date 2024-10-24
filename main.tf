module "azurerm_virtual_machine" {
  source  = "cloudeteer/vm/azurerm"
  version = "0.0.14"

  image    = var.image
  location = var.location
  name     = var.name
  tags     = merge(var.tags, var.tags_virtual_machine)

  admin_password                                         = var.admin_password
  admin_username                                         = var.admin_username
  allow_extension_operations                             = var.allow_extension_operations
  backup_policy_id                                       = var.backup_policy_id
  bypass_platform_safety_checks_on_user_schedule_enabled = var.bypass_platform_safety_checks_on_user_schedule_enabled
  computer_name                                          = var.computer_name
  data_disks                                             = var.data_disks
  encryption_at_host_enabled                             = false # only for mpn subscription never do this in prod
  enable_automatic_updates                               = var.enable_automatic_updates
  enable_backup_protected_vm                             = var.enable_backup_protected_vm
  extensions                                             = var.extensions
  hotpatching_enabled                                    = var.hotpatching_enabled
  key_vault_id                                           = var.key_vault_id
  operating_system                                       = "Windows"
  os_disk                                                = var.os_disk
  patch_assessment_mode                                  = var.patch_assessment_mode
  patch_mode                                             = var.patch_mode
  private_ip_address                                     = var.private_ip_address
  create_public_ip_address                               = true
  resource_group_name                                    = var.resource_group_name
  secure_boot_enabled                                    = false # only for mpn subscription never do this in prod
  size                                                   = var.size
  store_secret_in_key_vault                              = var.store_secret_in_key_vault
  subnet_id                                              = var.subnet_id
  timezone                                               = var.timezone
  vtpm_enabled                                           = false # only for mpn subscription never do this in prod
  zone                                                   = var.zone


  identity = var.identity
}

locals {
  is_manual_schedule_enabled = false
}

resource "time_sleep" "wait_60_seconds" {
  depends_on = [module.azurerm_virtual_machine]

  create_duration = "60s"
}

resource "azurerm_mssql_virtual_machine" "this" {
  depends_on            = [time_sleep.wait_60_seconds]
  r_services_enabled    = var.r_services_enabled
  sql_connectivity_port = var.sql_connectivity_port
  sql_connectivity_type = var.sql_connectivity_type
  sql_license_type      = var.sql_license_type
  virtual_machine_id    = module.azurerm_virtual_machine.id
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

  storage_configuration {
    disk_type                      = var.storage_configuration_disk_type
    storage_workload_type          = var.storage_configuration_storage_workload_type
    system_db_on_data_disk_enabled = var.storage_configuration_system_db_on_data_disk_enabled

    dynamic "data_settings" {
      for_each = length([for i in var.data_disks : i.lun if i.sql_storage_type == "data"]) > 0 ? [true] : []
      content {
        default_file_path = var.storage_configuration_data_settings_default_file_path
        luns              = [for i in var.data_disks : i.lun if i.sql_storage_type == "data"]
      }
    }

    dynamic "log_settings" {
      for_each = length([for i in var.data_disks : i.lun if i.sql_storage_type == "log"]) > 0 ? [true] : []
      content {
        default_file_path = var.storage_configuration_log_settings_default_file_path
        luns              = [for i in var.data_disks : i.lun if i.sql_storage_type == "log"]
      }
    }

    dynamic "temp_db_settings" {
      for_each = length([for i in var.data_disks : i.lun if i.sql_storage_type == "temp_db"]) > 0 ? [true] : []
      content {
        default_file_path = var.temp_db_settings_default_file_path
        luns              = []
        #         luns              = [for i in var.data_disks : i.lun if i.sql_storage_type == "temp_db"]
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
      max_server_memory_mb = coalesce(
        (var.max_server_memory_percent != null ? floor(local.total_memory_mb * (var.max_server_memory_percent / 100)) : null), # Use percentage-based calculation if provided
        var.sql_instance_max_server_memory_mb                                                                                  # Use absolute MB if percentage is not provided
      )
      min_server_memory_mb = var.sql_instance_min_server_memory_mb
    }
  }
}


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

  # Identify total memory for the selected SKU
  total_memory_mb = lookup(local.vm_size_memory_mapping, var.size, 3584)
}
