resource "azurerm_backup_container_storage_account" "backup" {
  for_each = toset(var.backup_policy_id != null ? ["enabled"] : [])

  recovery_vault_name = local.backup_vault_name
  resource_group_name = local.backup_vault_rg
  storage_account_id  = module.storage_account.storage_account_id

  lifecycle {
    precondition {
      condition     = !var.network_rules_enabled || contains(var.network_bypass, "AzureServices")
      error_message = "`AzureServices` must be allowed to access the Storage Account to have backup configured when firewall is enabled, please add it to `var.network_bypass`."
    }
  }
}

resource "azurerm_backup_protected_file_share" "backup" {
  for_each = toset(var.backup_policy_id != null ? [for s in var.file_shares : s.name if s.enabled_protocol != "NFS"] : [])

  backup_policy_id          = var.backup_policy_id
  recovery_vault_name       = local.backup_vault_name
  resource_group_name       = local.backup_vault_rg
  source_file_share_name    = module.storage_account.storage_file_shares[each.value].name
  source_storage_account_id = module.storage_account.storage_account_id

  depends_on = [azurerm_backup_container_storage_account.backup]

  lifecycle {
    precondition {
      condition     = !var.network_rules_enabled || contains(var.network_bypass, "AzureServices")
      error_message = "`AzureServices` must be allowed to access the Storage Account to have backup configured when firewall is enabled, please add it to `var.network_bypass`."
    }
  }
}
