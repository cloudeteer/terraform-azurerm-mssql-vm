mock_provider "azurerm" { source = "tests/local/mocks" }
mock_provider "time" { source = "tests/local/mocks" }

variables {
  location            = "westeurope"
  name                = "vm-tftest-dev-euw-01"
  resource_group_name = "rg-tftest-dev-euw-01"

  computer_name    = "tftest"
  backup_policy_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-example-dev-we-01/providers/Microsoft.RecoveryServices/vaults/rsv-example-dev-we-01/backupPolicies/policy"
  key_vault_id     = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg/providers/Microsoft.KeyVault/vaults/kv"
  subnet_id        = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg/providers/Microsoft.Network/virtualNetworks/vnet/subnets/snet"
}

run "should_succeed_with_no_storage_configuration" {
  command = plan
}

run "should_succeed_with_minimal_storage_configuration" {
  command = plan

  variables {
    storage_configuration = {
      disk_type                      = "NEW"
      storage_workload_type          = "OLTP"
      system_db_on_data_disk_enabled = false
    }
  }
}

run "should_succeed_with_each_one_disk" {
  command = plan

  variables {
    storage_configuration = {
      disk_type                      = "NEW"
      storage_workload_type          = "OLTP"
      system_db_on_data_disk_enabled = false

      data_settings = {
        luns              = [0]
        disk_size_gb      = 64
        default_file_path = "F:\\data"
      }
      log_settings = {
        luns              = [1]
        disk_size_gb      = 64
        default_file_path = "G:\\log"
      }
      temp_db_settings = {
        luns              = [2]
        default_file_path = "H:\\tempDb"
      }
    }
  }
}

run "should_succeed_with_each_multiple_disks" {
  command = plan

  variables {
    storage_configuration = {
      disk_type                      = "NEW"
      storage_workload_type          = "OLTP"
      system_db_on_data_disk_enabled = false

      data_settings = {
        luns              = [0, 1, 2]
        disk_size_gb      = 64
        default_file_path = "F:\\data"
      }
      log_settings = {
        luns              = [3, 4, 5]
        disk_size_gb      = 64
        default_file_path = "G:\\log"
      }
      temp_db_settings = {
        luns              = [6, 7, 8]
        default_file_path = "H:\\tempDb"
      }
    }
  }
}

run "should_succeed_with_no_disks" {
  command = plan

  variables {
    storage_configuration = {
      disk_type                      = "NEW"
      storage_workload_type          = "OLTP"
      system_db_on_data_disk_enabled = false

      data_settings = {
        luns              = []
        default_file_path = "D:\\data"
      }
      log_settings = {
        luns              = []
        default_file_path = "D:\\log"
      }
      temp_db_settings = {
        luns              = []
        default_file_path = "D:\\tempDb"
      }
    }
  }
}

run "should_fail_on_missing_disk_size_when_lun_is_defined" {
  command = plan

  variables {
    storage_configuration = {
      disk_type                      = "NEW"
      storage_workload_type          = "OLTP"
      system_db_on_data_disk_enabled = false

      data_settings = {
        luns              = [0, 1, 2]
        disk_size_gb      = 64
        default_file_path = "F:\\data"
      }
      log_settings = {
        luns              = [3, 4, 5]
        disk_size_gb      = 64
        default_file_path = "G:\\log"
      }
      temp_db_settings = {
        luns              = [6, 7, 8]
        default_file_path = "H:\\tempDb"
      }
    }
  }

  expect_failures = [var.storage_configuration]
}

run "should_fail_" {
  command = plan

  variables {
    storage_configuration = {
      disk_type                      = "NEW"
      storage_workload_type          = "OLTP"
      system_db_on_data_disk_enabled = false

      data_settings = {
        luns              = []
        disk_size_gb      = 64
        default_file_path = "D:\\data"
      }
      log_settings = {
        luns              = [1]
        disk_size_gb      = 64
        default_file_path = "G:\\log"
      }
      temp_db_settings = {
        luns              = []
        default_file_path = "H:\\tempDb"
      }
    }
  }

  expect_failures = [var.storage_configuration]
}


run "should_fail_on_wrong_file_path" {
  command = plan

  variables {
    storage_configuration = {
      disk_type                      = "NEW"
      storage_workload_type          = "OLTP"
      system_db_on_data_disk_enabled = false

      data_settings = {
        luns              = [0]
        disk_size_gb      = 64
        default_file_path = "D:\\data"
      }
      log_settings = {
        luns              = []
        disk_size_gb      = 64
        default_file_path = "G:\\log"
      }
      temp_db_settings = {
        luns              = []
        default_file_path = "H:\\tempDb"
      }
    }
  }

  expect_failures = [var.storage_configuration]
}

run "should_succeed_with_single_disk_for_all_disk_settings" {
  command = plan

  variables {
    storage_configuration = {
      disk_type                      = "NEW"
      storage_workload_type          = "OLTP"
      system_db_on_data_disk_enabled = false

      data_settings = {
        luns              = [0]
        disk_size_gb      = 64
        default_file_path = "F:\\data"
      }
      log_settings = {
        default_file_path = "F:\\log"
      }
      temp_db_settings = {
        default_file_path = "F:\\tempDb"
      }
    }
  }
}
