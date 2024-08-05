output "storage_account_properties" {
  description = "Created Storage Account properties"
  value       = module.storage_account.storage_account_properties
  sensitive   = true
}

output "storage_account_id" {
  description = "Created Storage Account ID"
  value       = module.storage_account.storage_account_id
}

output "storage_account_name" {
  description = "Created Storage Account name"
  value       = module.storage_account.storage_account_name
}

output "storage_account_identity" {
  description = "Created Storage Account identity block"
  value       = module.storage_account.storage_account_identity
}

output "storage_file_shares" {
  description = "Created file shares in the Storage Account"
  value       = module.storage_account.storage_file_shares
}

output "storage_file_shares_mount_endpoints" {
  description = "Mount endpoints of created file shares"
  value       = local.mount_endpoints
}

output "storage_file_shares_mount_options" {
  description = "Mount options for the file shares"
  value       = local.mount_options
}

output "storage_file_shares_default_fstab_entries" {
  description = "Default fstab entries for the file shares"
  value       = local.fstab_entries
}

output "storage_file_shares_default_mount_commands" {
  description = "Default mount commands for the file shares"
  value       = local.mount_cmds
}

output "storage_file_shares_default_mount_paths" {
  description = "Default mount paths for the file shares"
  value       = local.mount_paths
}

output "default_cifs_configuration_file_path" {
  description = "Default configuration file path for CIFS credentials file"
  value       = local.cifs_creds_file_path
}

output "cifs_credentials_file_content" {
  description = "Content of the CIFS credentials file"
  value       = local.cifs_creds_file_content
  sensitive   = true
}
