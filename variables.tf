variable "admin_password" {
  description = "Password to use for the local administrator on this virtual machine. If not set, a password will be generated and stored in the Key Vault specified by key_vault_id."
  default     = null
  type        = string
}

variable "admin_username" {
  default     = "azureadmin"
  description = "Username of the local administrator for the virtual machine."
  type        = string
}

variable "auto_backup_encryption_enabled" {
  description = "A boolean flag to specify whether encryption is enabled for backups."
  type        = bool
  default     = false
}

variable "auto_backup_encryption_password" {
  description = "The password used to encrypt backups if encryption is enabled. Must be specified when encryption is enabled."
  type        = string
  default     = ""
  sensitive   = true
  validation {
    condition     = var.auto_backup_encryption_password != "" || !var.enable_auto_backup
    error_message = "Encryption password must be provided when auto backup is enabled."
  }
}

variable "auto_backup_manual_schedule_full_backup_frequency" {
  description = "Frequency of full backups. Possible values: 'Daily', 'Weekly'."
  type        = string
  default     = "Weekly"
}

variable "auto_backup_manual_schedule_full_backup_start_hour" {
  description = "The hour of the day to start full backups, in 24-hour format (0-23)."
  type        = number
  default     = null
}

variable "auto_backup_manual_schedule_full_backup_window_in_hours" {
  description = "The number of hours the full backup operation can run."
  type        = number
  default     = null
}

variable "auto_backup_manual_schedule_log_backup_frequency_in_minutes" {
  description = "The frequency in minutes for log backups."
  type        = number
  default     = null
}

variable "auto_backup_retention_period_in_days" {
  description = "The number of days to retain backups for the SQL virtual machine."
  type        = number
  default     = null
}

variable "auto_backup_storage_account_access_key" {
  description = "The access key for the storage account to store SQL Server backups."
  type        = string
  default     = null
}

variable "auto_backup_storage_blob_endpoint" {
  description = "The storage blob endpoint for the backup of the SQL virtual machine."
  type        = string
  default     = null
}

variable "auto_backup_system_databases_backup_enabled" {
  description = "A boolean flag to specify whether system databases are included in the backup."
  type        = bool
  default     = false
}

variable "auto_patching_day_of_week" {
  description = "The day of the week for auto patching. Possible values: 'Sunday', 'Monday', etc."
  type        = string
  default     = null
}

variable "auto_patching_maintenance_window_duration_in_minutes" {
  description = "The duration of the maintenance window in minutes for auto patching."
  type        = number
  default     = null
}

variable "auto_patching_maintenance_window_starting_hour" {
  description = "The starting hour (0-23) of the maintenance window for auto patching."
  type        = number
  default     = null
}

variable "backup_policy_id" {
  description = "The ID of the backup policy to use."
  type        = string
  default     = null

  #   validation {
  #     condition     = (var.enable_backup_protected_vm && var.backup_policy_id != null) || !var.enable_backup_protected_vm
  #     error_message = "A backup policy ID is required when backup_protected_vm.enabled is true."
  #   }
}

variable "data_disks" {
  description = <<-EOT
    Additional disks to be attached to the virtual machine.

    Required parameters:

    Parameter | Description
    -- | --
    `disk_size_gb` | Specifies the size of the managed disk to create in gigabytes.
    `lun` | The Logical Unit Number of the Data Disk, which needs to be unique within the Virtual Machine.

    Optional parameters:

    Parameter | Description
    -- | --
    `caching` | Specifies the caching requirements for this Data Disk. Possible values include `None`, `ReadOnly` and `ReadWrite`.
    `create_option` | The method to use when creating the managed disk. Possible values include: `Empty` - Create an empty managed disk.
    `name` | Specifies the name of the Managed Disk. If omitted a name will be generated based on `name`.
    `storage_account_type` | The type of storage to use for the managed disk. Possible values are `Standard_LRS`, `StandardSSD_ZRS`, `Premium_LRS`, `PremiumV2_LRS`, `Premium_ZRS`, `StandardSSD_LRS` or `UltraSSD_LRS`.
  EOT

  type = list(object({
    caching              = optional(string, "ReadWrite")
    create_option        = optional(string, "Empty")
    disk_size_gb         = number
    lun                  = number
    name                 = optional(string)
    storage_account_type = optional(string, "Premium_LRS")
  }))

  default = []
}

