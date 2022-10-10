locals {
  backup_vault_name = split("/", var.backup_policy_id)[8]
  backup_vault_rg   = split("/", var.backup_policy_id)[4]
}
