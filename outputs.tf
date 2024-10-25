output "resource" {
  description = "Storage Account resource object."
  value       = module.storage_account
}

output "id" {
  description = "Storage Account ID."
  value       = module.storage_account.id
}

output "name" {
  description = "Storage Account name."
  value       = module.storage_account.name
}

output "identity_principal_id" {
  description = "Storage Account system identity principal ID."
  value       = module.storage_account.identity_principal_id
}

output "module_diagnostics" {
  description = "Diagnostics settings module outputs."
  value       = module.storage_account.module_diagnostics
}

output "file_shares" {
  description = "Created file shares in the Storage Account."
  value       = module.storage_account.resource_file_shares
}

output "file_shares_mount_endpoints" {
  description = "Mount endpoints of created file shares."
  value       = local.mount_endpoints
}

output "file_shares_mount_options" {
  description = "Mount options for the file shares."
  value       = local.mount_options
}

output "file_shares_default_fstab_entries" {
  description = "Default fstab entries for the file shares."
  value       = local.fstab_entries
}

output "file_shares_default_mount_commands" {
  description = "Default mount commands for the file shares."
  value       = local.mount_cmds
}

output "file_shares_default_mount_paths" {
  description = "Default mount paths for the file shares."
  value       = local.mount_paths
}

output "default_cifs_configuration_file_path" {
  description = "Default configuration file path for CIFS credentials file."
  value       = local.cifs_creds_file_path
}

output "cifs_credentials_file_content" {
  description = "Content of the CIFS credentials file."
  value       = local.cifs_creds_file_content
  sensitive   = true
}
