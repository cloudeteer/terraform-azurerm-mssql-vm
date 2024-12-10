<!-- markdownlint-disable first-line-h1 no-inline-html -->

> [!NOTE]
> This repository is publicly accessible as part of our open-source initiative. We welcome contributions from the community alongside our organization's primary development efforts.

---

# terraform-module-template

[![SemVer](https://img.shields.io/badge/SemVer-2.0.0-blue.svg)]

Terraform Module Template

<!-- BEGIN_TF_DOCS -->
## Usage

This example demonstrates the usage of this Terraform module with default settings.

```hcl
resource "azurerm_resource_group" "example" {
  name     = "rg-example-dev-euw-01"
  location = "westeurope"
}

resource "azurerm_virtual_network" "example" {
  name                = "vnet-example-dev-euw-01"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  address_space = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "example" {
  name                = "snet-example-dev-euw-01"
  resource_group_name = azurerm_resource_group.example.name

  address_prefixes     = ["10.0.2.0/24"]
  virtual_network_name = azurerm_virtual_network.example.name
}

resource "azurerm_recovery_services_vault" "example" {
  name                = "rsv-example-dev-euw-01"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  sku                 = "Standard"
  soft_delete_enabled = false
  storage_mode_type   = "GeoRedundant"
}

resource "azurerm_backup_policy_vm" "example" {
  name                = "bkpvm-example-dev-euw-01"
  resource_group_name = azurerm_resource_group.example.name

  policy_type         = "V2"
  recovery_vault_name = azurerm_recovery_services_vault.example.name
  timezone            = "UTC"

  backup {
    frequency = "Daily"
    time      = "23:00"
  }

  retention_daily {
    count = 30
  }
}

data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "example" {
  name                = "kv-example-dev-euw-01"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  purge_protection_enabled = false
  sku_name                 = "standard"
  tenant_id                = data.azurerm_client_config.current.tenant_id

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    secret_permissions = ["Backup", "Delete", "Get", "List", "Purge", "Recover", "Restore", "Set"]
  }
}

module "example" {
  source = "cloudeteer/mssql-vm/azurerm"

  name                = "vm-example-dev-euw-01"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  backup_policy_id = azurerm_backup_policy_vm.example.id
  key_vault_id     = azurerm_key_vault.example.id
  subnet_id        = azurerm_subnet.example.id

  computer_name = "example"
}
```

## Providers

The following providers are used by this module:

- <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) (>= 4.1)

- <a name="provider_time"></a> [time](#provider\_time) (>= 0.12)

## Modules

The following Modules are called:

### <a name="module_azurerm_virtual_machine"></a> [azurerm\_virtual\_machine](#module\_azurerm\_virtual\_machine)

Source: cloudeteer/vm/azurerm

Version: 0.0.20

## Resources

The following resources are used by this module:

- [azurerm_mssql_virtual_machine.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mssql_virtual_machine) (resource)
- [time_sleep.wait_60_seconds](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) (resource)


## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_admin_password"></a> [admin\_password](#input\_admin\_password)

Description: Password to use for the local administrator on this virtual machine. If not set, a password will be generated and stored in the Key Vault specified by key\_vault\_id.

Type: `string`

Default: `null`

### <a name="input_admin_username"></a> [admin\_username](#input\_admin\_username)

Description: Username of the local administrator for the virtual machine.

Type: `string`

Default: `"azureadmin"`

### <a name="input_allow_extension_operations"></a> [allow\_extension\_operations](#input\_allow\_extension\_operations)

Description: Should Extension Operations be allowed on this Virtual Machine?

Type: `bool`

Default: `true`

### <a name="input_auto_backup_encryption_enabled"></a> [auto\_backup\_encryption\_enabled](#input\_auto\_backup\_encryption\_enabled)

Description: A boolean flag to specify whether encryption is enabled for backups.

Type: `bool`

Default: `false`

### <a name="input_auto_backup_encryption_password"></a> [auto\_backup\_encryption\_password](#input\_auto\_backup\_encryption\_password)

Description: The password used to encrypt backups if encryption is enabled. Must be specified when encryption is enabled.

Type: `string`

Default: `""`

### <a name="input_auto_backup_manual_schedule_full_backup_frequency"></a> [auto\_backup\_manual\_schedule\_full\_backup\_frequency](#input\_auto\_backup\_manual\_schedule\_full\_backup\_frequency)

Description: Frequency of full backups. Possible values: 'Daily', 'Weekly'.

Type: `string`

Default: `"Weekly"`

### <a name="input_auto_backup_manual_schedule_full_backup_start_hour"></a> [auto\_backup\_manual\_schedule\_full\_backup\_start\_hour](#input\_auto\_backup\_manual\_schedule\_full\_backup\_start\_hour)

Description: The hour of the day to start full backups, in 24-hour format (0-23).

Type: `number`

Default: `null`

### <a name="input_auto_backup_manual_schedule_full_backup_window_in_hours"></a> [auto\_backup\_manual\_schedule\_full\_backup\_window\_in\_hours](#input\_auto\_backup\_manual\_schedule\_full\_backup\_window\_in\_hours)

Description: The number of hours the full backup operation can run.

Type: `number`

Default: `null`

### <a name="input_auto_backup_manual_schedule_log_backup_frequency_in_minutes"></a> [auto\_backup\_manual\_schedule\_log\_backup\_frequency\_in\_minutes](#input\_auto\_backup\_manual\_schedule\_log\_backup\_frequency\_in\_minutes)

Description: Frequency of log backups, in minutes. Valid values are from 5 to 60.

Type: `number`

Default: `5`

### <a name="input_auto_backup_retention_period_in_days"></a> [auto\_backup\_retention\_period\_in\_days](#input\_auto\_backup\_retention\_period\_in\_days)

Description: The number of days to retain backups for the SQL virtual machine.

Type: `number`

Default: `null`

### <a name="input_auto_backup_storage_account_access_key"></a> [auto\_backup\_storage\_account\_access\_key](#input\_auto\_backup\_storage\_account\_access\_key)

Description: The access key for the storage account to store SQL Server backups.

Type: `string`

Default: `null`

### <a name="input_auto_backup_storage_blob_endpoint"></a> [auto\_backup\_storage\_blob\_endpoint](#input\_auto\_backup\_storage\_blob\_endpoint)

Description: The storage blob endpoint for the backup of the SQL virtual machine.

Type: `string`

Default: `null`

### <a name="input_auto_backup_system_databases_backup_enabled"></a> [auto\_backup\_system\_databases\_backup\_enabled](#input\_auto\_backup\_system\_databases\_backup\_enabled)

Description: A boolean flag to specify whether system databases are included in the backup.

Type: `bool`

Default: `false`

### <a name="input_auto_patching_day_of_week"></a> [auto\_patching\_day\_of\_week](#input\_auto\_patching\_day\_of\_week)

Description: The day of the week for auto patching. Possible values: 'Sunday', 'Monday', etc.

Type: `string`

Default: `null`

### <a name="input_auto_patching_maintenance_window_duration_in_minutes"></a> [auto\_patching\_maintenance\_window\_duration\_in\_minutes](#input\_auto\_patching\_maintenance\_window\_duration\_in\_minutes)

Description: The duration of the maintenance window in minutes for auto patching.

Type: `number`

Default: `null`

### <a name="input_auto_patching_maintenance_window_starting_hour"></a> [auto\_patching\_maintenance\_window\_starting\_hour](#input\_auto\_patching\_maintenance\_window\_starting\_hour)

Description: The starting hour (0-23) of the maintenance window for auto patching.

Type: `number`

Default: `null`

### <a name="input_backup_policy_id"></a> [backup\_policy\_id](#input\_backup\_policy\_id)

Description: The ID of the backup policy to use.

Type: `string`

Default: `null`

### <a name="input_bypass_platform_safety_checks_on_user_schedule_enabled"></a> [bypass\_platform\_safety\_checks\_on\_user\_schedule\_enabled](#input\_bypass\_platform\_safety\_checks\_on\_user\_schedule\_enabled)

Description: Specifies whether to skip platform scheduled patching when a user schedule is associated with the VM.

**NOTE**: Can only be set to true when `patch_mode` is set to `AutomaticByPlatform`.

Type: `bool`

Default: `true`

### <a name="input_computer_name"></a> [computer\_name](#input\_computer\_name)

Description: Specifies the hostname to use for this virtual machine. If unspecified, it defaults to `name`.

Type: `string`

Default: `null`

### <a name="input_create_public_ip_address"></a> [create\_public\_ip\_address](#input\_create\_public\_ip\_address)

Description: If set to `true` a Azure public IP address will be created and assigned to the default network interface.

Type: `bool`

Default: `false`

### <a name="input_days_of_week"></a> [days\_of\_week](#input\_days\_of\_week)

Description: A list of days on which backup can take place. Possible values are Monday, Tuesday, Wednesday, Thursday, Friday, Saturday and Sunday

Type: `string`

Default: `null`

### <a name="input_enable_auto_backup"></a> [enable\_auto\_backup](#input\_enable\_auto\_backup)

Description: A boolean flag to enable or disable automatic backups for SQL backups.

Type: `bool`

Default: `false`

### <a name="input_enable_auto_patching"></a> [enable\_auto\_patching](#input\_enable\_auto\_patching)

Description: A boolean flag to enable or disable auto patching.

Type: `bool`

Default: `false`

### <a name="input_enable_automatic_updates"></a> [enable\_automatic\_updates](#input\_enable\_automatic\_updates)

Description: Specifies whether Automatic Updates are enabled for Windows Virtual Machines. This feature is not supported on Linux Virtual Machines.

Type: `bool`

Default: `true`

### <a name="input_enable_backup_protected_vm"></a> [enable\_backup\_protected\_vm](#input\_enable\_backup\_protected\_vm)

Description: Enable (`true`) or disable (`false`) a backup protected VM.

Type: `bool`

Default: `true`

### <a name="input_enable_sql_instance"></a> [enable\_sql\_instance](#input\_enable\_sql\_instance)

Description: A boolean flag to enable or disable the SQL instance configuration.

Type: `bool`

Default: `true`

### <a name="input_encryption_at_host_enabled"></a> [encryption\_at\_host\_enabled](#input\_encryption\_at\_host\_enabled)

Description: Should all of the disks (including the temp disk) attached to this Virtual Machine be encrypted by enabling Encryption at Host?

**NOTE**: Requires `Microsoft.Compute/EncryptionAtHost` to be enabled at the subscription level.

Type: `bool`

Default: `true`

### <a name="input_extensions"></a> [extensions](#input\_extensions)

Description: List of extensions to enable.

Possible values:
- `NetworkWatcherAgent`
- `AzureMonitorAgent`
- `AzurePolicy`
- `AntiMalware`

Type: `list(string)`

Default:

```json
[
  "NetworkWatcherAgent",
  "AzureMonitorAgent",
  "AzurePolicy",
  "AntiMalware"
]
```

### <a name="input_hotpatching_enabled"></a> [hotpatching\_enabled](#input\_hotpatching\_enabled)

Description: Should the Windows VM be patched without requiring a reboot? [more infos](https://learn.microsoft.com/windows-server/get-started/hotpatch)

**NOTE**: Hotpatching can only be enabled if the `patch_mode` is set to `AutomaticByPlatform`, the `provision_vm_agent` is set to `true`, your `source_image_reference` references a hotpatching enabled image, and the VM's `size` is set to a [Azure generation 2 VM](https://learn.microsoft.com/en-gb/azure/virtual-machines/generation-2#generation-2-vm-sizes).

**CAUTION**: The setting `bypass_platform_safety_checks_on_user_schedule_enabled` is set to `true` by default. To enable hotpatching, change it to `false`.

Type: `bool`

Default: `false`

### <a name="input_identity"></a> [identity](#input\_identity)

Description: The Azure managed identity to assign to the virtual machine.

Optional parameters:

Parameter | Description
-- | --
`type` | Specifies the type of Managed Service Identity that should be configured on this Windows Virtual Machine. Possible values are `SystemAssigned`, `UserAssigned`, or `SystemAssigned, UserAssigned` (to enable both).
`identity_ids` | Specifies a list of User Assigned Managed Identity IDs to be assigned to this Windows Virtual Machine.

Type:

```hcl
object({
    type         = optional(string)
    identity_ids = optional(list(string))
  })
```

Default: `null`

### <a name="input_image"></a> [image](#input\_image)

Description: The URN or URN alias of the operating system image. Valid URN format is `Publisher:Offer:SKU:Version`. Use `az vm image list` to list possible URN values.

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

Type: `string`

Default: `"MicrosoftSQLServer:sql2022-ws2022:standard-gen2:latest"`

### <a name="input_key_vault_id"></a> [key\_vault\_id](#input\_key\_vault\_id)

Description: Key Vault ID to store the generated admin password. Required when admin\_password is not set.

Type: `string`

Default: `null`

### <a name="input_location"></a> [location](#input\_location)

Description: The Azure location where the virtual machine should reside.

Type: `string`

Default: `null`

### <a name="input_max_server_memory_percent"></a> [max\_server\_memory\_percent](#input\_max\_server\_memory\_percent)

Description: Maximum server memory as a percentage of the total memory. Used if max\_server\_memory\_mb is not provided.

Type: `number`

Default: `80`

### <a name="input_name"></a> [name](#input\_name)

Description: The name of the virtual machine. Changing this forces a new resource to be created.

Type: `string`

Default: `null`

### <a name="input_os_disk"></a> [os\_disk](#input\_os\_disk)

Description: Operating system disk parameters.

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

Type:

```hcl
object({
    caching                          = optional(string, "ReadWrite")
    disk_size_gb                     = optional(string)
    name                             = optional(string)
    storage_account_type             = optional(string, "Premium_LRS")
    disk_encryption_set_id           = optional(string)
    write_accelerator_enabled        = optional(bool, false)
    secure_vm_disk_encryption_set_id = optional(string)
    security_encryption_type         = optional(string)
  })
```

Default:

```json
{
  "caching": "ReadWrite",
  "storage_account_type": "Premium_LRS",
  "write_accelerator_enabled": false
}
```

### <a name="input_patch_assessment_mode"></a> [patch\_assessment\_mode](#input\_patch\_assessment\_mode)

Description: Specifies the mode of VM Guest Patching for the Virtual Machine. Possible values are AutomaticByPlatform or ImageDefault.

**NOTE**: If the `patch_assessment_mode` is set to `AutomaticByPlatform` then the `provision_vm_agent` field must be set to `true`.

Possible values:
- `AutomaticByPlatform`
- `ImageDefault`

Type: `string`

Default: `"AutomaticByPlatform"`

### <a name="input_patch_mode"></a> [patch\_mode](#input\_patch\_mode)

Description: Specifies the mode of in-guest patching to this Windows Virtual Machine. For more information on patch modes please see the [product documentation](https://docs.microsoft.com/azure/virtual-machines/automatic-vm-guest-patching#patch-orchestration-modes).

**NOTE**: If `patch_mode` is set to `AutomaticByPlatform` then `provision_vm_agent` must also be set to true. If the Virtual Machine is using a hotpatching enabled image the `patch_mode` must always be set to `AutomaticByPlatform`.

Possible values:
- `AutomaticByOS`
- `AutomaticByPlatform`
- `Manual`

Type: `string`

Default: `"AutomaticByPlatform"`

### <a name="input_private_ip_address"></a> [private\_ip\_address](#input\_private\_ip\_address)

Description: The static IP address to use. If not set (default), a dynamic IP address is assigned.

Type: `string`

Default: `null`

### <a name="input_r_services_enabled"></a> [r\_services\_enabled](#input\_r\_services\_enabled)

Description: Enable or disable R services for the MSSQL virtual machine.

Type: `bool`

Default: `null`

### <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name)

Description: The name of the resource group to deploy the MSSQL server. This should match the resource group used in the Virtual Machine module to ensure all related resources are managed within the same group.

Type: `string`

Default: `null`

### <a name="input_secure_boot_enabled"></a> [secure\_boot\_enabled](#input\_secure\_boot\_enabled)

Description: Specifies whether secure boot should be enabled on the virtual machine.

Type: `bool`

Default: `true`

### <a name="input_size"></a> [size](#input\_size)

Description: The [SKU](https://cloudprice.net/) to use for this virtual machine.

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

Type: `string`

Default: `"Standard_DS1_v2"`

### <a name="input_sql_connectivity_port"></a> [sql\_connectivity\_port](#input\_sql\_connectivity\_port)

Description: The port number for SQL Server connectivity.

Type: `number`

Default: `null`

### <a name="input_sql_connectivity_type"></a> [sql\_connectivity\_type](#input\_sql\_connectivity\_type)

Description: The SQL connectivity type. Possible values are 'LOCAL', 'PRIVATE', and 'PUBLIC'.

Type: `string`

Default: `null`

### <a name="input_sql_instance_adhoc_workloads_optimization_enabled"></a> [sql\_instance\_adhoc\_workloads\_optimization\_enabled](#input\_sql\_instance\_adhoc\_workloads\_optimization\_enabled)

Description: Specifies if the SQL Server is optimized for adhoc workloads. Possible values are true and false. Defaults to false.

Type: `bool`

Default: `false`

### <a name="input_sql_instance_collation"></a> [sql\_instance\_collation](#input\_sql\_instance\_collation)

Description: Collation of the SQL Server. Defaults to SQL\_Latin1\_General\_CP1\_CI\_AS. Changing this forces a new resource to be created.

Type: `string`

Default: `"SQL_Latin1_General_CP1_CI_AS"`

### <a name="input_sql_instance_instant_file_initialization_enabled"></a> [sql\_instance\_instant\_file\_initialization\_enabled](#input\_sql\_instance\_instant\_file\_initialization\_enabled)

Description: Specifies if Instant File Initialization is enabled for the SQL Server. Possible values are true and false. Defaults to false. Changing this forces a new resource to be created.

Type: `bool`

Default: `false`

### <a name="input_sql_instance_lock_pages_in_memory_enabled"></a> [sql\_instance\_lock\_pages\_in\_memory\_enabled](#input\_sql\_instance\_lock\_pages\_in\_memory\_enabled)

Description: Specifies if Lock Pages in Memory is enabled for the SQL Server. Possible values are true and false. Defaults to false. Changing this forces a new resource to be created.

Type: `bool`

Default: `false`

### <a name="input_sql_instance_max_dop"></a> [sql\_instance\_max\_dop](#input\_sql\_instance\_max\_dop)

Description: Maximum Degree of Parallelism of the SQL Server. Possible values are between 0 and 32767. Defaults to 0.

Type: `number`

Default: `0`

### <a name="input_sql_instance_max_server_memory_mb"></a> [sql\_instance\_max\_server\_memory\_mb](#input\_sql\_instance\_max\_server\_memory\_mb)

Description: Maximum amount of memory that SQL Server Memory Manager can allocate to the SQL Server process. Possible values are between 128 and 2147483647. Defaults to 2147483647.

Type: `number`

Default: `128`

### <a name="input_sql_instance_min_server_memory_mb"></a> [sql\_instance\_min\_server\_memory\_mb](#input\_sql\_instance\_min\_server\_memory\_mb)

Description: Minimum amount of memory that SQL Server Memory Manager can allocate to the SQL Server process. Possible values are between 0 and 2147483647. Defaults to 0.

Type: `number`

Default: `0`

### <a name="input_sql_license_type"></a> [sql\_license\_type](#input\_sql\_license\_type)

Description: The SQL Server license type (PAYG or AHUB).

Type: `string`

Default: `"PAYG"`

### <a name="input_storage_configuration"></a> [storage\_configuration](#input\_storage\_configuration)

Description: # TODO

Type:

```hcl
object({
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
```

Default: `null`

### <a name="input_store_secret_in_key_vault"></a> [store\_secret\_in\_key\_vault](#input\_store\_secret\_in\_key\_vault)

Description: If set to `true`, the secrets generated by this module will be stored in the Key Vault specified by `key_vault_id`.

Type: `bool`

Default: `true`

### <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id)

Description: The ID of the subnet where the virtual machine's primary network interface should be located.

Type: `string`

Default: `null`

### <a name="input_tags"></a> [tags](#input\_tags)

Description: A mapping of tags which should be assigned to all resources in this module.

Type: `map(string)`

Default: `{}`

### <a name="input_tags_virtual_machine"></a> [tags\_virtual\_machine](#input\_tags\_virtual\_machine)

Description: A mapping of tags which should be assigned to the Virtual Machine. This map will be merged with `tags`.

Type: `map(string)`

Default: `{}`

### <a name="input_timezone"></a> [timezone](#input\_timezone)

Description: Specifies the Time Zone which should be used by the Virtual Machine, [the possible values are defined here](https://jackstromberg.com/2017/01/list-of-time-zones-consumed-by-azure/). Setting timezone is not supported on Linux Virtual Machines.

Type: `string`

Default: `null`

### <a name="input_vtpm_enabled"></a> [vtpm\_enabled](#input\_vtpm\_enabled)

Description: Specifies if vTPM (virtual Trusted Platform Module) and Trusted Launch is enabled for the Virtual Machine.

Type: `bool`

Default: `true`

### <a name="input_zone"></a> [zone](#input\_zone)

Description: Availability Zone in which this Windows Virtual Machine should be located.

Type: `string`

Default: `null`

<!-- END_TF_DOCS -->

## Contributions

We welcome all kinds of contributions, whether it's reporting bugs, submitting feature requests, or directly contributing to the development. Please read our [Contributing Guidelines](CONTRIBUTING.md) to learn how you can best contribute.

Thank you for your interest and support!

## Copyright and license

<img width=200 alt="Logo" src="https://raw.githubusercontent.com/cloudeteer/cdt-public/main/img/cdt_logo_orig_4c.svg">

© 2024 CLOUDETEER GmbH

This project is licensed under the [MIT License](LICENSE).