variable "days_of_week" {
  description = "A list of days on which backup can take place. Possible values are Monday, Tuesday, Wednesday, Thursday, Friday, Saturday and Sunday"
  type        = string
  default     = null
}

variable "enable_auto_backup" {
  description = "A boolean flag to enable or disable automatic backups for SQL backups."
  type        = bool
  default     = false
}

variable "enable_auto_patching" {
  description = "A boolean flag to enable or disable auto patching."
  type        = bool
  default     = false
}

variable "enable_key_vault_credential" {
  description = "A boolean flag to enable or disable Key Vault credentials for the SQL virtual machine."
  type        = bool
  default     = false
}

variable "enable_manual_schedule" {
  description = "A boolean flag to enable or disable the manual schedule for SQL backups."
  type        = bool
  default     = false
}

variable "enable_sql_instance" {
  description = "A boolean flag to enable or disable the SQL instance configuration."
  type        = bool
  default     = false
}

variable "enable_wsfc_domain_credential" {
  description = "A boolean flag to enable or disable WSFC domain credentials for the SQL virtual machine."
  type        = bool
  default     = false
}

variable "identity" {
  description = <<-EOT
    The Azure managed identity to assign to the virtual machine.

    Optional parameters:

    Parameter | Description
    -- | --
    `type` | Specifies the type of Managed Service Identity that should be configured on this Windows Virtual Machine. Possible values are `SystemAssigned`, `UserAssigned`, or `SystemAssigned, UserAssigned` (to enable both).
    `identity_ids` | Specifies a list of User Assigned Managed Identity IDs to be assigned to this Windows Virtual Machine.
  EOT

  type = object({
    type         = optional(string)
    identity_ids = optional(list(string))
  })

  default = null
}

variable "image" {
  description = <<-EOT
    The URN or URN alias of the operating system image. Valid URN format is `Publisher:Offer:SKU:Version`. Use `az vm image list` to list possible URN values.

    Valid URN aliases are:
    - `Win2022Datacenter`
    - `Win2022AzureEditionCore`
    - `Win2019Datacenter`
    - `Win2016Datacenter`
    - `Win2012R2Datacenter`
    - `Win2012Datacenter`
  EOT

  type    = string
  default = "MicrosoftSQLServer:SQL2019-WS2019:Standard:latest"
}

# variable "key_vault_credential_key_vault_url" {
#   description = "The URL of the Azure Key Vault to store credentials."
#   type        = string
# }
#
# variable "key_vault_credential_name" {
#   description = "The name of the Key Vault credential."
#   type        = string
# }
#
# variable "key_vault_credential_service_principal_name" {
#   description = "The service principal name for accessing the Key Vault."
#   type        = string
# }
#
# variable "key_vault_credential_service_principal_secret" {
#   description = "The secret for the service principal to access the Key Vault."
#   type        = string
# }

variable "r_services_enabled" {
  description = "Enable or disable R services for the MSSQL virtual machine."
  type        = bool
  default     = null
}

variable "key_vault_id" {
  description = "Key Vault ID to store the generated admin password. Required when admin_password is not set."
  default     = null
  type        = string

  # validation {
  #   condition = var.key_vault_id == null ? (
  #     (var.authentication_type == "Password" && var.admin_password != null) || (var.authentication_type == "SSH" && var.admin_ssh_public_key != null)
  #     ) : (
  #     (var.authentication_type == "Password" && var.admin_password == null) || (var.authentication_type == "SSH" && var.admin_ssh_public_key == null)
  #   )
  #   error_message = "Invalid combination of key_vault_id, admin_password, and admin_ssh_public_key. If key_vault_id is null, admin_password or admin_ssh_public_key must be non-null. If key_vault_id is not null, admin_password and admin_ssh_public_key must be null."
  # }
}

variable "location" {
  description = "The Azure location where the virtual machine should reside."
  type        = string
  default     = null
}

variable "name" {
  description = "The name of the virtual machine. Changing this forces a new resource to be created."
  type        = string
  default     = null
}

