# Development Task List

**Module**: [terraform-azurerm-mssql-vm](https://github.com/cloudeteer/terraform-azurerm-mssql-vm)

## 0. Preparation

Start with these warm-up tasks:

- [X] Review and apply the [Terraform Style Guide](https://github.com/cloudeteer/terraform-governance/blob/main/docs/Development%20-%20Terraform%20Style%20Guide.md).

---

## 1. Pre-Cleanup

Remove unnecessary files and clean the project:

- [X] Remove the `.idea/` folder and add it to `.gitignore`.
    - [X] Update the `.gitignore` in the [module template](https://github.com/cloudeteer/terraform-module-template) to include `.idea/` and `.vscode/`.
- [X] Delete the obsolete `CHANGELOG.md`.
- [X] Remove `versions.tf` (duplicate of `terraform.tf`).

---

## 2. Upgrade

Align the module with the latest cloudeteer standards:

- [X] Update the module with the latest files from the [module template](https://github.com/cloudeteer/terraform-module-template/tree/main):
    - [X] [`renovate.json`](https://github.com/cloudeteer/terraform-module-template/blob/main/renovate.json)
    - [X] [`.pre-commit-config.yaml`](https://github.com/cloudeteer/terraform-module-template/blob/main/.pre-commit-config.yaml)
    - [X] [`Makefile`](https://github.com/cloudeteer/terraform-module-template/blob/main/Makefile)
    - [X] [`.tflint.hcl`](https://github.com/cloudeteer/terraform-module-template/blob/main/.tflint.hcl)
    - [X] [`.tflint.examples.hcl`](https://github.com/cloudeteer/terraform-module-template/blob/main/.tflint.examples.hcl)
    - [X] [`.github/workflows/module-ci.yaml`](https://github.com/cloudeteer/terraform-module-template/blob/main/.github/workflows/module-ci.yaml)
- [X] Refresh the [`./tests`](https://github.com/cloudeteer/terraform-module-template/tree/main/tests) folder with the latest tests.

---

## 3. Development

- [ ] ⭐ **Simplify Configuration**  
  Remove all unused optional arguments from the `azurerm_mssql_virtual_machine` resource to keep the configuration minimal and focused.

- [ ] ⭐ **Default VM Image**  
  Define a default `azurerm_virtual_machine_image` input variable for the module to provide a baseline image.

- [ ] ⭐ **Virtual Machine Size**  
  Use the `size` input variable from the virtual machine submodule and allow it to be overridden by users. Determine an appropriate default size for a MSSQL virtual machine.

- [ ] ⭐ **Optional Admin Password Storage**  
  Add an option to disable storing the generated admin password in a key vault, leveraging the [`store_secret_in_key_vault`](https://github.com/cloudeteer/terraform-azurerm-vm#-store_secret_in_key_vault) argument.

- [ ] ⭐ **Allow OS Disk Configuration**  
  Enable the configuration of the virtual machine's [`os_disk`](https://github.com/cloudeteer/terraform-azurerm-vm#-os_disk) through module inputs, similar to how `data_disks` are handled.

- [ ] ⭐ **Expose Additional VM Inputs**  
  Expose the following input variables from the virtual machine submodule to your module input interface (without using the `azurerm_virtual_machine_` prefix):
    - `admin_password`
    - `admin_username`
    - `computer_name`
    - `enable_automatic_updates`
    - `enable_backup_protected_vm`
    - `hotpatching_enabled`
    - `identity` (merge with the required "Built-In-Identity")
    - `patch_assessment_mode`
    - `patch_mode`
    - `private_ip_address`
    - `tags`
    - `tags_virtual_machine`
    - `zone`

- [ ] ⭐⭐ **Configure VM Extensions**  
  Expose the virtual machine submodule’s [`extensions`](https://github.com/cloudeteer/terraform-azurerm-vm#-extensions) argument as a configurable input in your module. Consult the Azure Chapter to decide which default extensions are needed for MSSQL virtual machines.

- [ ] ⭐⭐ **Built-In Identity**  
  Ensure that the "Built-In-Identity" is assigned to the Virtual Machine. This identity is automatically added by Azure to all VMs associated with the [azurerm_mssql_virtual_machine](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mssql_virtual_machine) resource. To avoid Terraform drift, the identity should be explicitly added in the code.  
  Use a Terraform AzureRM data source to dynamically retrieve the identity ID instead of hardcoding it. The identity name is always in the format `Built-In-Identity-$LOCATION`, where `$LOCATION` is the Azure region where the module is deployed.

- [ ] ⭐⭐⭐⭐ **Disk Setup**  
  Ensure proper alignment between the data disks attached to the VM (via [`var.data_disks`](https://github.com/cloudeteer/terraform-azurerm-vm#-data_disks)) and the [`storage_configuration`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mssql_virtual_machine#storage_configuration) of the `azurerm_mssql_virtual_machine` resource. Reuse the data passed to the `azurerm_virtual_machine_data_disks` argument in the `storage_configuration` block to ensure consistency between the disk setup and the MSSQL configuration.

- [ ] ⭐⭐⭐⭐⭐⭐ **Implement Percentage-Based Memory Input Variables**  
  Add new input variables `max_server_memory_mb_percent` and `min_server_memory_mb_percent` to complement the existing `max_server_memory_mb` and `min_server_memory_mb` arguments of the `azurerm_mssql_virtual_machine` resource. This allows module users to define memory limits as either absolute values or relative percentages, offering more flexibility in memory configuration.

- [ ] ⭐⭐⭐⭐⭐⭐⭐⭐ **Allow External VM**
  Make it possible for users to bring their own virtual machine instead of having this module create one.

- [ ] 🌟 **Azure Chapter Input**  
  Collaborate with the Azure Chapter to decide the default settings for a MSSQL virtual machine compared to a regular VM.

- [ ] 🌟 **Present and Gather Feedback**  
  Present the completed module to the Azure Chapter and gather their feedback for improvements.