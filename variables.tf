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

variable "allow_extension_operations" {
  description = "Should Extension Operations be allowed on this Virtual Machine?"
  type        = bool
  default     = true
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
  description = "Frequency of log backups, in minutes. Valid values are from 5 to 60."
  type        = number
  default     = 5
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
}

variable "bypass_platform_safety_checks_on_user_schedule_enabled" {
  description = <<-EOT
    Specifies whether to skip platform scheduled patching when a user schedule is associated with the VM.

    **NOTE**: Can only be set to true when `patch_mode` is set to `AutomaticByPlatform`.
  EOT

  type    = bool
  default = true
}

variable "computer_name" {
  description = <<-EOT
    Specifies the hostname to use for this virtual machine. If unspecified, it defaults to `name`.
  EOT

  type    = string
  default = null

  validation {
    condition     = var.computer_name != null ? length(var.computer_name) <= 15 : true
    error_message = "Windows computer name can be at most 15 characters."
  }
}

variable "create_public_ip_address" {
  description = "If set to `true` a Azure public IP address will be created and assigned to the default network interface."
  default     = false
  type        = bool
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

variable "enable_automatic_updates" {
  description = "Specifies whether Automatic Updates are enabled for Windows Virtual Machines. This feature is not supported on Linux Virtual Machines."

  type    = bool
  default = true
}

variable "enable_backup_protected_vm" {
  description = "Enable (`true`) or disable (`false`) a backup protected VM."
  type        = bool
  default     = true
}

variable "enable_sql_instance" {
  description = "A boolean flag to enable or disable the SQL instance configuration."
  type        = bool
  default     = true
}

variable "encryption_at_host_enabled" {
  description = <<-EOT
    Should all of the disks (including the temp disk) attached to this Virtual Machine be encrypted by enabling Encryption at Host?

    **NOTE**: Requires `Microsoft.Compute/EncryptionAtHost` to be enabled at the subscription level.
  EOT

  type    = bool
  default = true
}

variable "extensions" {
  description = <<-EOT
    List of extensions to enable.

    Possible values:
    - `NetworkWatcherAgent`
    - `AzureMonitorAgent`
    - `AzurePolicy`
    - `AntiMalware`
  EOT

  type = list(string)

  default = [
    "NetworkWatcherAgent",
    "AzureMonitorAgent",
    "AzurePolicy",
    "AntiMalware",
  ]
}

variable "hotpatching_enabled" {

  description = <<-EOT
    Should the Windows VM be patched without requiring a reboot? [more infos](https://learn.microsoft.com/windows-server/get-started/hotpatch)

    **NOTE**: Hotpatching can only be enabled if the `patch_mode` is set to `AutomaticByPlatform`, the `provision_vm_agent` is set to `true`, your `source_image_reference` references a hotpatching enabled image, and the VM's `size` is set to a [Azure generation 2 VM](https://learn.microsoft.com/en-gb/azure/virtual-machines/generation-2#generation-2-vm-sizes).

    **CAUTION**: The setting `bypass_platform_safety_checks_on_user_schedule_enabled` is set to `true` by default. To enable hotpatching, change it to `false`.
  EOT

  type = bool

  default = false

  validation {
    condition     = var.hotpatching_enabled == true ? true : var.bypass_platform_safety_checks_on_user_schedule_enabled
    error_message = "Only one of the following options can be set to true: either bypass_platform_safety_checks_on_user_schedule_enabled or hotpatching_enabled."
  }
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

    Alternative SQL Images:
    - `MicrosoftSQLServer:sql2022-sles15:enterprise-gen2:latest`
    - `MicrosoftSQLServer:sql2022-sles15:sqldev-gen2:latest`
    - `MicrosoftSQLServer:sql2022-sles15:standard-gen2:latest`
    - `MicrosoftSQLServer:sql2022-sles15:web-gen2:latest`
    - `MicrosoftSQLServer:sql2022-ws2022:enterprise-gen2:latest`
    - `MicrosoftSQLServer:sql2022-ws2022:sqldev-gen2:latest`
    - `MicrosoftSQLServer:sql2022-ws2022:standard-gen2:latest`
    - `MicrosoftSQLServer:sql2022-ws2022:web-gen2:latest`
  EOT

  type    = string
  default = "MicrosoftSQLServer:sql2022-ws2022:standard-gen2:latest"
}

variable "key_vault_id" {
  description = "Key Vault ID to store the generated admin password. Required when admin_password is not set."
  default     = null
  type        = string
}

variable "location" {
  description = "The Azure location where the virtual machine should reside."
  type        = string
  default     = null
}

variable "max_server_memory_percent" {
  description = "Maximum server memory as a percentage of the total memory. Used if max_server_memory_mb is not provided."
  type        = number
  default     = 80
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

variable "patch_assessment_mode" {
  description = <<-EOT
    Specifies the mode of VM Guest Patching for the Virtual Machine. Possible values are AutomaticByPlatform or ImageDefault.

    **NOTE**: If the `patch_assessment_mode` is set to `AutomaticByPlatform` then the `provision_vm_agent` field must be set to `true`.

    Possible values:
    - `AutomaticByPlatform`
    - `ImageDefault`
  EOT

  type    = string
  default = "AutomaticByPlatform"
}

variable "patch_mode" {
  description = <<-EOT
    Specifies the mode of in-guest patching to this Windows Virtual Machine. For more information on patch modes please see the [product documentation](https://docs.microsoft.com/azure/virtual-machines/automatic-vm-guest-patching#patch-orchestration-modes).

    **NOTE**: If `patch_mode` is set to `AutomaticByPlatform` then `provision_vm_agent` must also be set to true. If the Virtual Machine is using a hotpatching enabled image the `patch_mode` must always be set to `AutomaticByPlatform`.

    Possible values:
    - `AutomaticByOS`
    - `AutomaticByPlatform`
    - `Manual`
  EOT

  type    = string
  default = "AutomaticByPlatform"
}

variable "private_ip_address" {
  description = "The static IP address to use. If not set (default), a dynamic IP address is assigned."
  default     = null
  type        = string
}

variable "r_services_enabled" {
  description = "Enable or disable R services for the MSSQL virtual machine."
  type        = bool
  default     = null
}

variable "resource_group_name" {
  description = "The name of the resource group to deploy the MSSQL server. This should match the resource group used in the Virtual Machine module to ensure all related resources are managed within the same group."
  type        = string
  default     = null
}

variable "secure_boot_enabled" {
  description = "Specifies whether secure boot should be enabled on the virtual machine."

  type    = bool
  default = true
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

variable "sql_instance_max_server_memory_mb" {
  description = "Maximum amount of memory that SQL Server Memory Manager can allocate to the SQL Server process. Possible values are between 128 and 2147483647. Defaults to 2147483647."
  type        = number
  default     = 128
}

variable "sql_instance_min_server_memory_mb" {
  description = "Minimum amount of memory that SQL Server Memory Manager can allocate to the SQL Server process. Possible values are between 0 and 2147483647. Defaults to 0."
  type        = number
  default     = 0
  validation {
    condition     = var.sql_instance_min_server_memory_mb >= 0 && var.sql_instance_min_server_memory_mb <= var.sql_instance_max_server_memory_mb
    error_message = "Min server memory must be between 0 and the maximum memory setting."
  }
}

variable "sql_license_type" {
  description = "The SQL Server license type (PAYG or AHUB)."
  type        = string
  default     = "PAYG"
}

variable "storage_configuration" {
  description = <<-EOT
    # TODO
  EOT


  default = null

  type = object({
    disk_type                      = string
    storage_workload_type          = string
    system_db_on_data_disk_enabled = optional(bool, false)

    data_settings = optional(object({
      default_file_path = string
      luns              = optional(list(number), [])

      # disk settings
      disk_size_gb = optional(number)

      caching = optional(string, "ReadWrite")
      # create_option        = "Empty" ? related to disk_type ?
      storage_account_type = optional(string, "Premium_LRS") # or UltraSSD_LRS
    }))

    log_settings = optional(object({
      default_file_path = string
      luns              = optional(list(number), [])

      # disk settings
      disk_size_gb = optional(number)
      caching      = optional(string, "ReadWrite")
      # create_option        = "Empty" ? related to disk_type ?
      storage_account_type = optional(string, "Premium_LRS") # or UltraSSD_LRS
    }))

    temp_db_settings = optional(object({
      default_file_path = string
      luns              = optional(list(number), [])

      data_file_count        = optional(number, 8)
      data_file_size_mb      = optional(number, 256)
      data_file_growth_in_mb = optional(number, 512)
      log_file_size_mb       = optional(number, 256)
      log_file_growth_mb     = optional(number, 512)

      # disk settings
      disk_size_gb = optional(number)
      caching      = optional(string, "ReadWrite")
      # create_option        = "Empty" ? related to disk_type ?
      storage_account_type = optional(string, "Premium_LRS") # or UltraSSD_LRSÏ
    }))
  })
  validation {
    condition = var.storage_configuration == null ? true : (var.storage_configuration.temp_db_settings == null ? true : (
      length(var.storage_configuration.temp_db_settings.luns) > 0 && var.storage_configuration.temp_db_settings.disk_size_gb != null
      ||
      length(var.storage_configuration.temp_db_settings.luns) == 0 && var.storage_configuration.temp_db_settings.disk_size_gb == null
    ))
    error_message = "If var.storage_configuration.temp_db_settings.luns is provided you must provide the var.storage_configuration.temp_db_settings.disk_size_gb too. If var.storage_configuration.temp_db_settings.luns is not provided please leave the var.storage_configuration.temp_db_settings.disk_size_gb empty too."
  }
  validation {
    condition = var.storage_configuration == null ? true : (var.storage_configuration.log_settings == null ? true : (
      length(var.storage_configuration.log_settings.luns) > 0 && var.storage_configuration.log_settings.disk_size_gb != null
      ||
      length(var.storage_configuration.log_settings.luns) == 0 && var.storage_configuration.log_settings.disk_size_gb == null
    ))
    error_message = "If var.storage_configuration.log_settings.luns is provided you must provide the var.storage_configuration.log_settings.disk_size_gb too. If var.storage_configuration.log_settings.luns is not provided please leave the var.storage_configuration.log_settings.disk_size_gb empty too."
  }
  validation {
    condition = var.storage_configuration == null ? true : (var.storage_configuration.data_settings == null ? true : (
      length(var.storage_configuration.data_settings.luns) > 0 && var.storage_configuration.data_settings.disk_size_gb != null
      ||
      length(var.storage_configuration.data_settings.luns) == 0 && var.storage_configuration.data_settings.disk_size_gb == null
    ))
    error_message = "If var.storage_configuration.data_settings.luns is provided you must provide the var.storage_configuration.data_settings.disk_size_gb too. If var.storage_configuration.data_settings.luns is not provided please leave the var.storage_configuration.data_settings.disk_size_gb empty too."
  }
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

variable "tags" {
  description = "A mapping of tags which should be assigned to all resources in this module."

  type    = map(string)
  default = {}
}

variable "tags_virtual_machine" {
  description = "A mapping of tags which should be assigned to the Virtual Machine. This map will be merged with `tags`."

  type    = map(string)
  default = {}
}

variable "timezone" {
  description = "Specifies the Time Zone which should be used by the Virtual Machine, [the possible values are defined here](https://jackstromberg.com/2017/01/list-of-time-zones-consumed-by-azure/). Setting timezone is not supported on Linux Virtual Machines."

  type    = string
  default = null
}

variable "vtpm_enabled" {
  description = "Specifies if vTPM (virtual Trusted Platform Module) and Trusted Launch is enabled for the Virtual Machine."

  type    = bool
  default = true
}

variable "zone" {
  description = "Availability Zone in which this Windows Virtual Machine should be located."

  type    = string
  default = null
}