variable "os_disk" {
  description = <<-EOT
    Operating system disk parameters.

    Optional parameters:

    Parameter | Description
    -- | --
    `caching` | The Type of Caching which should be used for the Internal OS Disk. Possible values are `None`, `ReadOnly` and `ReadWrite`.
    `disk_encryption_set_id` | The ID of the Disk Encryption Set which should be used to Encrypt this OS Disk. Conflicts with `secure_vm_disk_encryption_set_id`.
    || **NOTE**: The Disk Encryption Set must have the Reader Role Assignment scoped on the Key Vault - in addition to an Access Policy to the Key Vault.
    `disk_size_gb` | The Size of the Internal OS Disk in GB, if you wish to vary from the size used in the image this Virtual Machine is sourced from.
    || **NOTE**: If specified this must be equal to or larger than the size of the Image the Virtual Machine is based on. When creating a larger disk than exists in the image you'll need to repartition the disk to use the remaining space.
    `name` | The name which should be used for the Internal OS Disk. Default is `name` prefixed with `osdisk-`.
    `security_encryption_type` | Encryption Type when the Virtual Machine is a Confidential VM. Possible values are `VMGuestStateOnly` and `DiskWithVMGuestState`.
    || **NOTE**: `vtpm_enabled` must be set to true when `security_encryption_type` is specified.
    || **NOTE**: `encryption_at_host_enabled` cannot be set to true when `security_encryption_type` is set to `DiskWithVMGuestState`.
    `secure_vm_disk_encryption_set_id` | The ID of the Disk Encryption Set which should be used to Encrypt this OS Disk when the Virtual Machine is a Confidential VM. Conflicts with `disk_encryption_set_id`.
    || **NOTE**: `secure_vm_disk_encryption_set_id` can only be specified `when security_encryption_type` is set to `DiskWithVMGuestState`.
    `storage_account_type` | The Type of Storage Account which should back this the Internal OS Disk. Possible values are `Standard_LRS`, `StandardSSD_LRS`, `Premium_LRS`, `StandardSSD_ZRS` and `Premium_ZRS`.
    `write_accelerator_enabled` | Should Write Accelerator be Enabled for this OS Disk? Defaults to `false`.
    || **NOTE**: This requires that the `storage_account_type` is set to `Premium_LRS` and that `caching` is set to `None`.
  EOT

  type = object({
    caching                          = optional(string, "ReadWrite")
    disk_size_gb                     = optional(string)
    name                             = optional(string)
    storage_account_type             = optional(string, "Premium_LRS")
    disk_encryption_set_id           = optional(string)
    write_accelerator_enabled        = optional(bool, false)
    secure_vm_disk_encryption_set_id = optional(string)
    security_encryption_type         = optional(string)
  })

  default = {
    caching                   = "ReadWrite"
    storage_account_type      = "Premium_LRS"
    write_accelerator_enabled = false
  }
}

variable "resource_group_name" {
  description = "The name of the resource group to deploy the MSSQL server. This should match the resource group used in the Virtual Machine module to ensure all related resources are managed within the same group."
  type        = string
  default     = null
}

