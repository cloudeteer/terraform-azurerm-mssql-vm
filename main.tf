module "azurerm_virtual_machine" {
  source  = "cloudeteer/vm/azurerm"
  version = "0.0.14"

  image               = var.azurerm_virtual_machine_image
  location            = var.azurerm_virtual_machine_location
  name                = var.azurerm_virtual_machine_name
  resource_group_name = var.azurerm_virtual_machine_resource_group_name

  # Storage / Disk Configuration
  #   os_disk_size_gb = var.azurerm_virtual_machine_os_disk.disk_size_gb

  data_disks = var.azurerm_virtual_machine_data_disks

  # Identity for the VM
  #   identity = {
  #     type = UserAssigned
  #     identity_ids =
  #   }

  # Networking
  subnet_id        = var.azurerm_virtual_machine_subnet_id
  encryption_at_host_enabled = false # only for mpn subscription never do this in prod
  vtpm_enabled = false # only for mpn subscription never do this in prod
  secure_boot_enabled = false # only for mpn subscription never do this in prod
  backup_policy_id = var.azurerm_virtual_machine_backup_policy_vm_id
  key_vault_id     = var.azurerm_virtual_machine_key_vault_id
}

resource "azurerm_mssql_virtual_machine" "this" {
  r_services_enabled    = var.r_services_enabled
  sql_connectivity_port = var.sql_connectivity_port
  sql_connectivity_type = var.sql_connectivity_type
  sql_license_type      = var.sql_license_type
  virtual_machine_id    = module.azurerm_virtual_machine.id
  tags                  = var.tags

  dynamic "auto_backup" {
    for_each = var.enable_auto_backup ? [1] : []
    content {
      encryption_enabled              = var.auto_backup_encryption_enabled
      encryption_password             = var.auto_backup_encryption_password
      retention_period_in_days        = var.auto_backup_retention_period_in_days
      storage_account_access_key      = var.auto_backup_storage_account_access_key
      storage_blob_endpoint           = var.auto_backup_storage_blob_endpoint
      system_databases_backup_enabled = var.auto_backup_system_databases_backup_enabled
    }
    #     dynamic "manual_schedule" {
    #       for_each = var.enable_manual_schedule ? [1] : []
    #       content {
    #         days_of_week                    = var.days_of_week
    #         full_backup_frequency           = var.auto_backup_manual_schedule_full_backup_frequency
    #         full_backup_start_hour          = var.auto_backup_manual_schedule_full_backup_start_hour
    #         full_backup_window_in_hours     = var.auto_backup_manual_schedule_full_backup_window_in_hours
    #         log_backup_frequency_in_minutes = var.auto_backup_manual_schedule_log_backup_frequency_in_minutes
    #       }
    #     }
  }

  dynamic "auto_patching" {
    for_each = var.enable_auto_patching ? [1] : []
    content {
      day_of_week                            = var.auto_patching_day_of_week
      maintenance_window_duration_in_minutes = var.auto_patching_maintenance_window_duration_in_minutes
      maintenance_window_starting_hour       = var.auto_patching_maintenance_window_starting_hour
    }
  }

  #   dynamic "key_vault_credential" {
  #     for_each = var.enable_key_vault_credential ? [1] : []
  #     content {
  #       key_vault_url            = var.key_vault_credential_key_vault_url
  #       name                     = var.key_vault_credential_name
  #       service_principal_name   = var.key_vault_credential_service_principal_name
  #       service_principal_secret = var.key_vault_credential_service_principal_secret
  #     }
  #   }

  #   storage_configuration {
  #     disk_type             = var.storage_configuration_disk_type
  #     storage_workload_type = var.storage_configuration_storage_workload_type
  #     data_settings {
  #       default_file_path = var.storage_configuration_data_settings_default_file_path
  #       luns              = var.storage_configuration_data_settings.luns
  #     }
  #     log_settings {
  #       default_file_path = var.storage_configuration_log_settings_default_file_path
  #       luns              = var.storage_configuration_log_settings.luns
  #     }
  #   }

  dynamic "sql_instance" {
    for_each = var.enable_sql_instance ? [1] : []
    content {
      adhoc_workloads_optimization_enabled = var.sql_instance_adhoc_workloads_optimization_enabled
      collation                            = var.sql_instance_collation
      instant_file_initialization_enabled  = var.sql_instance_instant_file_initialization_enabled
      lock_pages_in_memory_enabled         = var.sql_instance_lock_pages_in_memory_enabled
      max_dop                              = var.sql_instance_max_dop
#       max_server_memory_mb                 = var.sql_instance_max_server_memory_mb
#       min_server_memory_mb                 = var.sql_instance_min_server_memory_mb
    }
    # TODO: let mssql only use 80% of the virtual machine memory
  }
}

