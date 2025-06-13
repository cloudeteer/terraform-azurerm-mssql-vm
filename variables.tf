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

variable "backup_policy_id" {
  description = "The ID of the backup policy to use."
  type        = string
  default     = null
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
    `create_option` | The method to use when creating the managed disk. Possible values include: `Empty` - Create an empty managed disk. `Copy` - Copy an existing managed disk or snapshot (specified with `source_resource_id`). `Restore` - Set by Azure Backup or Site Recovery on a restored disk (specified with `source_resource_id`).
    `name` | Specifies the name of the Managed Disk. If omitted a name will be generated based on `name`.
    `source_resource_id` | The ID of an existing Managed Disk or Snapshot to copy when `create_option` is `Cop`y or the recovery point to restore when `create_option` is `Restore`.
    `storage_account_type` | The type of storage to use for the managed disk. Possible values are `Standard_LRS`, `StandardSSD_ZRS`, `Premium_LRS`, `PremiumV2_LRS`, `Premium_ZRS`, `StandardSSD_LRS` or `UltraSSD_LRS`.
  EOT

  type = list(object({
    caching              = optional(string, "ReadWrite")
    create_option        = optional(string, "Empty")
    disk_size_gb         = number
    lun                  = number
    name                 = optional(string)
    source_resource_id   = optional(string)
    storage_account_type = optional(string, "Premium_LRS")
  }))

  default = []
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

  # TODO: Should be updated on new releases
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

variable "sql_connectivity_update_password" {
  description = "The SQL Server sysadmin login password."
  type        = string
  default     = null
  sensitive   = true
}

variable "sql_connectivity_update_username" {
  description = "The SQL Server sysadmin login to create."
  type        = string
  default     = "sqladmin"
}

variable "sql_instance" {

  description = <<-DESCRIPTION
    SQL instance parameters.

    Optional parameters:

    Parameter | Description
    -- | --
    `adhoc_workloads_optimization_enabled` | Specifies if the SQL Server is optimized for adhoc workloads. Possible values are true and false.
    `collation` | Collation of the SQL Server. Defaults to SQL_Latin1_General_CP1_CI_AS. Changing this forces a new resource to be created.
    `instant_file_initialization_enabled` | Specifies if Instant File Initialization is enabled for the SQL Server. Possible values are true and false. Changing this forces a new resource to be created.
    `lock_pages_in_memory_enabled` | Specifies if Lock Pages in Memory is enabled for the SQL Server. Possible values are true and false. Changing this forces a new resource to be created.
    `max_dop` | Maximum Degree of Parallelism of the SQL Server. Possible values are between 0 and 32767.
    `max_server_memory_mb` | Maximum amount of memory that SQL Server Memory Manager can allocate to the SQL Server process. Possible values are between 128 and 2147483647.
    `min_server_memory_mb` | Minimum amount of memory that SQL Server Memory Manager can allocate to the SQL Server process. Possible values are between 0 and 2147483647.

  DESCRIPTION

  type = object({
    adhoc_workloads_optimization_enabled = optional(bool, false)
    collation                            = optional(string, "SQL_Latin1_General_CP1_CI_AS")
    instant_file_initialization_enabled  = optional(bool, false)
    lock_pages_in_memory_enabled         = optional(bool, false)
    max_dop                              = optional(number, 0)
    max_server_memory_mb                 = optional(number, 128)
    min_server_memory_mb                 = optional(number, 0)
  })

  default = {}

  validation {
    condition     = var.sql_instance.max_dop >= 0 && var.sql_instance.max_dop <= 32767
    error_message = "The Maximum Degree of Parallelism (max_dop) must be between 0 and 32767."
  }

  validation {
    condition     = var.sql_instance.min_server_memory_mb >= 0 && var.sql_instance.min_server_memory_mb <= var.sql_instance.max_server_memory_mb
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
      caching              = optional(string, "ReadWrite")
      default_file_path    = optional(string, "F:\\data")
      disk_size_gb         = optional(number)
      luns                 = optional(list(number), [])
      storage_account_type = optional(string, "Premium_LRS") # or UltraSSD_LRS
    }))

    log_settings = optional(object({
      caching              = optional(string, "ReadWrite")
      default_file_path    = optional(string, "G:\\log")
      disk_size_gb         = optional(number)
      luns                 = optional(list(number), [])
      storage_account_type = optional(string, "Premium_LRS") # or UltraSSD_LRS
    }))

    temp_db_settings = optional(object({
      caching                = optional(string, "ReadWrite")
      data_file_count        = optional(number, 8)
      data_file_growth_in_mb = optional(number, 512)
      data_file_size_mb      = optional(number, 256)
      default_file_path      = optional(string, "H:\\tempdb")
      disk_size_gb           = optional(number)
      log_file_growth_mb     = optional(number, 512)
      log_file_size_mb       = optional(number, 256)
      luns                   = optional(list(number), [])
      storage_account_type   = optional(string, "Premium_LRS") # or UltraSSD_LRSÏ
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
  description = <<-DESCRIPTION
    A mapping of tags to assign specifically to the Virtual Machine resource. These tags will be merged with the `tags` variable.

    **NOTE**: By default, this module adds the tag `tags_virtual_machine` with a value of `95` to the Virtual Machine. You can override this default by specifying the `tags_virtual_machine` key in this variable.
  DESCRIPTION

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
