moved {
  from = azurerm_backup_container_storage_account.backup["enabled"]
  to   = azurerm_backup_container_storage_account.main[0]
}

resource "azurerm_backup_container_storage_account" "main" {
  count = var.backup_policy_id != null ? 1 : 0

  recovery_vault_name = local.backup_vault_name
  resource_group_name = local.backup_vault_rg
  storage_account_id  = module.storage_account.id

  lifecycle {
    precondition {
      condition     = !var.network_rules_enabled || contains(var.network_bypass, "AzureServices")
      error_message = "`AzureServices` must be allowed to access the Storage Account to have backup configured when firewall is enabled, please add it to `var.network_bypass`."
    }
  }
}

moved {
  from = azurerm_backup_protected_file_share.backup
  to   = azurerm_backup_protected_file_share.main
}

resource "azurerm_backup_protected_file_share" "main" {
  for_each = toset(var.backup_policy_id != null ? [for s in var.file_shares : s.name if s.enabled_protocol != "NFS"] : [])

  backup_policy_id          = var.backup_policy_id
  recovery_vault_name       = local.backup_vault_name
  resource_group_name       = local.backup_vault_rg
  source_file_share_name    = module.storage_account.resource_file_shares[each.value].name
  source_storage_account_id = module.storage_account.id

  depends_on = [azurerm_backup_container_storage_account.main]

  lifecycle {
    precondition {
      condition     = !var.network_rules_enabled || contains(var.network_bypass, "AzureServices")
      error_message = "`AzureServices` must be allowed to access the Storage Account to have backup configured when firewall is enabled, please add it to `var.network_bypass`."
    }
  }
}