variable "size" {
  description = <<-EOT
    The [SKU](https://cloudprice.net/) to use for this virtual machine.

    Common sizes:
    - `Standard_B2s`
    - `Standard_B2ms`
    - `Standard_D2s_v5`
    - `Standard_D4s_v5`
    - `Standard_DC2s_v2`
    - `Standard_DS1_v2`
    - `Standard_DS2_v2`
    - `Standard_E4s_v5`
    - `Standard_E4bds_v5`
    - `Standard_F2s_v2`
    - `Standard_F4s_v2`
  EOT

  type    = string
  default = "Standard_DS1_v2"
}

variable "sql_connectivity_port" {
  description = "The port number for SQL Server connectivity."
  type        = number
  default     = null
}

variable "sql_connectivity_type" {
  description = "The SQL connectivity type. Possible values are 'LOCAL', 'PRIVATE', and 'PUBLIC'."
  type        = string
  default     = null
}

variable "sql_instance_adhoc_workloads_optimization_enabled" {
  description = "Specifies if the SQL Server is optimized for adhoc workloads. Possible values are true and false. Defaults to false."
  type        = bool
  default     = false
}

variable "sql_instance_collation" {
  description = "Collation of the SQL Server. Defaults to SQL_Latin1_General_CP1_CI_AS. Changing this forces a new resource to be created."
  type        = string
  default     = "SQL_Latin1_General_CP1_CI_AS"
}

variable "sql_instance_instant_file_initialization_enabled" {
  description = "Specifies if Instant File Initialization is enabled for the SQL Server. Possible values are true and false. Defaults to false. Changing this forces a new resource to be created."
  type        = bool
  default     = false
}

variable "sql_instance_lock_pages_in_memory_enabled" {
  description = "Specifies if Lock Pages in Memory is enabled for the SQL Server. Possible values are true and false. Defaults to false. Changing this forces a new resource to be created."
  type        = bool
  default     = false
}

variable "sql_instance_max_dop" {
  description = "Maximum Degree of Parallelism of the SQL Server. Possible values are between 0 and 32767. Defaults to 0."
  type        = number
  default     = 0
  validation {
    condition     = var.sql_instance_max_dop >= 0 && var.sql_instance_max_dop <= 32767
    error_message = "The Maximum Degree of Parallelism (max_dop) must be between 0 and 32767."
  }
}

# variable "sql_instance_max_server_memory_mb" {
#   description = "Maximum amount of memory that SQL Server Memory Manager can allocate to the SQL Server process. Possible values are between 128 and 2147483647. Defaults to 2147483647."
#   type        = number
#   default     = null
#   validation {
#     condition     = var.sql_instance_max_server_memory_mb >= 128 && var.sql_instance_max_server_memory_mb <= 2147483647
#     error_message = "Max server memory must be between 128 and 2147483647 MB."
#   }
# }
#
# variable "sql_instance_min_server_memory_mb" {
#   description = "Minimum amount of memory that SQL Server Memory Manager can allocate to the SQL Server process. Possible values are between 0 and 2147483647. Defaults to 0."
#   type        = number
#   default     = null
#   validation {
#     condition     = var.sql_instance_min_server_memory_mb >= 0 && var.sql_instance_min_server_memory_mb <= var.sql_instance_max_server_memory_mb
#     error_message = "Min server memory must be between 0 and the maximum memory setting."
#   }
# }

variable "sql_license_type" {
  description = "The SQL Server license type (PAYG or AHUB)."
  type        = string
  default     = null
}

# variable "storage_configuration_data_settings" {
#   description = "The Logical Unit Numbers (LUNs) for the attached disks."
#   type        = list(number)
#   default     = null
# }
#
# variable "storage_configuration_data_settings_default_file_path" {
#   description = "The default file path for the data settings in the storage configuration."
#   type        = string
# }
#
# variable "storage_configuration_data_settings_luns" {
#   description = "The Logical Unit Numbers (LUNs) for the data settings in the storage configuration."
#   type        = list(number)
# }
#
# variable "storage_configuration_disk_type" {
#   description = "The disk type for storage configuration. Possible values include 'Premium_LRS', 'Standard_LRS', etc."
#   type        = string
#   default     = "Premium_LRS"
# }
#
# variable "storage_configuration_log_settings" {
#   description = "The Logical Unit Numbers (LUNs) for the attached disks."
#   type        = list(number)
#   default     = null
# }
#
# variable "storage_configuration_log_settings_default_file_path" {
#   description = "The default file path for the log settings in the storage configuration."
#   type        = string
# }
#
# variable "storage_configuration_log_settings_luns" {
#   description = "The Logical Unit Numbers (LUNs) for the log settings in the storage configuration."
#   type        = list(number)
# }
#
# variable "storage_configuration_storage_workload_type" {
#   description = "The workload type for the storage configuration. Possible values include 'GeneralPurpose', 'OLTP', etc."
#   type        = string
#   default     = "GeneralPurpose"
# }

variable "tags" {
  description = "Tags to assign to the resources."
  type        = map(string)
  default     = {}
}

variable "store_secret_in_key_vault" {
  description = "If set to `true`, the secrets generated by this module will be stored in the Key Vault specified by `key_vault_id`."
  type        = bool
  default     = true
}

variable "subnet_id" {
  default     = null
  description = "The ID of the subnet where the virtual machine's primary network interface should be located."
  type        = string
}
